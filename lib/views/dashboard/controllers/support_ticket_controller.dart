import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/support_ticket_model.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';

class SupportTicketController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _ticketsSubscription;

  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Filters (Section 4.1)
  final RxString selectedRoleFilter = 'All'.obs; // All, Driver, Passenger
  final RxString selectedStatusFilter =
      'All'.obs; // All, Open, Resolved
  final RxString selectedCategoryFilter =
      'All'.obs; // All, Fare / Payment, Ride Issue, Account / Profile, Other

  final Rx<SupportTicketModel?> selectedTicket = Rx<SupportTicketModel?>(null);
  final TextEditingController replyController = TextEditingController();

  final List<String> categories = [
    'All',
    'Fare / Payment',
    'Ride Issue',
    'Account / Profile',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    isLoading(true);
    try {
      _ticketsSubscription = _firestore
          .collection('support_tickets')
          .snapshots()
          .listen(
            (snapshot) {
              final List<SupportTicketModel> loaded = [];
              for (var doc in snapshot.docs) {
                try {
                  loaded.add(SupportTicketModel.fromFirestore(doc));
                } catch (e) {
                  debugPrint(
                    'Error parsing support ticket document ${doc.id}: $e',
                  );
                }
              }
              // Sort by createdAt descending (most recent first)
              loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              tickets.assignAll(loaded);
              isLoading(false);

              // Keep selectedTicket updated if it was currently opened
              if (selectedTicket.value != null) {
                final updatedSelected = tickets.firstWhereOrNull(
                  (t) => t.id == selectedTicket.value!.id,
                );
                if (updatedSelected != null) {
                  selectedTicket.value = updatedSelected;
                }
              }
            },
            onError: (error) {
              isLoading(false);
              debugPrint('Firestore support_tickets error: $error');
              AppSnackBar.error(
                message: 'Error listening to support tickets: $error',
              );
            },
          );
    } catch (e) {
      isLoading(false);
      debugPrint('Error setting up support tickets subscription: $e');
    }
  }

  List<SupportTicketModel> get filteredTickets {
    return tickets.where((ticket) {
      final query = searchQuery.value.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          ticket.id.toLowerCase().contains(query) ||
          ticket.userName.toLowerCase().contains(query) ||
          ticket.userEmail.toLowerCase().contains(query) ||
          ticket.subject.toLowerCase().contains(query) ||
          ticket.message.toLowerCase().contains(query);

      final matchesRole =
          selectedRoleFilter.value == 'All' ||
          ticket.userRole.toLowerCase() ==
              selectedRoleFilter.value.toLowerCase();

      final matchesStatus =
          selectedStatusFilter.value == 'All' ||
          (selectedStatusFilter.value == 'Open' &&
              (ticket.isOpen || ticket.isInProgress)) ||
          (selectedStatusFilter.value == 'Resolved' && ticket.isResolved);

      final matchesCategory =
          selectedCategoryFilter.value == 'All' ||
          ticket.category == selectedCategoryFilter.value;

      return matchesSearch && matchesRole && matchesStatus && matchesCategory;
    }).toList();
  }

  int get totalCount => tickets.length;
  int get openCount => tickets.where((t) => !t.isResolved).length;
  int get inProgressCount => tickets.where((t) => t.isInProgress).length;
  int get resolvedCount => tickets.where((t) => t.isResolved).length;
  int get unresolvedCount => tickets.where((t) => !t.isResolved).length;

  void setSearchQuery(String val) => searchQuery.value = val;
  void setRoleFilter(String val) => selectedRoleFilter.value = val;
  void setStatusFilter(String val) => selectedStatusFilter.value = val;
  void setCategoryFilter(String val) => selectedCategoryFilter.value = val;

  void selectTicket(SupportTicketModel ticket) {
    selectedTicket.value = ticket;
    replyController.clear();
  }

  void closeTicketModal() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    selectedTicket.value = null;
    replyController.clear();
  }

  Future<void> updateTicketStatus(String ticketId, String newStatus) async {
    final formattedStatus = newStatus.toLowerCase().replaceAll(' ', '_');
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': formattedStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local memory optimistically
      final index = tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        final updated = tickets[index].copyWith(
          status: formattedStatus,
          updatedAt: DateTime.now(),
        );
        tickets[index] = updated;
        if (selectedTicket.value?.id == ticketId) {
          selectedTicket.value = updated;
        }
        AppSnackBar.success(
          message:
              'Ticket $ticketId status updated to ${updated.displayStatus}',
        );
      }
    } catch (e) {
      debugPrint('Error updating ticket status in Firestore: $e');
      AppSnackBar.error(
        message: 'Failed to update ticket status in Firebase: $e',
      );
    }
  }

  Future<void> sendReply(String ticketId, String replyText) async {
    if (replyText.trim().isEmpty) return;

    final index = tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    final current = tickets[index];
    final authCtrl = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    final adminName = authCtrl?.currentUserName ?? 'Support Team';

    final newMsg = TicketMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderRole: 'admin',
      senderName: adminName,
      message: replyText.trim(),
      timestamp: DateTime.now(),
    );

    try {
      final updatedStatus = current.status;

      await _firestore.collection('support_tickets').doc(ticketId).update({
        'adminReply': replyText.trim(),
        'status': updatedStatus,
        'messages': FieldValue.arrayUnion([newMsg.toJson()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification document so user receives a push notification via backend listener
      if (current.userId.isNotEmpty) {
        try {
          await _firestore.collection('notifications').add({
            'userId': current.userId,
            'title': 'Support Team Replied',
            'body': replyText.trim(),
            'message': replyText.trim(),
            'type': 'support_ticket_reply',
            'ticketId': ticketId,
            'subject': current.subject,
            'userRole': current.userRole,
            'senderName': adminName,
            'senderRole': 'admin',
            'isRead': false,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
            'timestamp': FieldValue.serverTimestamp(),
            'data': {
              'ticketId': ticketId,
              'type': 'support_ticket_reply',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          });
        } catch (notifErr) {
          debugPrint('Warning: Could not create notification document: $notifErr');
        }
      }

      // Local optimistic update
      final updatedMessages = List<TicketMessage>.from(current.messages)
        ..add(newMsg);
      final updated = current.copyWith(
        adminReply: replyText.trim(),
        messages: updatedMessages,
        status: updatedStatus,
        updatedAt: DateTime.now(),
      );

      tickets[index] = updated;
      if (selectedTicket.value?.id == ticketId) {
        selectedTicket.value = updated;
      }
      replyController.clear();
      AppSnackBar.success(
        message:
            'Reply sent to user ${current.userName}\'s mobile app and saved in Firebase!',
      );
    } catch (e) {
      debugPrint('Error sending reply to Firestore: $e');
      AppSnackBar.error(message: 'Failed to save reply in Firebase: $e');
    }
  }

  /// Create a new support ticket in Firestore
  Future<bool> createTicket({
    required String userName,
    required String userEmail,
    required String userPhone,
    required String userRole,
    required String category,
    required String subject,
    required String message,
    String? tripId,
  }) async {
    try {
      final docRef = _firestore.collection('support_tickets').doc();
      final initialMessage = TicketMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderRole: userRole.toLowerCase(),
        senderName: userName,
        message: message.trim(),
        timestamp: DateTime.now(),
      );

      final ticket = SupportTicketModel(
        id: docRef.id,
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        userName: userName.trim(),
        userEmail: userEmail.trim(),
        userPhone: userPhone.trim(),
        userRole: userRole.toLowerCase(),
        category: category,
        subject: subject.trim(),
        message: message.trim(),
        tripId: tripId?.trim().isNotEmpty == true ? tripId!.trim() : null,
        status: 'open',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [initialMessage],
      );

      await docRef.set(ticket.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error creating support ticket: $e');
      AppSnackBar.error(message: 'Failed to create ticket: $e');
      return false;
    }
  }

  /// Delete a support ticket from Firestore
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).delete();
      tickets.removeWhere((t) => t.id == ticketId);
      if (selectedTicket.value?.id == ticketId) {
        selectedTicket.value = null;
      }
      AppSnackBar.success(message: 'Ticket #$ticketId deleted successfully.');
    } catch (e) {
      debugPrint('Error deleting ticket from Firestore: $e');
      AppSnackBar.error(message: 'Failed to delete ticket: $e');
    }
  }

  @override
  void onClose() {
    _ticketsSubscription?.cancel();
    replyController.dispose();
    super.onClose();
  }
}

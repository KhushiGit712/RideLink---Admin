import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {}
  }
  return DateTime.now();
}

class TicketMessage {
  final String id;
  final String senderRole; // 'user' or 'admin'
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String? attachmentUrl;

  TicketMessage({
    required this.id,
    required this.senderRole,
    required this.senderName,
    required this.message,
    DateTime? timestamp,
    this.attachmentUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isAdmin => senderRole.toLowerCase() == 'admin';

  String get formattedTime => DateFormat('MMM dd, hh:mm a').format(timestamp);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderRole': senderRole,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'attachmentUrl': attachmentUrl,
    };
  }

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? 'user',
      senderName: json['senderName']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: _parseDateTime(json['timestamp']),
      attachmentUrl: json['attachmentUrl']?.toString(),
    );
  }
}

class SupportTicketModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userRole; // "driver" | "passenger"
  final String category; // "Fare / Payment", "Ride Issue", "Account / Profile", "Other"
  final String subject;
  final String message;
  final String? tripId;
  final String? attachmentUrl;
  final String status; // "open" | "in_progress" | "resolved"
  final String? adminReply;
  final List<TicketMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userRole,
    required this.category,
    required this.subject,
    required this.message,
    this.tripId,
    this.attachmentUrl,
    this.status = 'open',
    this.adminReply,
    List<TicketMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        messages = messages ?? [];

  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userRole,
    String? category,
    String? subject,
    String? message,
    String? tripId,
    String? attachmentUrl,
    String? status,
    String? adminReply,
    List<TicketMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userRole: userRole ?? this.userRole,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      tripId: tripId ?? this.tripId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      adminReply: adminReply ?? this.adminReply,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedCreatedDate => DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt);
  String get formattedUpdatedDate => DateFormat('MMM dd, yyyy • hh:mm a').format(updatedAt);

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isResolved => status.toLowerCase() == 'resolved';
  bool get isDriver => userRole.toLowerCase() == 'driver';
  bool get isPassenger => userRole.toLowerCase() == 'passenger';

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return 'Open';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userRole': userRole,
      'category': category,
      'subject': subject,
      'message': message,
      'tripId': tripId,
      'attachmentUrl': attachmentUrl,
      'status': status,
      'adminReply': adminReply,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userRole': userRole,
      'category': category,
      'subject': subject,
      'message': message,
      'tripId': tripId,
      'attachmentUrl': attachmentUrl,
      'status': status,
      'adminReply': adminReply,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return SupportTicketModel.fromJson(data, id: doc.id);
  }

  factory SupportTicketModel.fromJson(Map<String, dynamic> json, {String? id}) {
    List<TicketMessage> parsedMessages = [];
    if (json['messages'] != null && json['messages'] is List) {
      parsedMessages = (json['messages'] as List)
          .map((m) => TicketMessage.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } else if (json['message'] != null && (json['message'] as String).isNotEmpty) {
      // If messages array is not yet created, create an initial user message
      parsedMessages = [
        TicketMessage(
          id: 'initial_msg',
          senderRole: json['userRole']?.toString() ?? 'user',
          senderName: json['userName']?.toString() ?? 'User',
          message: json['message']?.toString() ?? '',
          timestamp: _parseDateTime(json['createdAt']),
          attachmentUrl: json['attachmentUrl']?.toString(),
        ),
      ];
    }

    return SupportTicketModel(
      id: id ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Unknown User',
      userEmail: json['userEmail']?.toString() ?? '',
      userPhone: json['userPhone']?.toString() ?? '',
      userRole: json['userRole']?.toString() ?? 'passenger',
      category: json['category']?.toString() ?? 'Other',
      subject: json['subject']?.toString() ?? 'Support Request',
      message: json['message']?.toString() ?? '',
      tripId: json['tripId']?.toString(),
      attachmentUrl: json['attachmentUrl']?.toString(),
      status: json['status']?.toString() ?? 'open',
      adminReply: json['adminReply']?.toString(),
      messages: parsedMessages,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
}

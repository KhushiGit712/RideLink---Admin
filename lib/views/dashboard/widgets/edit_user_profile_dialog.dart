import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/community_model.dart';
import 'package:ridelink_admin/data/models/data/driver_document_request_model.dart';
import 'package:ridelink_admin/data/models/data/support_ticket_model.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';

/// Modal dialog allowing administrators to update basic profile information
/// for Drivers and Passengers (Full Name, Phone, Email, Vehicle details).
class EditUserProfileDialog extends StatefulWidget {
  final String userId;
  final String initialName;
  final String initialPhone;
  final String initialEmail;
  final bool initialIsDriver;
  final String initialVehicleMake;
  final String initialVehicleModel;
  final String initialVehiclePlate;
  final String initialVehicleColor;
  final String initialVehicleType;
  final String? communityId;
  final VoidCallback? onSaved;

  const EditUserProfileDialog({
    super.key,
    required this.userId,
    required this.initialName,
    this.initialPhone = '',
    this.initialEmail = '',
    this.initialIsDriver = false,
    this.initialVehicleMake = '',
    this.initialVehicleModel = '',
    this.initialVehiclePlate = '',
    this.initialVehicleColor = '',
    this.initialVehicleType = 'Sedan',
    this.communityId,
    this.onSaved,
  });

  /// Factory constructor for Driver Document Request
  factory EditUserProfileDialog.fromDriver({
    required DriverDocumentRequestModel driver,
    VoidCallback? onSaved,
  }) {
    return EditUserProfileDialog(
      userId: driver.driverId,
      initialName: driver.driverName,
      initialPhone: driver.driverPhone,
      initialEmail: driver.driverEmail,
      initialIsDriver: true,
      initialVehicleMake: driver.vehicleMake,
      initialVehicleModel: driver.vehicleModel,
      initialVehiclePlate: driver.vehiclePlate,
      initialVehicleColor: driver.vehicleColor,
      initialVehicleType:
          driver.vehicleType.isNotEmpty ? driver.vehicleType : 'Sedan',
      onSaved: onSaved,
    );
  }

  /// Factory constructor for Community Member (Driver or Passenger)
  factory EditUserProfileDialog.fromCommunityMember({
    required CommunityMemberModel member,
    required String communityId,
    VoidCallback? onSaved,
  }) {
    return EditUserProfileDialog(
      userId: member.userId,
      initialName: member.name,
      initialPhone: member.phone ?? '',
      initialEmail: member.email ?? '',
      initialIsDriver: member.isDriver,
      communityId: communityId,
      onSaved: onSaved,
    );
  }

  /// Factory constructor for Support Ticket user
  factory EditUserProfileDialog.fromTicket({
    required SupportTicketModel ticket,
    VoidCallback? onSaved,
  }) {
    return EditUserProfileDialog(
      userId: ticket.userId,
      initialName: ticket.userName,
      initialPhone: ticket.userPhone,
      initialEmail: ticket.userEmail,
      initialIsDriver: ticket.isDriver,
      onSaved: onSaved,
    );
  }

  @override
  State<EditUserProfileDialog> createState() => _EditUserProfileDialogState();
}

class _EditUserProfileDialogState extends State<EditUserProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  // Vehicle controllers
  late TextEditingController _vehicleMakeController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehiclePlateController;
  late TextEditingController _vehicleColorController;
  late String _selectedVehicleType;

  late bool _isDriver;
  bool _isSaving = false;
  bool _isLoadingVehicleData = false;

  final List<String> _vehicleTypes = const [
    'Sedan',
    'SUV',
    'Hatchback',
    'Van',
    'Motorcycle',
    'Coupe',
    'Truck',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isDriver = widget.initialIsDriver;
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);

    _vehicleMakeController =
        TextEditingController(text: widget.initialVehicleMake);
    _vehicleModelController =
        TextEditingController(text: widget.initialVehicleModel);
    _vehiclePlateController =
        TextEditingController(text: widget.initialVehiclePlate);
    _vehicleColorController =
        TextEditingController(text: widget.initialVehicleColor);
    _selectedVehicleType = widget.initialVehicleType.isNotEmpty
        ? widget.initialVehicleType
        : 'Sedan';

    if (!_vehicleTypes.contains(_selectedVehicleType)) {
      _selectedVehicleType = 'Sedan';
    }

    // If driver and vehicle plate wasn't passed, attempt one-shot fetch from Firestore
    if (_isDriver && widget.initialVehiclePlate.isEmpty && widget.userId.isNotEmpty) {
      _fetchDriverVehicleData();
    }
  }

  Future<void> _fetchDriverVehicleData() async {
    try {
      setState(() => _isLoadingVehicleData = true);
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (snap.exists && mounted) {
        final data = snap.data();
        if (data != null && data['vehicle'] is Map) {
          final v = Map<String, dynamic>.from(data['vehicle'] as Map);
          _vehicleMakeController.text = (v['make'] ?? '').toString();
          _vehicleModelController.text = (v['model'] ?? '').toString();
          _vehiclePlateController.text = (v['licensePlate'] ?? '').toString();
          _vehicleColorController.text = (v['color'] ?? '').toString();
          final type = (v['type'] ?? '').toString();
          if (_vehicleTypes.contains(type)) {
            _selectedVehicleType = type;
          }
        }
      }
    } catch (e) {
      debugPrint('Error pre-fetching vehicle data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingVehicleData = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  void _closeModal() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.back();
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final cleanName = _nameController.text.trim();
    final cleanPhone = _phoneController.text.trim();
    final cleanEmail = _emailController.text.trim();
    final cleanMake = _vehicleMakeController.text.trim();
    final cleanModel = _vehicleModelController.text.trim();
    final cleanPlate = _vehiclePlateController.text.trim().toUpperCase();
    final cleanColor = _vehicleColorController.text.trim();

    try {
      // 1. Prepare user doc update in Cloud Firestore 'users' collection
      final Map<String, dynamic> userUpdate = {
        'fullName': cleanName,
        'name': cleanName,
        'phoneNumber': cleanPhone,
        'phone': cleanPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (cleanEmail.isNotEmpty) {
        userUpdate['email'] = cleanEmail;
      }

      if (_isDriver) {
        userUpdate['vehicle'] = {
          'make': cleanMake,
          'model': cleanModel,
          'licensePlate': cleanPlate,
          'color': cleanColor,
          'type': _selectedVehicleType,
        };
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set(userUpdate, SetOptions(merge: true));

      // 2. If community member, update community subcollection record as well
      if (widget.communityId != null && widget.communityId!.isNotEmpty) {
        final Map<String, dynamic> memberUpdate = {
          'name': cleanName,
          'phone': cleanPhone,
          'role': _isDriver ? 'driver' : 'passenger',
        };
        if (cleanEmail.isNotEmpty) {
          memberUpdate['email'] = cleanEmail;
        }

        await FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId)
            .collection('members')
            .doc(widget.userId)
            .set(memberUpdate, SetOptions(merge: true));
      }

      // 3. If DriverDocumentController is registered and we're updating a driver, update local reactive state
      if (Get.isRegistered<DriverDocumentController>() && _isDriver) {
        final driverCtrl = Get.find<DriverDocumentController>();
        final idx = driverCtrl.requests
            .indexWhere((r) => r.driverId == widget.userId || r.id == widget.userId);
        if (idx != -1) {
          final old = driverCtrl.requests[idx];
          final updated = old.copyWith(
            driverName: cleanName,
            driverPhone: cleanPhone,
            driverEmail: cleanEmail.isNotEmpty ? cleanEmail : old.driverEmail,
            vehicleMake: cleanMake,
            vehicleModel: cleanModel,
            vehiclePlate: cleanPlate,
            vehicleColor: cleanColor,
            vehicleType: _selectedVehicleType,
          );
          driverCtrl.requests[idx] = updated;
          if (driverCtrl.selectedRequest.value?.driverId == widget.userId ||
              driverCtrl.selectedRequest.value?.id == widget.userId) {
            driverCtrl.selectedRequest.value = updated;
          }
        }
      }

      // 4. Trigger caller callback
      widget.onSaved?.call();

      // 5. CRITICAL: Close dialog FIRST before showing snackbar notification
      if (!mounted) return;
      _closeModal();

      // 6. Show success snackbar AFTER dialog closure
      AppSnackBar.success(
        message:
            '${_isDriver ? "Driver" : "Passenger"} profile updated successfully.',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
      AppSnackBar.error(message: 'Failed to update profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 620,
        constraints: const BoxConstraints(maxHeight: 780),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isDriver
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isDriver
                            ? const Color(0xFFBFDBFE)
                            : const Color(0xFFBBF7D0),
                      ),
                    ),
                    child: Icon(
                      _isDriver
                          ? Icons.drive_eta_rounded
                          : Icons.person_rounded,
                      color: _isDriver
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isDriver
                              ? 'Edit Driver Profile'
                              : 'Edit Passenger Profile',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Update basic details directly in Cloud Firestore (User ID: ${widget.userId})',
                          style: AppTextStyle.text12MediumOrSmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _closeModal,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // Scrollable Form Fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Toggle Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.manage_accounts_outlined,
                                  size: 20,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Profile Account Role:',
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Passenger'),
                                  selected: !_isDriver,
                                  onSelected: (val) {
                                    if (val) setState(() => _isDriver = false);
                                  },
                                  selectedColor: const Color(0xFFDCFCE7),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: !_isDriver
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Driver'),
                                  selected: _isDriver,
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() => _isDriver = true);
                                      if (_vehiclePlateController.text.isEmpty) {
                                        _fetchDriverVehicleData();
                                      }
                                    }
                                  },
                                  selectedColor: const Color(0xFFDBEAFE),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _isDriver
                                        ? const Color(0xFF1D4ED8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Section 1: Basic Personal Info
                      Text(
                        'BASIC INFORMATION',
                        style: AppTextStyle.text12MediumOrSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF475569),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Full Name
                      _buildLabel('Full Name *'),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          hint: 'e.g. John Doe',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Phone & Email in a 2-column row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Phone Number'),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _inputDecoration(
                                    hint: 'e.g. +61 412 345 678',
                                    icon: Icons.phone_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Email Address'),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _inputDecoration(
                                    hint: 'e.g. user@example.com',
                                    icon: Icons.email_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Section 2: Vehicle Details (for Drivers)
                      if (_isDriver) ...[
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'VEHICLE DETAILS',
                              style: AppTextStyle.text12MediumOrSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF475569),
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (_isLoadingVehicleData)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // License Plate Number & Vehicle Type Row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('License Plate Number *'),
                                  TextFormField(
                                    controller: _vehiclePlateController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: _inputDecoration(
                                      hint: 'e.g. 1ABC234',
                                      icon: Icons.badge_outlined,
                                    ),
                                    validator: (v) {
                                      if (_isDriver &&
                                          (v == null || v.trim().isEmpty)) {
                                        return 'License plate is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Vehicle Type'),
                                  Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedVehicleType,
                                        isExpanded: true,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 20),
                                        items: _vehicleTypes.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(
                                              type,
                                              style: const TextStyle(
                                                  fontSize: 13),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() =>
                                                _selectedVehicleType = val);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Make & Model Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Vehicle Make'),
                                  TextFormField(
                                    controller: _vehicleMakeController,
                                    decoration: _inputDecoration(
                                      hint: 'e.g. Toyota',
                                      icon: Icons.directions_car_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Vehicle Model'),
                                  TextFormField(
                                    controller: _vehicleModelController,
                                    decoration: _inputDecoration(
                                      hint: 'e.g. Camry',
                                      icon: Icons.car_rental_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Vehicle Color
                        _buildLabel('Vehicle Color'),
                        TextFormField(
                          controller: _vehicleColorController,
                          decoration: _inputDecoration(
                            hint: 'e.g. Silver / White / Black',
                            icon: Icons.color_lens_outlined,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // Footer Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : _closeModal,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveChanges,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded,
                            size: 18, color: Colors.white),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Changes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyle.text12MediumOrSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyle.text12MediumOrSmall.copyWith(
        color: const Color(0xFF94A3B8),
      ),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }
}

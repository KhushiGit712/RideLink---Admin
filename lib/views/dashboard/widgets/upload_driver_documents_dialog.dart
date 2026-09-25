import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/widgets/app_button.dart';
import 'package:ridelink_admin/widgets/app_text_field.dart';

class UploadDriverDocumentsDialog extends StatefulWidget {
  const UploadDriverDocumentsDialog({super.key});

  @override
  State<UploadDriverDocumentsDialog> createState() =>
      _UploadDriverDocumentsDialogState();
}

class _UploadDriverDocumentsDialogState
    extends State<UploadDriverDocumentsDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _driverNameController = TextEditingController();
  final _driverEmailController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _driverIdController = TextEditingController();

  final _vehicleMakeController = TextEditingController(text: 'Toyota');
  final _vehicleModelController = TextEditingController(text: 'Camry');
  final _vehicleYearController = TextEditingController(text: '2023');
  final _vehiclePlateController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  String _selectedVehicleType = 'Sedan';

  final _licenseNumberController = TextEditingController();
  final _insuranceExpiryController = TextEditingController(text: '2027-12-31');

  // Picked Document Files
  Uint8List? _licenseFrontBytes;
  String? _licenseFrontName;

  Uint8List? _licenseBackBytes;
  String? _licenseBackName;

  Uint8List? _rcBytes;
  String? _rcName;

  Uint8List? _insuranceBytes;
  String? _insuranceName;

  Uint8List? _profileBytes;
  String? _profileName;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String docType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          switch (docType) {
            case 'license_front':
              _licenseFrontBytes = bytes;
              _licenseFrontName = image.name;
              break;
            case 'license_back':
              _licenseBackBytes = bytes;
              _licenseBackName = image.name;
              break;
            case 'rc':
              _rcBytes = bytes;
              _rcName = image.name;
              break;
            case 'insurance':
              _insuranceBytes = bytes;
              _insuranceName = image.name;
              break;
            case 'profile':
              _profileBytes = bytes;
              _profileName = image.name;
              break;
          }
        });
      }
    } catch (e) {
      AppSnackBar.error(message: 'Failed to pick image: $e');
    }
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverEmailController.dispose();
    _driverPhoneController.dispose();
    _driverIdController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehiclePlateController.dispose();
    _seatsController.dispose();
    _licenseNumberController.dispose();
    _insuranceExpiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverDocumentController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 840,
        constraints: const BoxConstraints(maxHeight: 860),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.cloud_upload_rounded,
                          color: AppColors.primaryColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Driver Documents (KYC)',
                            style: AppTextStyle.text20Medium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Upload document images directly to Firebase Storage and create a verification application in Firestore',
                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF64748B)),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Driver Details
                      _buildSectionHeader(
                        icon: Icons.person_rounded,
                        title: '1. Driver Personal Details',
                      ),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextFormField1(
                              controller: _driverNameController,
                              label: 'Driver Full Name *',
                              hintText: 'e.g. Michael Jordan',
                              prefixIcon: const Icon(Icons.badge_rounded,
                                  color: Color(0xFF94A3B8)),
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTextFormField1(
                              controller: _driverEmailController,
                              label: 'Email Address *',
                              hintText: 'michael@example.com',
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Color(0xFF94A3B8)),
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Email is required'
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextFormField1(
                              controller: _driverPhoneController,
                              label: 'Phone Number *',
                              hintText: '+61 400 123 456',
                              prefixIcon: const Icon(Icons.phone_outlined,
                                  color: Color(0xFF94A3B8)),
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Phone is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTextFormField1(
                              controller: _driverIdController,
                              label: 'Driver UID (Optional)',
                              hintText: 'Leave empty to auto-generate',
                              prefixIcon: const Icon(Icons.fingerprint_rounded,
                                  color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Section 2: Vehicle Details
                      _buildSectionHeader(
                        icon: Icons.directions_car_rounded,
                        title: '2. Vehicle Details',
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextFormField1(
                              controller: _vehicleMakeController,
                              label: 'Vehicle Make *',
                              hintText: 'e.g. Toyota',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextFormField1(
                              controller: _vehicleModelController,
                              label: 'Model *',
                              hintText: 'e.g. Camry',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextFormField1(
                              controller: _vehicleYearController,
                              label: 'Year *',
                              hintText: 'e.g. 2023',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextFormField1(
                              controller: _vehiclePlateController,
                              label: 'License Plate # *',
                              hintText: 'e.g. 1ABC999',
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Plate is required'
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextFormField1(
                              controller: _seatsController,
                              label: 'Passenger Seats',
                              hintText: '4',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vehicle Type',
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedVehicleType,
                                      isExpanded: true,
                                      items: ['Sedan', 'SUV', 'Electric', 'Van']
                                          .map((t) => DropdownMenuItem(
                                                value: t,
                                                child: Text(t),
                                              ))
                                          .toList(),
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

                      const SizedBox(height: 22),

                      // Section 3: License & Insurance Data
                      _buildSectionHeader(
                        icon: Icons.assignment_outlined,
                        title: '3. License & Insurance Details',
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextFormField1(
                              controller: _licenseNumberController,
                              label: 'Driver License Number *',
                              hintText: 'e.g. DL-987654321',
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'License number is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTextFormField1(
                              controller: _insuranceExpiryController,
                              label: 'Insurance Expiry Date',
                              hintText: 'YYYY-MM-DD',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section 4: Document Image Uploads to Firebase Storage
                      _buildSectionHeader(
                        icon: Icons.upload_file_rounded,
                        title: '4. Document Images (Upload to Firebase Storage)',
                      ),
                      const SizedBox(height: 14),

                      // Pickers Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // License Front
                          Expanded(
                            child: _buildDocUploadBox(
                              title: "Driver License (Front) *",
                              bytes: _licenseFrontBytes,
                              fileName: _licenseFrontName,
                              onPick: () => _pickImage('license_front'),
                              onRemove: () =>
                                  setState(() => _licenseFrontBytes = null),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // License Back
                          Expanded(
                            child: _buildDocUploadBox(
                              title: "Driver License (Back) *",
                              bytes: _licenseBackBytes,
                              fileName: _licenseBackName,
                              onPick: () => _pickImage('license_back'),
                              onRemove: () =>
                                  setState(() => _licenseBackBytes = null),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // RC Certificate
                          Expanded(
                            child: _buildDocUploadBox(
                              title: "Vehicle Registration (RC) *",
                              bytes: _rcBytes,
                              fileName: _rcName,
                              onPick: () => _pickImage('rc'),
                              onRemove: () => setState(() => _rcBytes = null),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Vehicle Insurance
                          Expanded(
                            child: _buildDocUploadBox(
                              title: "Vehicle Insurance Policy *",
                              bytes: _insuranceBytes,
                              fileName: _insuranceName,
                              onPick: () => _pickImage('insurance'),
                              onRemove: () =>
                                  setState(() => _insuranceBytes = null),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Profile image (optional)
                      _buildDocUploadBox(
                        title: "Driver Profile Photo (Optional)",
                        bytes: _profileBytes,
                        fileName: _profileName,
                        onPick: () => _pickImage('profile'),
                        onRemove: () => setState(() => _profileBytes = null),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // Uploading status display
              Obx(() {
                if (controller.isUploading.value) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          controller.uploadProgressMessage.value,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 14),
                  Obx(() => SizedBox(
                        width: 220,
                        child: AppButton(
                          label: controller.isUploading.value
                              ? 'Uploading...'
                              : 'Upload to Firebase',
                          onPressed: controller.isUploading.value
                              ? () {}
                              : () => _submitForm(controller),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyle.text14Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildDocUploadBox({
    required String title,
    required Uint8List? bytes,
    required String? fileName,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bytes != null
              ? const Color(0xFF16A34A)
              : const Color(0xFFCBD5E1),
          width: bytes != null ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              if (bytes != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SELECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (bytes != null) ...[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    bytes,
                    width: 70,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName ?? 'image.jpg',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 20),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ] else ...[
            InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded,
                        size: 20, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text(
                      'Choose Image File',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submitForm(DriverDocumentController controller) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_licenseFrontBytes == null) {
      AppSnackBar.error(message: 'Please choose License Front image.');
      return;
    }
    if (_licenseBackBytes == null) {
      AppSnackBar.error(message: 'Please choose License Back image.');
      return;
    }
    if (_rcBytes == null) {
      AppSnackBar.error(message: 'Please choose Vehicle RC image.');
      return;
    }
    if (_insuranceBytes == null) {
      AppSnackBar.error(message: 'Please choose Vehicle Insurance image.');
      return;
    }

    final success = await controller.uploadDriverApplication(
      driverName: _driverNameController.text.trim(),
      driverEmail: _driverEmailController.text.trim(),
      driverPhone: _driverPhoneController.text.trim(),
      driverId: _driverIdController.text.trim(),
      vehicleMake: _vehicleMakeController.text.trim(),
      vehicleModel: _vehicleModelController.text.trim(),
      vehicleYear: _vehicleYearController.text.trim(),
      vehiclePlate: _vehiclePlateController.text.trim(),
      passengerSeats: int.tryParse(_seatsController.text.trim()) ?? 4,
      vehicleType: _selectedVehicleType,
      licenseNumber: _licenseNumberController.text.trim(),
      insuranceExpiryDate: _insuranceExpiryController.text.trim(),
      licenseFrontBytes: _licenseFrontBytes!,
      licenseFrontFileName: _licenseFrontName ?? 'license_front.jpg',
      licenseBackBytes: _licenseBackBytes!,
      licenseBackFileName: _licenseBackName ?? 'license_back.jpg',
      rcBytes: _rcBytes!,
      rcFileName: _rcName ?? 'rc_doc.jpg',
      insuranceBytes: _insuranceBytes!,
      insuranceFileName: _insuranceName ?? 'insurance.jpg',
      profileImageBytes: _profileBytes,
      profileImageFileName: _profileName,
    );

    if (success) {
      Get.back();
    }
  }
}


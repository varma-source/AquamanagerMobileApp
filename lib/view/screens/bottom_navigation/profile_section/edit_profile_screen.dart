import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/services/profileService.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);

  final _profileController = Get.find<ProfileController>();
  final _profileService = Get.find<ProfileService>();
  final ImagePicker _picker = ImagePicker();

  // ---------- Controllers ----------
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ---------- Picked image ----------
  File? _pickedImage;
  bool _isSaving = false;
  bool _isPrefilled = false;

  @override
  void initState() {
    super.initState();
    _prefillFromController();
  }

  void _prefillFromController() {
    final user = _profileController.profileDataResponce.value.data;
    if (user != null) {
      _nameController.text = user.name ?? "";
      _emailController.text = user.email ?? "";
      _phoneController.text = user.phone ?? "";
      _addressController.text = user.address ?? "";
      _isPrefilled = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"could_not_pick_image".tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _primary,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    // ✅ Image is OPTIONAL — only validate if user actually picked one
    if (_pickedImage != null && !await _pickedImage!.exists()) {
      Get.snackbar(
        "image_missing".tr,
        "image_file_missing".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _profileService.updateProfiledetails(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        // ✅ Pass the picked image path OR null when nothing was picked
        image: _pickedImage?.path,
      );
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"update_failed".tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _primary,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith("http")) return imagePath;
    final clean =
        imagePath.startsWith("/") ? imagePath.substring(1) : imagePath;
    return "${AppBaseUrls.ImagebaseUrl}$clean";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Top Bar ----------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  CustomText(
                    textName: "edit_profile".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 15,
                  ),
                  const Spacer(),
                  const SizedBox(width: 18),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // ---------- Scrollable Form ----------
            Expanded(
              child: Obx(() {
                final user = _profileController.profileDataResponce.value.data;

                if (user == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!_isPrefilled) {
                  _prefillFromController();
                }

                final String currentImageUrl = _buildImageUrl(user.image);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ---------- Profile Photo Picker ----------
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primary.withOpacity(0.1),
                                  border: Border.all(
                                    color: _primary.withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _pickedImage != null
                                    ? Image.file(
                                        _pickedImage!,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      )
                                    : currentImageUrl.isNotEmpty
                                        ? Image.network(
                                            currentImageUrl,
                                            width: 110,
                                            height: 110,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const Center(
                                                child: SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Color(0xFF087FC1),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) =>
                                                const SizedBox.shrink(),
                                          )
                                        : const SizedBox.shrink(),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomText(
                          textName: "tap_to_change_photo".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                        const SizedBox(height: 26),

                        // ---------- Form Container ----------
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full Name
                              _buildLabel(Icons.person_outline, "full_name".tr),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _nameController,
                                hint: "enter_full_name".tr,
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? "please_enter_name".tr
                                        : null,
                              ),
                              const SizedBox(height: 18),

                              // Email (read-only)
                              _buildLabel(
                                Icons.email_outlined,
                                "email_address".tr,
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _emailController,
                                hint: "email".tr,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                readOnly: true,
                              ),
                              const SizedBox(height: 18),

                              // Phone
                              _buildLabel(
                                Icons.phone_outlined,
                                "phone_number".tr,
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _phoneController,
                                hint: "enter_phone".tr,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return "please_enter_phone".tr;
                                  }
                                  if (v.trim().length != 10) {
                                    return "phone_10_digits".tr;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Address
                              _buildLabel(
                                Icons.location_on_outlined,
                                "address".tr,
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _addressController,
                                hint: "enter_address".tr,
                                icon: Icons.location_on_outlined,
                                keyboardType: TextInputType.streetAddress,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ---------- Save Changes ----------
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _primary.withOpacity(0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : CustomText(
                                    textName: "save_changes".tr,
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.semiBold,
                                    textColor: Colors.white,
                                    fontSize: 14,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ---------- Cancel ----------
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: CustomText(
                              textName: "cancel".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.semiBold,
                              textColor: AppColors.blackColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _primary),
        const SizedBox(width: 8),
        CustomText(
          textName: text,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
          fontSize: 12,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        color: readOnly ? Colors.grey.shade600 : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
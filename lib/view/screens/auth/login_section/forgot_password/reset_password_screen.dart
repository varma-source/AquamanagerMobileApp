import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_images.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/services/authService.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String emailId;
  const ResetPasswordScreen({super.key, required this.emailId});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  final _authservice = Get.find<Authservice>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------- Back Button + Title ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.blackColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomText(
                        textName: "reset_password".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        fontSize: 20,
                        textColor: AppColors.blackColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ---------- App Logo ----------
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(AppImages.appLogo, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 24),

                // ---------- Title ----------
                CustomText(
                  textName: "create_new_password".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  fontSize: 22,
                  textColor: AppColors.blackColor,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // ---------- Subtitle ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: CustomText(
                    textName: "new_password_subtitle".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    fontSize: 14,
                    textColor: AppColors.greyColor11,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 35),

                // ---------- Form Container ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- New Password ----------
                        _buildLabel(Icons.lock_outline, "new_password".tr),
                        const SizedBox(height: 10),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hint: "enter_new_password".tr,
                          isVisible: _isNewPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "please_enter_new_password".tr;
                            }
                            if (value.length < 6) {
                              return "password_min_6".tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // ---------- Confirm Password ----------
                        _buildLabel(Icons.lock_reset, "confirm_password".tr),
                        const SizedBox(height: 10),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: "reenter_new_password".tr,
                          isVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "please_confirm_password".tr;
                            }
                            if (value != _newPasswordController.text) {
                              return "passwords_do_not_match".tr;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ---------- Reset Password Button ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // ✅ Condition 1: new password must not be empty
                        if (_newPasswordController.text.trim().isEmpty) {
                          Get.snackbar(
                            "required".tr,
                            "please_enter_new_password".tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // ✅ Condition 2: min length
                        if (_newPasswordController.text.length < 6) {
                          Get.snackbar(
                            "weak_password".tr,
                            "password_min_6".tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // ✅ Condition 3: confirm must not be empty
                        if (_confirmPasswordController.text.trim().isEmpty) {
                          Get.snackbar(
                            "required".tr,
                            "please_confirm_password".tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // ✅ Condition 4: both must match
                        if (_newPasswordController.text !=
                            _confirmPasswordController.text) {
                          Get.snackbar(
                            "mismatch".tr,
                            "passwords_do_not_match".tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // ✅ All checks passed — call the API
                        _authservice.userverifypassword(
                          email: widget.emailId,
                          newPassword: _newPasswordController.text,
                          confirmPassword: _confirmPasswordController.text,
                        );
                        // Get.to(LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            textName: "reset_password".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: AppColors.whiteColor,
                            fontSize: 14,
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Helper: Field Label ----------
  Widget _buildLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        CustomText(
          textName: text,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
          fontSize: 13,
        ),
      ],
    );
  }

  // ---------- Helper: Password Field ----------
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.grey.shade500,
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade500,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
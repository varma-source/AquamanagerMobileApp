import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_images.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/services/authService.dart';

class EmailPassword extends StatefulWidget {
  const EmailPassword({super.key});

  @override
  State<EmailPassword> createState() => _EmailPasswordState();
}

class _EmailPasswordState extends State<EmailPassword> {
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  final _authservice = Get.find<Authservice>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // ---------- Back Button ----------
                Row(
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
                  ],
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
                const SizedBox(height: 30),

                // ---------- Title ----------
                CustomText(
                  textName: "forgot_password_q".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  fontSize: 24,
                  textColor: AppColors.blackColor,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // ---------- Subtitle ----------
                CustomText(
                  textName: "forgot_password_subtitle".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  fontSize: 14,
                  textColor: AppColors.greyColor11,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 35),

                // ---------- Input Container ----------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          CustomText(
                            textName: "email".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: AppColors.blackColor,
                            fontSize: 13,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Input Field
                      TextFormField(
                        controller: _inputController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade900,
                        ),
                        decoration: InputDecoration(
                          hintText: "email_phone_hint".tr,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.alternate_email,
                            color: Colors.grey.shade500,
                            size: 22,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "please_enter_email_phone".tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ---------- Continue Button ----------
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ Condition: only proceed if email/phone is not empty
                      if (_inputController.text.trim().isEmpty) {
                        Get.snackbar(
                          "required".tr,
                          "please_enter_email_phone".tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primaryColor,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      _authservice.useremailverify(
                        email: _inputController.text.trim(),
                      );
                      // Get.to(OtpPassword());
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
                          textName: "continue_btn".tr,
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

                const SizedBox(height: 24),

                // ---------- Back to Login ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      textName: "remember_password".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: CustomText(
                        textName: "login".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: AppColors.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
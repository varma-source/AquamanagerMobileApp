import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/services/authService.dart';

class OtpPassword extends StatefulWidget {
  final String emailId;
  const OtpPassword({super.key, required this.emailId});

  @override
  State<OtpPassword> createState() => _OtpPasswordState();
}

class _OtpPasswordState extends State<OtpPassword> {
  String otpData = "";
  int secondsRemaining = 120; // 2 minutes
  Timer? timer;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    secondsRemaining = 120;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void onResendTap() {
    if (secondsRemaining == 0 && !isResending) {
      setState(() {
        isResending = true;
      });
      // Simulate resend (UI only)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isResending = false;
            startTimer();
          });
        }
      });
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  final _authservice = Get.find<Authservice>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: CustomText(
          textName: "verify_otp".tr,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
          fontSize: 15,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // ---------- Title ----------
            CustomText(
              textName: "enter_verification_code".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: AppColors.blackColor,
              fontSize: 18,
            ),
            const SizedBox(height: 8),

            // ---------- Subtitle ----------
            CustomText(
              textName: "enter_code_sent_email".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.medium,
              textColor: AppColors.greyColor1,
              fontSize: 13,
            ),
            const SizedBox(height: 4),

            // ---------- Phone Number ----------
            CustomText(
              textName: widget.emailId,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: AppColors.blackColor,
              fontSize: 13,
            ),
            const SizedBox(height: 30),

            // ---------- 6-Digit OTP Field ----------
            PinCodeTextField(
              appContext: context,
              length: 4,
              keyboardType: TextInputType.number,
              cursorColor: AppColors.primaryColor,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
                fieldHeight: 60,
                fieldWidth: 55,
                activeColor: AppColors.primaryColor,
                inactiveColor: Colors.grey.shade300,
                selectedColor: AppColors.primaryColor,
                selectedFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                activeFillColor: Colors.white,
                borderWidth: 2,
              ),
              animationType: AnimationType.fade,
              animationDuration: const Duration(milliseconds: 200),
              enableActiveFill: true,
              onChanged: (value) {
                otpData = value;
              },
              onCompleted: (value) {
                otpData = value;
              },
              beforeTextPaste: (text) {
                return true;
              },
            ),
            const SizedBox(height: 20),

            // ---------- Resend Row ----------
            Row(
              children: [
                CustomText(
                  textName: "didnt_receive_code".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: AppColors.blackColor,
                  fontSize: 13,
                ),
                GestureDetector(
                  onTap:
                      (secondsRemaining == 0 && !isResending)
                          ? onResendTap
                          : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Text(
                          isResending ? "sending".tr : "resend".tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                (secondsRemaining == 0 && !isResending)
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          secondsRemaining == 0
                              ? ""
                              : formatTime(secondsRemaining),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ---------- Continue Button ----------
            InkWell(
              onTap: () {
                _authservice.userverifyemailotp(
                  email: widget.emailId,
                  otp: otpData,
                );
                // Get.to(ResetPasswordScreen());
              },
              child: Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primaryColor,
                ),
                child: Center(
                  child: CustomText(
                    textName: "continue_btn".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: AppColors.whiteColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
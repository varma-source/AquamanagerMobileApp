import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_mediaquery.dart';
import 'package:superapp/constants/app_sizedbox.dart';
import 'package:superapp/constants/app_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;
  final bool isBackButtonVisible;
  final bool isWallet;
  final Color? backgroundColor; // Button background color
  final Gradient? gradient; // Gradient for the button background
  CustomAppBar({
    super.key,
    this.backgroundColor,
    this.gradient, // New parameter for gradient
    required this.title,
    this.height = 50, // Default height if not provided
    this.isBackButtonVisible = true,
    this.isWallet = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.whiteColor,
      elevation: 4,
      shadowColor: AppColors.blackColor.withOpacity(0.4),
      leading: Row(
        children: [
          CustomSizedBoxWidth(width: 16),
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryColor.withOpacity(0.10),
              ),
              child: Icon(
                Icons.arrow_back,
                size: getProportionateScreenHeight(25),
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      title: CustomText(
        textName: title,
        fontSize: 14,
        fontFamily: FontFamily.montserrat,
        fontWeightType: FontWeightType.medium,
        textColor: AppColors.blackColor,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

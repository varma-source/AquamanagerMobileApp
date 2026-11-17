import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _profileController = Get.find<ProfileController>();

  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ),
        title: CustomText(
          textName: "help_support".tr,
          fontSize: 18,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final data = _profileController.profileDataResponce.value.data;

        if (data == null) {
          return _buildShimmer();
        }

        final faqs = data.faqs ?? [];
        final aboutUs = data.aboutUs;

        final String supportEmail =
            (aboutUs?.email != null && aboutUs!.email!.isNotEmpty)
                ? aboutUs.email!
                : "support@aqua.com";

        final String supportPhone =
            (aboutUs?.phone != null && aboutUs!.phone!.isNotEmpty)
                ? aboutUs.phone!
                : "+91 98765 43210";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSupportHeader(),
              const SizedBox(height: 20),
              _buildQuickContact(email: supportEmail, phone: supportPhone),
              const SizedBox(height: 24),
              CustomText(
                textName: "frequently_asked_questions".tr,
                fontSize: 18,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.semiBold,
                textColor: AppColors.blackColor,
              ),
              const SizedBox(height: 12),
              if (faqs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CustomText(
                      textName: "no_faqs_available".tr,
                      fontSize: 13,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    return _buildFAQItem(
                      index: index,
                      question: faqs[index].question ?? "",
                      answer: faqs[index].answer ?? "",
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // ---------- SHIMMER LOADING ----------
  // ============================================================
  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 220,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ---------- SUPPORT HEADER ----------
  // ============================================================
  Widget _buildSupportHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            const Color(0xFF087FC1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textName: "how_can_we_help".tr,
                  fontSize: 18,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 4),
                CustomText(
                  textName: "here_to_assist".tr,
                  fontSize: 13,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.white.withOpacity(0.85),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ---------- QUICK CONTACT ----------
  // ============================================================
  Widget _buildQuickContact({
    required String email,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "quick_contact".tr,
            fontSize: 15,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: AppColors.blackColor,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  icon: Icons.email_outlined,
                  label: "email".tr,
                  value: email,
                  onTap: () {
                    Get.snackbar(
                      "email_support".tr,
                      email,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColors.primaryColor,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactCard(
                  icon: Icons.phone_outlined,
                  label: "call_us".tr,
                  value: phone,
                  onTap: () {
                    Get.snackbar(
                      "call_support".tr,
                      "${"call_us_at".tr} $phone",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColors.primaryColor,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 20),
            ),
            const SizedBox(height: 6),
            CustomText(
              textName: label,
              fontSize: 11,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.medium,
              textColor: Colors.grey[600]!,
            ),
            CustomText(
              textName: value.length > 15
                  ? '${value.substring(0, 15)}...'
                  : value,
              fontSize: 10,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: AppColors.primaryColor,
              maxLines: 1,
              overFlow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ---------- FAQ ITEM ----------
  // ============================================================
  Widget _buildFAQItem({
    required int index,
    required String question,
    required String answer,
  }) {
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? -1 : index;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomText(
                        textName: question,
                        fontSize: 13,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.medium,
                        textColor: AppColors.blackColor,
                        maxLines: 2,
                        overFlow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[200], height: 1),
                  const SizedBox(height: 12),
                  CustomText(
                    textName: answer,
                    fontSize: 12,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey[600]!,
                    textAlign: TextAlign.left,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
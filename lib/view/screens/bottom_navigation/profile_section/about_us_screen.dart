import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/profile_model.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';

class PolicysScreen extends StatefulWidget {
  const PolicysScreen({super.key});

  @override
  State<PolicysScreen> createState() => _PolicysScreenState();
}

class _PolicysScreenState extends State<PolicysScreen> {
  int _selectedTab = 0; // 0: About Us, 1: Terms

  final _profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          textName: "about_us".tr,
          fontSize: 18,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabs(),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final data = _profileController.profileDataResponce.value.data;

              if (data == null) {
                return _buildShimmer();
              }

              return _selectedTab == 0
                  ? _buildAboutUsContent(data)
                  : _buildTermsContent(data);
            }),
          ),
        ],
      ),
    );
  }

  // ---------- Tabs ----------
  Widget _buildTabs() {
    final List<String> tabs = ['about_us'.tr, 'terms'.tr];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomText(
                    textName: tabs[index],
                    fontSize: 12,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: isSelected
                        ? FontWeightType.semiBold
                        : FontWeightType.medium,
                    textColor:
                        isSelected ? Colors.white : Colors.grey[600]!,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // ---------- ABOUT US CONTENT ----------
  // ============================================================
  Widget _buildAboutUsContent(Data data) {
    final String aboutUsText = data.policy?.aboutus?.isNotEmpty == true
        ? data.policy!.aboutus!
        : "no_about_us_info".tr;

    final String email = data.aboutUs?.email?.isNotEmpty == true
        ? data.aboutUs!.email!
        : "support@aquaapp.com";

    final String phone = data.aboutUs?.phone?.isNotEmpty == true
        ? data.aboutUs!.phone!
        : "+91 98765 43210";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.water_drop_outlined,
                  color: AppColors.primaryColor,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: CustomText(
                textName: "aqua_app".tr,
                fontSize: 20,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: CustomText(
                textName: "version_1_0_0".tr,
                fontSize: 12,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey[500]!,
              ),
            ),
            const SizedBox(height: 24),

            // About Us content from API
            _buildSectionTitle("about_us".tr),
            _buildSectionContent(aboutUsText),
            const SizedBox(height: 20),

            // Contact Card
            _buildSectionTitle("contact_us".tr),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _contactRow(Icons.mail_outline, email),
                  const SizedBox(height: 10),
                  _contactRow(Icons.phone_outlined, phone),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomText(
                      textName: "built_with_care".tr,
                      fontSize: 11,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.medium,
                      textColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ---------- TERMS & CONDITIONS CONTENT ----------
  // ============================================================
  Widget _buildTermsContent(Data data) {
    final String terms =
        data.policy?.termsAndCondition?.isNotEmpty == true
            ? data.policy!.termsAndCondition!
            : "no_terms_available".tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("terms_conditions".tr),
            const SizedBox(height: 4),
            CustomText(
              textName: "last_updated_sep_2026".tr,
              fontSize: 11,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey[500]!,
            ),
            const SizedBox(height: 14),

            // Terms content from API
            CustomText(
              textName: terms,
              fontSize: 13,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey[700]!,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomText(
                textName: "last_updated_sep_2026".tr,
                fontSize: 11,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.medium,
                textColor: Colors.grey[500]!,
              ),
            ),
          ],
        ),
      ),
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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                5,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Helpers ----------
  Widget _buildSectionTitle(String title) {
    return CustomText(
      textName: title,
      fontSize: 15,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.semiBold,
      textColor: AppColors.blackColor,
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: CustomText(
        textName: content,
        fontSize: 13,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.regular,
        textColor: Colors.grey[600]!,
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: CustomText(
            textName: text,
            fontSize: 12,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey[700]!,
          ),
        ),
      ],
    );
  }
}
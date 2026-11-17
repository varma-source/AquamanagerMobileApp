import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/manager_section/manager_bottom_navigation/manager_staff_section/manager_add_staff_screen.dart';
import 'package:superapp/manager_section/manager_bottom_navigation/manager_staff_section/manager_edit_staff_screen.dart';
import 'package:superapp/model/staff_module/staff_manager_staff_model.dart';
import 'package:superapp/services/staff_module_service.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_manager_staff_controller.dart';

class ManagerStaffScreen extends StatefulWidget {
  const ManagerStaffScreen({super.key});

  @override
  State<ManagerStaffScreen> createState() => _ManagerStaffScreenState();
}

class _ManagerStaffScreenState extends State<ManagerStaffScreen> {
  // 🎨 Colors matching the screenshot
  final Color _bgColor = const Color(0xFFF3F4F6);
  final Color _primaryDark = const Color(0xFF1E3A5F);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _textDark = const Color(0xFF1F2937);
  final Color _textGrey = const Color(0xFF6B7280);

  // Status colors
  final Color _activeGreenBg = const Color(0xFFD1FAE5);
  final Color _activeGreenText = const Color(0xFF059669);

  // ✅ Controller
  late final StaffManagerStaffController _staffController;

  @override
  void initState() {
    super.initState();

    // Register Controller safely
    if (Get.isRegistered<StaffManagerStaffController>()) {
      _staffController = Get.find<StaffManagerStaffController>();
    } else {
      _staffController = Get.put(
        StaffManagerStaffController(StaffModuleService()),
      );
    }

    // ✅ Force fetch the latest data every time the screen is opened
    _staffController.fetchstaffmanagerstaffdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox.shrink(),
        title: CustomText(
          textName: "staff_management".tr,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: _primaryDark,
          fontSize: 16,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1E3A5F), size: 24),
            onPressed: () {
              Get.to(() => const ManagerAddStaffScreen());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final response = _staffController.staffmanagerstaffDataResponce.value;
        final staffList = response.data;

        // Loading State
        if (staffList == null) {
          return _buildShimmerList();
        }

        // Empty State
        if (staffList.isEmpty) {
          return Center(
            child: CustomText(
              textName: "no_staff_added".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: _textGrey,
              fontSize: 14,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map through the staff list
              ...staffList.map((staff) => _buildStaffCard(staff)),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ INDIVIDUAL STAFF CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildStaffCard(Datum staff) {
    final name = staff.name ?? "Unknown";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
    final isActive = (staff.status?.toLowerCase() == "active");

    // Check if tanks are assigned
    final tanks = staff.tankName ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A5F),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomText(
                    textName: initial,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: CustomText(
                            textName: name,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.bold,
                            textColor: _textDark,
                            fontSize: 14,
                            maxLines: 1,
                            overFlow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Role Tag
                        if (staff.role != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomText(
                              textName: staff.role!.toUpperCase(),
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.medium,
                              textColor: Colors.blueGrey.shade700,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Status Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isActive ? _activeGreenBg : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomText(
                            textName:
                                isActive ? "active".tr : "inactive".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.medium,
                            textColor:
                                isActive
                                    ? _activeGreenText
                                    : Colors.red.shade700,
                            fontSize: 9,
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Get.to(() => ManagerEditStaffScreen(staff: staff));
                          },
                          child: Icon(
                            Icons.edit,
                            color: AppColors.primaryColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      textName: staff.email ?? "",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: _textGrey,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Assigned Tanks
          if (tanks.isEmpty)
            CustomText(
              textName: "no_tanks".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: _textGrey,
              fontSize: 12,
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  tanks
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomText(
                            textName: t,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.medium,
                            textColor: const Color(0xFF0369A1),
                            fontSize: 11,
                          ),
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ SHIMMER LOADING LIST
  // ═══════════════════════════════════════════════════════════
  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar Shimmer
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name & Email Shimmer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tanks Shimmer
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
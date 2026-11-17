import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/staff_module/staff_get_medicine_model.dart' as med_model;
import 'package:superapp/model/staff_module/staff_my_feed_model.dart' as feed_model;
import 'package:superapp/model/staff_module/staff_home_model.dart';
import 'package:superapp/services/staff_module_service.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_get_medicine_conntroller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_my_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_home_controller.dart';

class ManagerInventoryScreen extends StatefulWidget {
  const ManagerInventoryScreen({super.key});

  @override
  State<ManagerInventoryScreen> createState() =>
      _ManagerInventoryScreenState();
}

class _ManagerInventoryScreenState extends State<ManagerInventoryScreen> {
  // 🎨 Colors matching the screenshots
  final Color _bgColor = const Color(0xFFF3F4F6);
  final Color _primaryDark = const Color(0xFF1E3A5F);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _textDark = const Color(0xFF1F2937);
  final Color _textGrey = const Color(0xFF6B7280);
  final Color _warningRed = const Color(0xFFEF4444);
  final Color _warningBg = const Color(0xFFFEE2E2);
  final Color _greenText = const Color(0xFF059669);
  final Color _greenBg = const Color(0xFFD1FAE5);

  // ✅ Controllers
  late final StaffHomeController _homeController;
  late final StaffGetMedicineConntroller _medicineController;
  late final StaffMyFeedController _feedController;

  // State
  int _selectedTabIndex = 0; // 0 = Feed, 1 = Medicine
  String _selectedTankDropdown = "All Tanks";

  @override
  void initState() {
    super.initState();

    // Register Home Controller safely
    if (Get.isRegistered<StaffHomeController>()) {
      _homeController = Get.find<StaffHomeController>();
    } else {
      _homeController = Get.put(StaffHomeController(StaffModuleService()));
    }

    // Register Medicine Controller safely
    if (Get.isRegistered<StaffGetMedicineConntroller>()) {
      _medicineController = Get.find<StaffGetMedicineConntroller>();
    } else {
      _medicineController = Get.put(StaffGetMedicineConntroller(StaffModuleService()));
    }

    // Register Feed Controller safely
    if (Get.isRegistered<StaffMyFeedController>()) {
      _feedController = Get.find<StaffMyFeedController>();
    } else {
      _feedController = Get.put(StaffMyFeedController(StaffModuleService()));
    }
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
          textName: "inventory_overview".tr,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: _primaryDark,
          fontSize: 16,
        ),
      ),
      body: Obx(() {
        final homeResponse = _homeController.staffprofileDataResponce.value;
        final medResponse = _medicineController.staffgetmedicineDataResponce.value;
        final feedResponse = _feedController.staffmyfeedDataResponce.value;

        final tanks = homeResponse.data ?? [];
        final medicineLogs = medResponse.data ?? [];
        final feedLogs = feedResponse.data ?? [];

        // Loading state
        if (tanks.isEmpty && medicineLogs.isEmpty && feedLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Build a map to group Medicine logs by Tank Name
        Map<String, List<med_model.Datum>> groupedMedicine = {};
        for (var log in medicineLogs) {
          final tName = log.tankName ?? "Unknown Tank";
          if (!groupedMedicine.containsKey(tName)) {
            groupedMedicine[tName] = [];
          }
          groupedMedicine[tName]!.add(log);
        }

        // Build a map to group Feed logs by Tank Name
        Map<String, List<feed_model.Datum>> groupedFeed = {};
        for (var log in feedLogs) {
          final tName = log.tankName ?? "Unknown Tank";
          if (!groupedFeed.containsKey(tName)) {
            groupedFeed[tName] = [];
          }
          groupedFeed[tName]!.add(log);
        }

        // ALWAYS use the `tanks` list from the Home API to display cards
        // Compare against a localized "All Tanks" sentinel
        final allTanksLabel = "all_tanks".tr;
        final displayTanks = _selectedTankDropdown == allTanksLabel
            ? tanks
            : tanks.where((t) => t.tankName == _selectedTankDropdown).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- CUSTOM TAB TOGGLE ----------
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildTabItem("feed".tr, 0),
                    _buildTabItem("medicine".tr, 1),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---------- DROPDOWN ----------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTankDropdown,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    items: [
                      DropdownMenuItem(
                        value: "All Tanks",
                        child: Text("all_tanks".tr),
                      ),
                      ...tanks.map((tank) {
                        return DropdownMenuItem(
                          value: tank.tankName ?? "Unknown",
                          child: Text(tank.tankName ?? "Unknown"),
                        );
                      }).toList(),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTankDropdown = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---------- GRID VIEW ----------
              if (displayTanks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CustomText(
                      textName: "no_tanks_available".tr,
                      fontFamily: FontFamily.poppins,
                      textColor: _textGrey,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 160,
                  ),
                  itemCount: displayTanks.length,
                  itemBuilder: (context, index) {
                    final tank = displayTanks[index];
                    final tankName = tank.tankName ?? "Unnamed Tank";

                    if (_selectedTabIndex == 0) {
                      final feeds = groupedFeed[tankName] ?? [];
                      return _buildFeedCard(tankName, feeds);
                    } else {
                      final meds = groupedMedicine[tankName] ?? [];
                      return _buildMedicineCard(tankName, meds);
                    }
                  },
                ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // ---------- TAB HELPER ----------
  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: CustomText(
            textName: title,
            fontFamily: FontFamily.poppins,
            fontWeightType:
                isSelected ? FontWeightType.semiBold : FontWeightType.medium,
            textColor: isSelected ? _primaryDark : _textGrey,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ---------- FEED CARD ----------
  Widget _buildFeedCard(String tankName, List<feed_model.Datum> feeds) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: tankName,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: _textDark,
            fontSize: 13,
            maxLines: 1,
            overFlow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          if (feeds.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CustomText(
                textName: "no_feed_recorded".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: _textGrey,
                fontSize: 11,
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: feeds.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 12, color: Color(0xFFF3F4F6)),
                itemBuilder: (context, index) {
                  final item = feeds[index];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomText(
                          textName: item.feedName ?? "Unknown",
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: _textGrey,
                          fontSize: 10,
                          maxLines: 1,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _greenBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          textName: "${item.kg ?? '0'} kg",
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.medium,
                          textColor: _greenText,
                          fontSize: 9,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ---------- MEDICINE CARD ----------
  Widget _buildMedicineCard(String tankName, List<med_model.Datum> meds) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: tankName,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: _textDark,
            fontSize: 13,
            maxLines: 1,
            overFlow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          if (meds.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CustomText(
                textName: "no_medicine_recorded".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: _textGrey,
                fontSize: 11,
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meds.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 12, color: Color(0xFFF3F4F6)),
                itemBuilder: (context, index) {
                  final item = meds[index];
                  final qty = double.tryParse(item.quanTityUsed ?? "0") ?? 0;
                  final isLowStock = qty < 10;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomText(
                          textName: item.medicineName ?? "Unknown",
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: _textGrey,
                          fontSize: 10,
                          maxLines: 1,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isLowStock ? _warningBg : _greenBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          textName:
                              "${item.quanTityUsed ?? '0'} ${"units".tr}",
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.medium,
                          textColor: isLowStock ? _warningRed : _greenText,
                          fontSize: 9,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/medicine_data_model.dart'
    as medicine;
import 'package:superapp/model/tank/all_tank_model.dart';
import 'package:superapp/model/tank/get_form_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/tank_overview/tank_overview.dart';
import 'package:superapp/view/screens/bottom_navigation/intentory/parties_screen.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_controller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_all_tank_conteoller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_form_controller.dart';

class InventoryOverviewScreen extends StatefulWidget {
  const InventoryOverviewScreen({super.key});

  @override
  State<InventoryOverviewScreen> createState() =>
      _InventoryOverviewScreenState();
}

class _InventoryOverviewScreenState extends State<InventoryOverviewScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);
  final Color _green = const Color(0xFF1B9C4A);

  // Selected toggle: Feed or Medicine (internal values stay English)
  String _selectedTab = "Feed";

  // ✅ Selected tank filter (internal value stays "All Tanks")
  String _selectedTank = "All Tanks";

  // ✅ Selected farm
  Datum? _selectedFarm;

  // Controllers
  late final GetAllTankConteoller _tankController;
  late final GetFormController _getFormController;
  late final MedicineController _medicineController;

  // ✅ Per-tank medicine cache
  final Map<String, List<medicine.Datum>> _medicineCache = {};
  final RxBool _isLoadingMedicine = false.obs;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<GetAllTankConteoller>()) {
      _tankController = Get.find<GetAllTankConteoller>();
    } else {
      _tankController = Get.put(GetAllTankConteoller(TankService()));
    }

    if (Get.isRegistered<GetFormController>()) {
      _getFormController = Get.find<GetFormController>();
    } else {
      _getFormController = Get.put(GetFormController(TankService()));
    }

    if (Get.isRegistered<MedicineController>()) {
      _medicineController = Get.find<MedicineController>();
    } else {
      _medicineController = Get.put(MedicineController(OverviewService()));
    }

    if (_getFormController.getformDataResponce.value.data == null) {
      _getFormController.fetchgetformdata();
    }

    ever(_getFormController.getformDataResponce, (Getformdata data) {
      final farms = data.data ?? [];

      if (farms.isNotEmpty && _selectedFarm == null) {
        final firstFarm = farms.first;
        setState(() => _selectedFarm = firstFarm);

        if (firstFarm.id != null && firstFarm.id!.isNotEmpty) {
          _tankController.fetchgetanksdata(farmId: firstFarm.id!);
        }
      }
    });

    final existingFarms =
        _getFormController.getformDataResponce.value.data ?? [];
    if (existingFarms.isNotEmpty && _selectedFarm == null) {
      final firstFarm = existingFarms.first;
      _selectedFarm = firstFarm;
      if (firstFarm.id != null && firstFarm.id!.isNotEmpty) {
        _tankController.fetchgetanksdata(farmId: firstFarm.id!);
      }
    }

    ever(_tankController.tanksDataResponce, (_) async {
      final tanks = _tankController.tanksDataResponce.value.tanks ?? [];
      final farmId = _selectedFarm?.id ?? "";
      if (farmId.isEmpty) return;

      for (final tank in tanks) {
        final tid = tank.id ?? "";
        if (tid.isEmpty) continue;
        await _fetchMedicineForTank(tid, farmId);
      }
    });
  }

  Future<void> _fetchMedicineForTank(String tankId, String farmId) async {
    if (_medicineCache.containsKey(tankId)) return;

    _isLoadingMedicine.value = true;
    try {
      _medicineController.fetchmedicinedata(
        tankId: tankId,
        farmId: farmId,
      );

      final list = await _waitForMedicineResponse(tankId);
      _medicineCache[tankId] = list;
    } catch (e) {
      debugPrint("Medicine fetch error for tank $tankId: $e");
      _medicineCache[tankId] = [];
    } finally {
      _isLoadingMedicine.value = false;
    }
  }

  Future<List<medicine.Datum>> _waitForMedicineResponse(
    String tankId,
  ) async {
    final deadline = DateTime.now().add(const Duration(seconds: 10));

    while (DateTime.now().isBefore(deadline)) {
      final data = _medicineController.medicineDataResponce.value.data;

      if (data != null) {
        if (data.isEmpty) return const [];

        final belongs = data.any((m) => (m.tankId ?? "") == tankId);
        if (belongs) {
          return data
              .where((m) => (m.tankId ?? "") == tankId)
              .toList();
        }
      }

      await Future.delayed(const Duration(milliseconds: 120));
    }
    return const [];
  }

  double _medicineQtyForTank(String tankId) {
    final list = _medicineCache[tankId] ?? [];
    double qty = 0;
    for (final m in list) {
      qty += double.tryParse(m.quantityPurchased ?? "0") ?? 0;
    }
    return qty;
  }

  double _medicineAmountForTank(String tankId) {
    final list = _medicineCache[tankId] ?? [];
    double amt = 0;
    for (final m in list) {
      amt += double.tryParse(m.totalAmount ?? "0") ?? 0;
    }
    return amt;
  }

  List<String> _tankOptions() {
    final tanks = _tankController.tanksDataResponce.value.tanks ?? [];
    return ["All Tanks", ...tanks.map((t) => t.name ?? "Unnamed").toList()];
  }

  List<Tank> _filteredTanks() {
    final tanks = _tankController.tanksDataResponce.value.tanks ?? [];
    if (_selectedTank == "All Tanks") return tanks;
    return tanks.where((t) => (t.name ?? "") == _selectedTank).toList();
  }

  // 🌐 Translate tab label for display
  String _tabLabel(String key) {
    return key == "Feed" ? "feed".tr : "medicine".tr;
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
                  const SizedBox(width: 28),
                  const Spacer(),
                  CustomText(
                    textName: "inventory_overview".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 15,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // ---------- Body ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Parties Row ----------
                    InkWell(
                      onTap: () => Get.to(PartiesScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: _primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomText(
                                textName: "parties_row_title".tr,
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.medium,
                                textColor: AppColors.blackColor,
                                fontSize: 13,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ---------- Feed / Medicine Toggle ----------
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _buildToggleItem("Feed"),
                          _buildToggleItem("Medicine"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ---------- Farm Dropdown ----------
                    _buildLabel("farm_name".tr),
                    const SizedBox(height: 6),
                    _buildFarmDropdown(),
                    const SizedBox(height: 14),

                    // ---------- Tank Dropdown ----------
                    _buildLabel("tank".tr),
                    const SizedBox(height: 6),
                    Obx(() {
                      final options = _tankOptions();
                      final safeValue =
                          options.contains(_selectedTank)
                              ? _selectedTank
                              : "All Tanks";

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: safeValue,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade700,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            items:
                                options.map((t) {
                                  return DropdownMenuItem<String>(
                                    value: t,
                                    child: CustomText(
                                      textName: t == "All Tanks"
                                          ? "all_tanks".tr
                                          : t,
                                      fontFamily: FontFamily.poppins,
                                      fontWeightType: FontWeightType.regular,
                                      textColor: AppColors.blackColor,
                                      fontSize: 13,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedTank = v);
                              }
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),

                    // ---------- Tank Cards Grid ----------
                    Obx(() {
                      final tanks =
                          _tankController.tanksDataResponce.value.tanks;

                      if (tanks == null) {
                        return _buildGridShimmer();
                      }

                      final filtered = _filteredTanks();

                      if (filtered.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 20,
                          ),
                          child: Center(
                            child: CustomText(
                              textName: "no_tanks_found".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.35,
                            ),
                        itemBuilder: (context, index) {
                          return _buildTankCard(filtered[index]);
                        },
                      );
                    }),
                    const SizedBox(height: 16),

                    // ---------- EXPORT BUTTONS ----------
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareCsv,
                            icon: Icon(
                              Icons.share_outlined,
                              size: 16,
                              color: _primary,
                            ),
                            label: CustomText(
                              textName: "share_csv".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.semiBold,
                              textColor: _primary,
                              fontSize: 12,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _downloadCsv,
                            icon: Icon(
                              Icons.file_download_outlined,
                              size: 16,
                              color: _primary,
                            ),
                            label: CustomText(
                              textName: "download_csv".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.semiBold,
                              textColor: _primary,
                              fontSize: 12,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _primary.withOpacity(0.4),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: _primary.withOpacity(0.05),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.semiBold,
      textColor: Colors.grey.shade700,
      fontSize: 11,
    );
  }

  Widget _buildFarmDropdown() {
    return Obx(() {
      final response = _getFormController.getformDataResponce.value;

      if (response.data == null || response.data!.isEmpty) {
        final isLoading = response.success == null;

        if (isLoading) {
          return Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: CustomText(
              textName: "no_farms_available".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        );
      }

      final farmList = response.data!;

      final bool isValid =
          _selectedFarm != null &&
          farmList.any((f) => f.id == _selectedFarm!.id);
      final Datum safeValue = isValid ? _selectedFarm! : farmList.first;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Datum>(
            value: safeValue,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade700,
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items:
                farmList.map((farm) {
                  return DropdownMenuItem<Datum>(
                    value: farm,
                    child: CustomText(
                      textName: farm.farmName ?? "Unnamed Farm",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: AppColors.blackColor,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
            onChanged: (Datum? value) {
              if (value == null) return;

              setState(() {
                _selectedFarm = value;
                _selectedTank = "All Tanks";
                _medicineCache.clear();
              });

              if (value.id != null && value.id!.isNotEmpty) {
                _tankController.fetchgetanksdata(farmId: value.id!);
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildToggleItem(String key) {
    final isSelected = _selectedTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: CustomText(
              textName: _tabLabel(key),
              fontFamily: FontFamily.poppins,
              fontWeightType:
                  isSelected ? FontWeightType.semiBold : FontWeightType.regular,
              textColor:
                  isSelected ? AppColors.blackColor : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTankCard(Tank tank) {
    final String tid = tank.id ?? "";

    final feedQty = tank.purchaseSummary?.totalQuantityPurchased ?? 0;
    final feedAmount = tank.purchaseSummary?.totalPurchaseAmount ?? 0;

    final medQty = _medicineQtyForTank(tid);
    final medAmount = _medicineAmountForTank(tid);

    final bool isFeed = _selectedTab == "Feed";

    final double qty = isFeed ? feedQty.toDouble() : medQty;
    final double amount = isFeed ? feedAmount.toDouble() : medAmount;
    final bool hasData = qty > 0 || amount > 0;

    final String label = isFeed ? "feed".tr : "medicine".tr;
    final String qtyText = isFeed ? "$qty kg" : "$qty ${"units".tr}";

    return InkWell(
      onTap: () {
        final farmId = _selectedFarm?.id ?? "";
        Get.to(
          TankOverviewScreen(
            tankId: tid,
            farmId: farmId,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    textName: tank.name ?? "Unnamed",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 13,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
              ],
            ),
            const Spacer(),

            if (!hasData)
              CustomText(
                textName:
                    isFeed ? "no_feed_recorded".tr : "no_medicine_recorded".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade500,
                fontSize: 11,
              )
            else ...[
              CustomText(
                textName: label,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.medium,
                textColor: AppColors.blackColor,
                fontSize: 11,
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  CustomText(
                    textName: "₹${amount.toStringAsFixed(0)}",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      textName: qtyText,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.medium,
                      textColor: _green,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 70,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════
  // EXPORT — DATA BUILDERS
  // ═══════════════════════════════════════════════════
  List<_InvRow> _buildInventoryRows() {
    final rows = <_InvRow>[];
    final tanks = _filteredTanks();

    for (final tank in tanks) {
      final tid = tank.id ?? "";
      final tname = tank.name ?? "Unnamed";

      final feedQty =
          (tank.purchaseSummary?.totalQuantityPurchased ?? 0).toDouble();
      final feedAmt =
          (tank.purchaseSummary?.totalPurchaseAmount ?? 0).toDouble();
      if (feedQty > 0 || feedAmt > 0) {
        rows.add(_InvRow(
          tankName: tname,
          type: "Feed",
          itemName: "Feed (aggregate)",
          quantity: feedQty,
          amount: feedAmt,
        ));
      }

      final meds = _medicineCache[tid] ?? [];
      for (final m in meds) {
        rows.add(_InvRow(
          tankName: tname,
          type: "Medicine",
          itemName: m.medicineName ?? "Medicine",
          quantity: double.tryParse(m.quantityPurchased ?? "0") ?? 0,
          amount: double.tryParse(m.totalAmount ?? "0") ?? 0,
        ));
      }
    }
    return rows;
  }

  _InvExportData _getExportData() {
    final rows = _buildInventoryRows();
    double feedQty = 0, feedAmt = 0, medQty = 0, medAmt = 0;
    for (final r in rows) {
      if (r.type == "Feed") {
        feedQty += r.quantity;
        feedAmt += r.amount;
      } else {
        medQty += r.quantity;
        medAmt += r.amount;
      }
    }
    return _InvExportData(
      rows: rows,
      totalFeedQty: feedQty,
      totalFeedAmount: feedAmt,
      totalMedicineQty: medQty,
      totalMedicineAmount: medAmt,
    );
  }

  // ═══════════════════════════════════════════════════
  // EXPORT — CSV STRING (uses translated headers)
  // ═══════════════════════════════════════════════════
  String? _buildCsvString() {
    final data = _getExportData();
    if (data.isEmpty) return null;

    final farmName = _selectedFarm?.farmName ?? "Unknown Farm";
    final generatedDate = DateFormat("M/d/yyyy").format(DateTime.now());
    final tankFilterDisplay = _selectedTank == "All Tanks"
        ? "all_tanks".tr
        : _selectedTank;

    final rows = <List<dynamic>>[];

    rows.add(["csv_farm".tr, farmName]);
    rows.add(["csv_tank_filter".tr, tankFilterDisplay]);
    rows.add(["csv_generated".tr, generatedDate]);
    rows.add(<dynamic>[]);

    rows.add(["csv_overall_summary".tr, "csv_value".tr]);
    rows.add(["csv_feed_quantity".tr, data.totalFeedQty.toStringAsFixed(2)]);
    rows.add(["csv_feed_value".tr, data.totalFeedAmount.toStringAsFixed(2)]);
    rows.add(
        ["csv_medicine_quantity".tr, data.totalMedicineQty.toStringAsFixed(2)]);
    rows.add(
        ["csv_medicine_value".tr, data.totalMedicineAmount.toStringAsFixed(2)]);
    rows.add(<dynamic>[]);

    rows.add([
      "csv_tank".tr,
      "csv_type".tr,
      "csv_item".tr,
      "csv_total_purchased".tr,
      "csv_total_amount".tr,
    ]);
    for (final r in data.rows) {
      rows.add([
        r.tankName,
        r.type == "Feed" ? "feed".tr : "medicine".tr,
        r.type == "Feed" ? "csv_feed_aggregate".tr : r.itemName,
        r.quantity.toStringAsFixed(2),
        r.amount.toStringAsFixed(2),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  // ═══════════════════════════════════════════════════
  // SNACK HELPERS
  // ═══════════════════════════════════════════════════
  void _showNoDataSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("no_data_to_export".tr)),
    );
  }

  void _showSuccessSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnack(String action, Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$action ${"failed".tr}: $e")),
    );
  }

  // ═══════════════════════════════════════════════════
  // SHARE CSV
  // ═══════════════════════════════════════════════════
  Future<void> _shareCsv() async {
    final csv = _buildCsvString();
    if (csv == null) {
      _showNoDataSnack();
      return;
    }
    try {
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/inventory.csv";
      final file = File(path);
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(path)], text: "inventory_csv".tr);
    } catch (e) {
      _showErrorSnack("csv_share".tr, e);
    }
  }

  // ═══════════════════════════════════════════════════
  // DOWNLOAD CSV
  // ═══════════════════════════════════════════════════
  Future<void> _downloadCsv() async {
    final csv = _buildCsvString();
    if (csv == null) {
      _showNoDataSnack();
      return;
    }

    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = "inventory_$timestamp.csv";

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(csv);
      debugPrint('══► CSV temp file: ${tempFile.path}');

      final params = SaveFileDialogParams(
        sourceFilePath: tempFile.path,
        fileName: fileName,
        mimeTypesFilter: const ['text/csv', 'text/comma-separated-values'],
      );
      final result = await FlutterFileDialog.saveFile(params: params);
      debugPrint('══► CSV save result: $result');

      if (result != null && result.isNotEmpty) {
        _showSuccessSnack("${"csv_saved".tr}: $fileName");
      }
    } catch (e) {
      debugPrint('══► CSV download error: $e');
      _showErrorSnack("csv_download".tr, e);
    }
  }
}

// ═══════════════════════════════════════════════════
// EXPORT DATA MODELS
// ═══════════════════════════════════════════════════
class _InvRow {
  final String tankName;
  final String type; // "Feed" or "Medicine"
  final String itemName;
  final double quantity;
  final double amount;

  _InvRow({
    required this.tankName,
    required this.type,
    required this.itemName,
    required this.quantity,
    required this.amount,
  });
}

class _InvExportData {
  final List<_InvRow> rows;
  final double totalFeedQty;
  final double totalFeedAmount;
  final double totalMedicineQty;
  final double totalMedicineAmount;

  _InvExportData({
    required this.rows,
    required this.totalFeedQty,
    required this.totalFeedAmount,
    required this.totalMedicineQty,
    required this.totalMedicineAmount,
  });

  bool get isEmpty => rows.isEmpty;
}
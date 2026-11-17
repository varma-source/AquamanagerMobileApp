import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_images.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/home_pandl_model.dart' hide Stock;
import 'package:superapp/model/over_view/home_tank_over_view_model.dart';
import 'package:superapp/model/tank/all_tank_model.dart';
import 'package:superapp/model/tank/get_form_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/add_tank.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/tank_overview/tank_overview.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/notification_screen.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_pandl_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_tank_over_view_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/harvest_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/log_feeding_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_useage_controller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_all_tank_conteoller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_form_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color _primary = const Color(0xFF087FC1);
  final Color _primaryDark = const Color(0xFF005A9C);
  final Color _accent = const Color(0xFF83C5BE);
  final Color _cream = const Color(0xFFEDF6F9);
  final Color _green = const Color(0xFF1B9C4A);
  final Color _red = const Color(0xFFE53935);

  final _tankController = Get.find<GetAllTankConteoller>();
  final _formController = Get.find<GetFormController>();

  Datum? _selectedFarm;
  bool _isInitialLoading = true;

  final Map<String, HomePandlController> _pandlControllers = {};
  final Map<String, HomeTankOverViewController> _overviewControllers = {};
  final Map<String, HarvestController> _harvestControllers = {};

  // ✅ ADDED — needed so Home's Net P&L matches P&L screen
  final Map<String, LogFeedingController> _logFeedingControllers = {};
  final Map<String, MedicineUseageController> _medicineUsageControllers = {};

  static const Duration _minLoadDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _isInitialLoading = true;
    final DateTime startedAt = DateTime.now();

    if (_formController.getformDataResponce.value.data == null) {
      _formController.fetchgetformdata();
    }

    ever(_formController.getformDataResponce, (data) {
      final farms = data.data ?? [];
      if (farms.isNotEmpty && _selectedFarm == null) {
        final firstFarm = farms.first;
        setState(() => _selectedFarm = firstFarm);
        if (firstFarm.id != null && firstFarm.id!.isNotEmpty) {
          _tankController.fetchgetanksdata(farmId: firstFarm.id!);
        }
      }
    });

    final existingFarms = _formController.getformDataResponce.value.data ?? [];
    if (existingFarms.isNotEmpty && _selectedFarm == null) {
      final firstFarm = existingFarms.first;
      _selectedFarm = firstFarm;
      if (firstFarm.id != null && firstFarm.id!.isNotEmpty) {
        _tankController.fetchgetanksdata(farmId: firstFarm.id!);
      }
    }

    ever(_tankController.tanksDataResponce, (data) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _setupTankControllers(data.tanks ?? []);
      });
    });

    _ensureMinLoading(startedAt);
  }

  void _setupTankControllers(List<Tank> tanks) {
    final farmId = _selectedFarm?.id ?? "";
    if (farmId.isEmpty) {
      if (mounted) setState(() => _controllersSetupAttempted = true);
      return;
    }

    for (final tank in tanks) {
      final tid = tank.id ?? "";
      if (tid.isEmpty) continue;

      if (!_pandlControllers.containsKey(tid)) {
        try {
          final c = Get.put(HomePandlController(OverviewService()), tag: tid);
          _pandlControllers[tid] = c;
          c.fetchgetpandldata(tankId: tid, farmId: farmId);
        } catch (e) {
          debugPrint("Get.put HomePandlController failed for $tid: $e");
        }
      }

      if (!_overviewControllers.containsKey(tid)) {
        try {
          final oc = Get.put(
            HomeTankOverViewController(OverviewService()),
            tag: "overview_$tid",
          );
          _overviewControllers[tid] = oc;
          oc.fetchhomeoverviewdata(tankId: tid, farmId: farmId);
        } catch (e) {
          debugPrint("Get.put HomeTankOverViewController failed for $tid: $e");
        }
      }

      if (!_harvestControllers.containsKey(tid)) {
        try {
          final hc = Get.put(
            HarvestController(OverviewService()),
            tag: "harvest_$tid",
          );
          _harvestControllers[tid] = hc;
          hc.fetchharvestdata(tankId: tid, farmId: farmId);
        } catch (e) {
          debugPrint("Get.put HarvestController failed for $tid: $e");
        }
      }

      // ✅ ADDED — inside the loop so `tid` is in scope
      if (!_logFeedingControllers.containsKey(tid)) {
        try {
          final lc = Get.put(
            LogFeedingController(OverviewService()),
            tag: "logfeed_$tid",
          );
          _logFeedingControllers[tid] = lc;
          // MUST match PandLWidget exactly: speciesId: ""
          lc.fetchlogfeedata(tankId: tid, farmId: farmId, speciesId: "");
        } catch (e) {
          debugPrint("LogFeedingController failed for $tid: $e");
        }
      }

      if (!_medicineUsageControllers.containsKey(tid)) {
        try {
          final mc = Get.put(
            MedicineUseageController(OverviewService()),
            tag: "medusage_$tid",
          );
          _medicineUsageControllers[tid] = mc;
          mc.fetchmedicineuseagedata(tankId: tid, farmId: farmId);
        } catch (e) {
          debugPrint("MedicineUseageController failed for $tid: $e");
        }
      }
    }

    if (mounted) setState(() => _controllersSetupAttempted = true);
  }

  Future<void> _ensureMinLoading(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minLoadDuration - elapsed;

    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  @override
  void dispose() {
    for (final entry in _pandlControllers.entries) {
      Get.delete<HomePandlController>(tag: entry.key, force: true);
    }
    for (final entry in _overviewControllers.entries) {
      Get.delete<HomeTankOverViewController>(
        tag: "overview_${entry.key}",
        force: true,
      );
    }
    for (final entry in _harvestControllers.entries) {
      Get.delete<HarvestController>(tag: "harvest_${entry.key}", force: true);
    }
    // ✅ ADDED
    for (final entry in _logFeedingControllers.entries) {
      Get.delete<LogFeedingController>(
        tag: "logfeed_${entry.key}",
        force: true,
      );
    }
    for (final entry in _medicineUsageControllers.entries) {
      Get.delete<MedicineUseageController>(
        tag: "medusage_${entry.key}",
        force: true,
      );
    }
    super.dispose();
  }

  List<Datum> get _farms =>
      _formController.getformDataResponce.value.data ?? [];

  String get _currentFarmName => _selectedFarm?.farmName ?? "";

  void _openTankOverview(Tank tank) {
    final tankId = tank.id ?? "";
    final farmId = _selectedFarm?.id ?? "";

    if (tankId.isEmpty) {
      Get.snackbar(
        "unavailable".tr,
        "tank_no_id_msg".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
      );
      return;
    }
    if (farmId.isEmpty) {
      Get.snackbar(
        "no_farm_selected".tr,
        "select_farm_first".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
      );
      return;
    }

    Get.to(() => TankOverviewScreen(tankId: tankId, farmId: farmId));
  }

  List<Stock> _currentCycleStocks(String tankId) {
    if (tankId.isEmpty) return <Stock>[];
    final overviewCtrl = _overviewControllers[tankId];
    if (overviewCtrl == null) return <Stock>[];

    final overviewList =
        overviewCtrl.hometankoverviewDataResponce.value.overview ?? [];
    if (overviewList.isEmpty) return <Stock>[];

    final allStocks = overviewList.first.stocks ?? [];

    final harvestCtrl = _harvestControllers[tankId];
    if (harvestCtrl == null) return allStocks;

    final harvests = harvestCtrl.harvestDataResponce.value.harvests ?? [];

    DateTime? latestFinal;
    for (final h in harvests) {
      if ((h.harvestType ?? "").toLowerCase() != "final") continue;

      final precise = h.logCreatedDate;
      final fallback = h.date;
      DateTime? candidate;
      if (precise != null) {
        candidate = precise;
      } else if (fallback != null) {
        candidate = DateTime(
          fallback.year,
          fallback.month,
          fallback.day,
          23,
          59,
          59,
        );
      }
      if (candidate == null) continue;

      if (latestFinal == null || candidate.isAfter(latestFinal)) {
        latestFinal = candidate;
      }
    }

    if (latestFinal == null) return allStocks;

    return allStocks.where((s) {
      DateTime? created = s.logCreatedDate;
      if (created == null) {
        final parsed = _parseDate(s.date);
        if (parsed != null) {
          created = DateTime(parsed.year, parsed.month, parsed.day);
        }
      }
      if (created == null) return false;
      return created.isAfter(latestFinal!);
    }).toList();
  }

  String _docFromTank(Tank tank) {
    final tid = tank.id ?? "";
    if (tid.isEmpty) return "--";
    return _docFromStocks(_currentCycleStocks(tid));
  }

  String _docFromStocks(List<Stock> stocks) {
    if (stocks.isEmpty) return "--";

    DateTime? earliest;
    for (final s in stocks) {
      final d = _parseDate(s.date);
      if (d == null) continue;
      if (earliest == null || d.isBefore(earliest)) earliest = d;
    }
    if (earliest == null) return "--";

    final start = DateTime(earliest.year, earliest.month, earliest.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final diffDays = today.difference(start).inDays;
    if (diffDays < 0) return "0";
    if (diffDays > 999) return "999+";
    return diffDays.toString();
  }

  DateTime? _parseDate(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    try {
      return DateTime.parse(v);
    } catch (_) {}
    final m = RegExp(
      r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})$',
    ).firstMatch(v);
    if (m != null) {
      final d = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      var y = int.parse(m.group(3)!);
      if (y < 100) y += 2000;
      return DateTime(y, mo, d);
    }
    return null;
  }

  bool _isTankHarvested(String tankId) {
    if (tankId.isEmpty) return false;
    final harvestCtrl = _harvestControllers[tankId];
    if (harvestCtrl == null) return false;

    final harvests = harvestCtrl.harvestDataResponce.value.harvests ?? [];

    bool hasFinal = false;
    for (final h in harvests) {
      if ((h.harvestType ?? "").toLowerCase() == "final") {
        hasFinal = true;
        break;
      }
    }
    if (!hasFinal) return false;

    return _currentCycleStocks(tankId).isEmpty;
  }

  bool _isTankDataReady(String tankId) {
    if (tankId.isEmpty) return false;
    final oc = _overviewControllers[tankId];
    if (oc == null) return false;
    if (oc.hometankoverviewDataResponce.value.overview == null) return false;

    final hc = _harvestControllers[tankId];
    if (hc == null) return false;
    if (hc.harvestDataResponce.value.harvests == null) return false;

    return true;
  }

  // ✅ REWRITTEN — exact same formula as PandLWidget
  double _netPnlForTank(String tankId, HomePandLdata resp) {
    if (resp.success == null) return 0;

    // 1. INCOME — from harvests
    double income = 0;
    for (final h in resp.harvests ?? []) {
      income += double.tryParse(h.totalAmount ?? "0") ?? 0;
    }

    // 2. AVG FEED COST PER KG
    double totalPurchasedKg = 0;
    double totalPurchasedAmount = 0;
    for (final p in resp.purchases ?? []) {
      totalPurchasedKg += double.tryParse(p.quantityPurchased ?? "0") ?? 0;
      totalPurchasedAmount += double.tryParse(p.totalAmount ?? "0") ?? 0;
    }
    final double avgFeedCostPerKg =
        totalPurchasedKg > 0 ? (totalPurchasedAmount / totalPurchasedKg) : 0.0;

    // 3. AVG MED COST PER UNIT
    double totalMedPurchasedQty = 0;
    double totalMedPurchasedAmount = 0;
    for (final m in resp.medicines ?? []) {
      totalMedPurchasedQty += double.tryParse(m.quantityPurchased ?? "0") ?? 0;
      totalMedPurchasedAmount += double.tryParse(m.totalAmount ?? "0") ?? 0;
    }
    final double avgMedCostPerUnit =
        totalMedPurchasedQty > 0
            ? (totalMedPurchasedAmount / totalMedPurchasedQty)
            : 0.0;

    // 4. FEED CONSUMED — from log feeding (same source as P&L)
    double feedConsumedKg = 0;
    final logCtrl = _logFeedingControllers[tankId];
    if (logCtrl != null) {
      for (final log in logCtrl.logfeedDataResponce.value.data ?? []) {
        feedConsumedKg += double.tryParse(log.kg ?? "0") ?? 0;
      }
    }
    final double feedConsumedAmount = feedConsumedKg * avgFeedCostPerKg;

    // 5. MEDICINE USED — from medicine usage logs (same source as P&L)
    double medicineUsedQty = 0;
    final medCtrl = _medicineUsageControllers[tankId];
    if (medCtrl != null) {
      for (final log in medCtrl.medicineuseDataResponce.value.data ?? []) {
        medicineUsedQty += double.tryParse(log.quanTityUsed ?? "0") ?? 0;
      }
    }
    final double medicineUsedAmount = medicineUsedQty * avgMedCostPerUnit;

    // 6. STOCKING
    double stocking = 0;
    for (final o in resp.overview ?? []) {
      for (final s in o.stocks ?? []) {
        stocking += double.tryParse(s.totalAmount ?? "0") ?? 0;
      }
    }

    // 7. LABOUR/SALARY + OTHER
    double labourSalaries = 0;
    double otherExpenses = 0;
    for (final e in resp.expenses ?? []) {
      final cat = (e.category ?? "").toLowerCase().trim();
      final amt = _expenseAmount(e);
      if (cat == "labour" || cat == "salary") {
        labourSalaries += amt;
      } else {
        otherExpenses += amt;
      }
    }

    final double expenses =
        feedConsumedAmount +
        medicineUsedAmount +
        stocking +
        labourSalaries +
        otherExpenses;

    final result = income - expenses;
    if (result.isNaN || result.isInfinite) return 0;
    return result;
  }

  // ✅ REWRITTEN — category-driven, same as PandLWidget
  double _expenseAmount(Expense e) {
    final cat = (e.category ?? "").toLowerCase().trim();

    switch (cat) {
      case "labour":
        return double.tryParse(e.labour?.totalLabourCost ?? "0") ?? 0;
      case "salary":
        return double.tryParse(e.salary?.totalSalaries ?? "0") ?? 0;
      case "tiffins":
      case "tiffinsmeals":
      case "tiffins/meals":
        return (e.tiffinsMeals?.amount ?? e.tiffinsMeals?.dieselAmount ?? 0)
            .toDouble();
      case "petrol":
        return (e.petrol?.amount ?? e.petrol?.dieselAmount ?? 0).toDouble();
      case "diesel":
        return (e.diesel?.amount ?? e.diesel?.dieselAmount ?? 0).toDouble();
      case "transport":
        return (e.transport?.amount ?? e.transport?.dieselAmount ?? 0)
            .toDouble();
      case "utilities":
        return (e.utilities?.amount ?? e.utilities?.dieselAmount ?? 0)
            .toDouble();
      case "other":
        return (e.other?.amount ?? e.other?.dieselAmount ?? 0).toDouble();
      case "electrical":
        return (e.electrical?.total ?? 0).toDouble();
      case "plumbing":
        return (e.plumbing?.total ?? 0).toDouble();
    }

    if (e.labour?.totalLabourCost != null) {
      return double.tryParse(e.labour!.totalLabourCost!) ?? 0;
    }
    if (e.salary?.totalSalaries != null) {
      return double.tryParse(e.salary!.totalSalaries!) ?? 0;
    }
    for (final d in [
      e.tiffinsMeals,
      e.petrol,
      e.diesel,
      e.transport,
      e.utilities,
      e.other,
    ]) {
      if (d != null) {
        if (d.amount != null) return d.amount!.toDouble();
        if (d.dieselAmount != null) return d.dieselAmount!.toDouble();
      }
    }
    if (e.electrical?.total != null) {
      return e.electrical!.total!.toDouble();
    }
    if (e.plumbing?.total != null) {
      return e.plumbing!.total!.toDouble();
    }
    return 0;
  }

  String _totalDocLabel(List<Tank> tanks) {
    if (tanks.isEmpty) return "--";

    final docList = <int>[];
    for (final t in tanks) {
      final docStr = _docFromTank(t);
      if (docStr == "--" || docStr == "999+") continue;
      final doc = int.tryParse(docStr);
      if (doc == null) continue;
      docList.add(doc);
    }

    if (docList.isEmpty) return "--";

    final lowest = docList.reduce((a, b) => a < b ? a : b);
    final highest = docList.reduce((a, b) => a > b ? a : b);

    return lowest == highest ? "$lowest" : "$lowest-$highest";
  }

  String _formatCurrency(num value) {
    final d = value.toDouble();
    if (d.isNaN || d.isInfinite) return "₹0";
    if (d.abs() > 1e15) return "₹—";

    final isNegative = d < 0;
    final abs = d.abs().round();
    final str = abs.toString();
    String formatted;
    if (str.length <= 3) {
      formatted = str;
    } else {
      final last3 = str.substring(str.length - 3);
      final rest = str.substring(0, str.length - 3);
      final restRev = rest.split('').reversed.join();
      final chunks = <String>[];
      for (int i = 0; i < restRev.length; i += 2) {
        chunks.add(
          restRev
              .substring(i, i + 2 > restRev.length ? restRev.length : i + 2)
              .split('')
              .reversed
              .join(),
        );
      }
      formatted = "${chunks.reversed.join(',')},$last3";
    }
    return "${isNegative ? '-' : ''}₹$formatted";
  }

  double _overallNetPnl(List<Tank> tanks) {
    double total = 0;
    for (final t in tanks) {
      final tid = t.id ?? "";
      if (tid.isEmpty) continue;
      final c = _pandlControllers[tid];
      if (c == null) continue;
      total += _netPnlForTank(tid, c.homepandlDataResponce.value);
    }
    return total;
  }

  bool _controllersSetupAttempted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              textName: "hello_wave".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: _openFarmListSheet,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  Flexible(
                                    child: CustomText(
                                      textName:
                                          _currentFarmName.isEmpty
                                              ? "select_farm".tr
                                              : "${_currentFarmName} ${"dashboard_suffix".tr}",
                                      fontFamily: FontFamily.poppins,
                                      fontWeightType: FontWeightType.bold,
                                      textColor: AppColors.blackColor,
                                      fontSize: 16,
                                      maxLines: 1,
                                      overFlow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                    color: _primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Get.to(() => NotificationsScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            color: _primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primary, _primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.35),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          textName:
                              _currentFarmName.isEmpty
                                  ? "farm_summary".tr
                                  : "${_currentFarmName} ${"summary_suffix".tr}",
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.medium,
                          textColor: Colors.white70,
                          fontSize: 12,
                        ),
                        const SizedBox(height: 22),

                        _isInitialLoading
                            ? _buildSummaryShimmer()
                            : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    final count =
                                        _tankController
                                            .tanksDataResponce
                                            .value
                                            .tanks
                                            ?.length ??
                                        0;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          textName: "active_tanks".tr,
                                          fontFamily: FontFamily.poppins,
                                          fontWeightType:
                                              FontWeightType.regular,
                                          textColor: Colors.white60,
                                          fontSize: 11,
                                        ),
                                        const SizedBox(height: 4),
                                        CustomText(
                                          textName: "$count",
                                          fontFamily: FontFamily.poppins,
                                          fontWeightType: FontWeightType.bold,
                                          textColor: Colors.white,
                                          fontSize: 34,
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                                Container(
                                  height: 50,
                                  width: 1,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                                Expanded(
                                  child: Obx(() {
                                    final tanks =
                                        _tankController
                                            .tanksDataResponce
                                            .value
                                            .tanks ??
                                        [];

                                    final netPnl = _overallNetPnl(tanks);

                                    return Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            textName: "net_pl".tr,
                                            fontFamily: FontFamily.poppins,
                                            fontWeightType:
                                                FontWeightType.regular,
                                            textColor: Colors.white60,
                                            fontSize: 11,
                                          ),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: CustomText(
                                              textName: _formatCurrency(netPnl),
                                              fontFamily: FontFamily.poppins,
                                              fontWeightType:
                                                  FontWeightType.bold,
                                              textColor:
                                                  netPnl >= 0
                                                      ? _accent
                                                      : const Color(0xFFFFB4B4),
                                              fontSize: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.waves_outlined,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Obx(() {
                                  final tanks =
                                      _tankController
                                          .tanksDataResponce
                                          .value
                                          .tanks;

                                  if (tanks == null) {
                                    return _buildDocPillShimmer();
                                  }

                                  bool allReady = true;
                                  for (final t in tanks) {
                                    final tid = t.id ?? "";
                                    final oc = _overviewControllers[tid];
                                    if (oc != null) {
                                      final _ =
                                          oc.hometankoverviewDataResponce.value;
                                    }
                                    final hc = _harvestControllers[tid];
                                    if (hc != null) {
                                      final _ = hc.harvestDataResponce.value;
                                    }
                                    if (!_isTankDataReady(tid)) {
                                      allReady = false;
                                    }
                                  }

                                  if (!allReady) {
                                    return _buildDocPillShimmer();
                                  }

                                  return CustomText(
                                    textName:
                                        "${"doc_label".tr} ${_totalDocLabel(tanks)} ${"across_tanks".tr}",
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.medium,
                                    textColor: Colors.white,
                                    fontSize: 11,
                                    maxLines: 1,
                                    overFlow: TextOverflow.ellipsis,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  Obx(() {
                    final count =
                        _tankController.tanksDataResponce.value.tanks?.length ??
                        0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          textName: "my_tanks".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.bold,
                          textColor: AppColors.blackColor,
                          fontSize: 17,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CustomText(
                            textName: "$count ${"tanks_suffix".tr}",
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: _primaryDark,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                final tanks = _tankController.tanksDataResponce.value.tanks;
                if (tanks == null) return _buildTankShimmer();
                if (tanks.isEmpty) return _buildEmptyState();
                if (!_controllersSetupAttempted) return _buildTankShimmer();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  itemCount: tanks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) => _buildTankCard(tanks[index]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.45),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Get.to(() => AddTankScreen()),
          backgroundColor: _primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSummaryShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.25),
      highlightColor: Colors.white.withOpacity(0.55),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 90,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocPillShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.25),
      highlightColor: Colors.white.withOpacity(0.55),
      child: Container(
        width: 140,
        height: 11,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  void _openFarmListSheet() {
    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      _FarmListSheet(
        primary: _primary,
        accent: _accent,
        farms: _farms,
        selectedFarm: _currentFarmName,
        onSelect: (farm) {
          setState(() {
            _selectedFarm = farm;
            _isInitialLoading = true;
            _controllersSetupAttempted = false;
          });
          Get.back();

          for (final entry in _pandlControllers.entries) {
            Get.delete<HomePandlController>(tag: entry.key, force: true);
          }
          _pandlControllers.clear();

          for (final entry in _overviewControllers.entries) {
            Get.delete<HomeTankOverViewController>(
              tag: "overview_${entry.key}",
              force: true,
            );
          }
          _overviewControllers.clear();

          for (final entry in _harvestControllers.entries) {
            Get.delete<HarvestController>(
              tag: "harvest_${entry.key}",
              force: true,
            );
          }
          _harvestControllers.clear();

          // ✅ ADDED
          for (final entry in _logFeedingControllers.entries) {
            Get.delete<LogFeedingController>(
              tag: "logfeed_${entry.key}",
              force: true,
            );
          }
          _logFeedingControllers.clear();

          for (final entry in _medicineUsageControllers.entries) {
            Get.delete<MedicineUseageController>(
              tag: "medusage_${entry.key}",
              force: true,
            );
          }
          _medicineUsageControllers.clear();

          final id = farm.id;
          if (id != null && id.isNotEmpty) {
            _tankController.fetchgetanksdata(farmId: id);
          }

          _ensureMinLoading(DateTime.now());
        },
        onAddFarm: () {
          Get.back();
          Future.delayed(const Duration(milliseconds: 200), () {
            _openAddFarmSheet();
          });
        },
      ),
    );
  }

  void _openAddFarmSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (ctx) {
        return _AddFarmSheet(
          primary: _primary,
          onSubmit: (name, location) {
            _formController.fetchgetformdata();
            Get.snackbar(
              "farm_added".tr,
              "$name • $location",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: _primary,
              colorText: Colors.white,
              margin: const EdgeInsets.all(14),
            );
          },
        );
      },
    );
  }

  Widget _buildTankCard(Tank tank) {
    final String typeLower = (tank.tankType ?? "").toLowerCase().trim();
    final String imagePath =
        typeLower == "prawn"
            ? AppImages.prawnimage
            : typeLower == "fish"
            ? AppImages.fishimage
            : AppImages.prawnimage;

    final double feedStock =
        (tank.purchaseSummary?.totalQuantityPurchased ?? 0).toDouble();

    final tid = tank.id ?? "";
    final pnlController = tid.isEmpty ? null : _pandlControllers[tid];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              onTap: () => _openTankOverview(tank),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary, _primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            textName: tank.name ?? "unnamed_tank".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.bold,
                            textColor: Colors.white,
                            fontSize: 16,
                            maxLines: 1,
                            overFlow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.water_drop_outlined,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: CustomText(
                                    textName:
                                        "${(tank.tankType ?? '').toUpperCase()} · ${tank.pondSize ?? 'N/A'} ${"acres_suffix".tr}",
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.medium,
                                    textColor: Colors.white,
                                    fontSize: 10,
                                    maxLines: 1,
                                    overFlow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildDocCircle(tank),
                    const SizedBox(width: 8),
                    _buildTypeImageCircle(imagePath),
                  ],
                ),
              ),
            ),

            InkWell(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              onTap: () => _openTankOverview(tank),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 6,
                            width: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B6B6B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: CustomText(
                              textName: tank.address ?? "no_address".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.semiBold,
                              textColor: const Color(0xFF6B6B6B),
                              fontSize: 10,
                              maxLines: 1,
                              overFlow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      height: 40,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Obx(() {
                              final _ = _tankController.tanksDataResponce.value;

                              final harvestCtrl = _harvestControllers[tid];

                              final bool isHarvested =
                                  harvestCtrl == null
                                      ? false
                                      : _isTankHarvested(tid);

                              final Color badgeBg =
                                  isHarvested
                                      ? Colors.grey.shade200
                                      : AppColors.greencolor.withOpacity(0.2);
                              final Color badgeTextColor =
                                  isHarvested
                                      ? Colors.grey.shade700
                                      : AppColors.greencolor;
                              final String label =
                                  isHarvested
                                      ? "harvested".tr
                                      : "active".tr;

                              return Container(
                                height: 26,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: badgeBg,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: CustomText(
                                    textName: label,
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.semiBold,
                                    textColor: badgeTextColor,
                                    fontSize: 10,
                                    maxLines: 1,
                                    overFlow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 32,
                            width: 1,
                            color: Colors.grey.shade200,
                          ),
                          const SizedBox(width: 8),

                          Expanded(
                            flex: 3,
                            child:
                                pnlController == null
                                    ? _buildInfo(
                                      label: "net_pl".tr,
                                      value: "—",
                                      valueColor: Colors.grey,
                                    )
                                    : Obx(() {
                                      // ✅ CHANGED: pass tid so we read the
                                      // tagged log feeding / medicine usage
                                      final pnl = _netPnlForTank(
                                        tid,
                                        pnlController
                                            .homepandlDataResponce
                                            .value,
                                      );
                                      return _buildInfo(
                                        label: "net_pl".tr,
                                        value: _formatCurrency(pnl),
                                        valueColor: pnl >= 0 ? _green : _red,
                                      );
                                    }),
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            color: Colors.grey.shade200,
                          ),
                          const SizedBox(width: 8),

                          Expanded(
                            flex: 3,
                            child: _buildInfo(
                              label: "feed_stock".tr,
                              value:
                                  (!feedStock.isFinite ||
                                          feedStock.abs() > 1e12)
                                      ? "—"
                                      : "${feedStock.toStringAsFixed(0)} kg",
                              valueColor: AppColors.blackColor,
                            ),
                          ),
                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primary.withOpacity(0.08),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 11,
                              color: _primary,
                            ),
                          ),
                        ],
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

  Widget _buildDocCircle(Tank tank) {
    final tid = tank.id ?? "";
    return SizedBox(
      height: 56,
      width: 56,
      child: ClipOval(
        child: Container(
          color: Colors.white.withOpacity(0.15),
          alignment: Alignment.center,
          child: Obx(() {
            final _ = _tankController.tanksDataResponce.value;

            final oc = _overviewControllers[tid];
            final hc = _harvestControllers[tid];

            if (oc == null || hc == null) {
              return _buildDocCircleShimmer();
            }

            final _ = oc.hometankoverviewDataResponce.value;
            final _ = hc.harvestDataResponce.value;

            if (!_isTankDataReady(tid)) {
              return _buildDocCircleShimmer();
            }

            final doc = _docFromTank(tank);
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CustomText(
                    textName: doc,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    fontSize: 14,
                    textColor: AppColors.whiteColor,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                ),
                CustomText(
                  textName: "DOC",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  fontSize: 10,
                  textColor: AppColors.whiteColor,
                  maxLines: 1,
                  overFlow: TextOverflow.ellipsis,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDocCircleShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.25),
      highlightColor: Colors.white.withOpacity(0.55),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 18,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeImageCircle(String imagePath) {
    return SizedBox(
      height: 56,
      width: 56,
      child: ClipOval(
        child: Container(
          color: Colors.white.withOpacity(0.15),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder:
                (_, __, ___) => Icon(
                  Icons.set_meal,
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 14,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CustomText(
              textName: label,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade600,
              fontSize: 10,
              maxLines: 1,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 18,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CustomText(
              textName: value,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.bold,
              textColor: valueColor,
              fontSize: 14,
              maxLines: 1,
              overFlow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTankShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withOpacity(0.1),
                border: Border.all(color: _primary.withOpacity(0.25), width: 2),
              ),
              child: Icon(Icons.water_drop_outlined, color: _primary, size: 42),
            ),
            const SizedBox(height: 24),
            CustomText(
              textName: "no_tanks_yet".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.bold,
              textColor: AppColors.blackColor,
              fontSize: 18,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              textName: "tap_plus_to_add".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade600,
              fontSize: 12,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmListSheet extends StatelessWidget {
  final Color primary;
  final Color accent;
  final List<Datum> farms;
  final String selectedFarm;
  final void Function(Datum farm) onSelect;
  final VoidCallback onAddFarm;

  const _FarmListSheet({
    required this.primary,
    required this.accent,
    required this.farms,
    required this.selectedFarm,
    required this.onSelect,
    required this.onAddFarm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.agriculture_outlined,
                    color: primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                CustomText(
                  textName: "my_farms".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 17,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomText(
                    textName: "${farms.length}",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: primary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            CustomText(
              textName: "select_farm_to_switch".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade600,
              fontSize: 11,
            ),
            const SizedBox(height: 18),

            if (farms.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.agriculture_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      CustomText(
                        textName: "no_farms_yet".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.medium,
                        textColor: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        textName: "tap_add_farm_below".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: farms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final farm = farms[index];
                    final farmName = farm.farmName ?? "unnamed_farm".tr;
                    final isSelected = farmName == selectedFarm;
                    return _FarmTile(
                      index: index + 1,
                      farmName: farmName,
                      location: farm.farmLocation ?? "",
                      isSelected: isSelected,
                      primary: primary,
                      onTap: () => onSelect(farm),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onAddFarm,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: CustomText(
                  textName: "add_farm".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: Colors.white,
                  fontSize: 14,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

class _FarmTile extends StatelessWidget {
  final int index;
  final String farmName;
  final String location;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  const _FarmTile({
    required this.index,
    required this.farmName,
    required this.location,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color:
              isSelected ? primary.withOpacity(0.08) : const Color(0xFFF7F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade200,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primary : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: CustomText(
                textName: "$index",
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    textName: farmName,
                    fontFamily: FontFamily.poppins,
                    fontWeightType:
                        isSelected
                            ? FontWeightType.bold
                            : FontWeightType.medium,
                    textColor: AppColors.blackColor,
                    fontSize: 14,
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                  ),
                  if (location.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CustomText(
                        textName: location,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade500,
                        fontSize: 10,
                        maxLines: 1,
                        overFlow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            if (isSelected)
              Icon(Icons.check_circle, color: primary, size: 20)
            else
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AddFarmSheet extends StatefulWidget {
  final Color primary;
  final void Function(String name, String location) onSubmit;

  const _AddFarmSheet({required this.primary, required this.onSubmit});

  @override
  State<_AddFarmSheet> createState() => _AddFarmSheetState();
}

class _AddFarmSheetState extends State<_AddFarmSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _farmNameCtrl = TextEditingController();
  final TextEditingController _farmLocationCtrl = TextEditingController();

  final _tankService = Get.find<TankService>();
  final ImagePicker _picker = ImagePicker();

  File? _pickedImage;

  double? _latitude;
  double? _longitude;
  bool _isFetchingLocation = false;

  String _selectedCurrency = "₹";
  final List<String> _currencies = ["₹", "\$", "€"];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _farmNameCtrl.dispose();
    _farmLocationCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          "location_disabled".tr,
          "enable_location_services".tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _isFetchingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "permission_denied".tr,
          "location_permission_required".tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _isFetchingLocation = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isFetchingLocation = false;
      });

      Get.snackbar(
        "location_fetched".tr,
        "Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: widget.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => _isFetchingLocation = false);
      Get.snackbar(
        "error".tr,
        "${"could_not_fetch_location".tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _buildLocationJson() {
    final lat = _latitude ?? 17.4483;
    final lng = _longitude ?? 78.4010;
    final d = 0.01;
    return '{"type":"Polygon","coordinates":[[[${lng - d},${lat + d}],[${lng + d},${lat + d}],[${lng + d},${lat - d}],[${lng - d},${lat - d}],[${lng - d},${lat + d}]]]}';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      await _tankService.useraddform(
        farmName: _farmNameCtrl.text.trim(),
        farmLocation: _farmLocationCtrl.text.trim(),
        currency: _selectedCurrency,
        location: _buildLocationJson(),
      );

      widget.onSubmit(_farmNameCtrl.text.trim(), _farmLocationCtrl.text.trim());

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint("Add farm error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: widget.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.agriculture_outlined,
                          color: widget.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      CustomText(
                        textName: "add_farm".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: AppColors.blackColor,
                        fontSize: 17,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _label("farm_name".tr),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _farmNameCtrl,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 13),
                    decoration: _inputDecoration(
                      hint: "farm_name_hint".tr,
                      icon: Icons.storefront_outlined,
                      primary: widget.primary,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "please_enter_farm_name".tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _label("farm_location".tr),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _farmLocationCtrl,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 13),
                    decoration: _inputDecoration(
                      hint: "farm_location_hint".tr,
                      icon: Icons.location_on_outlined,
                      primary: widget.primary,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "please_enter_farm_location".tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _label("current_location".tr),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _isFetchingLocation ? null : _fetchLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            size: 18,
                            color: widget.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child:
                                _isFetchingLocation
                                    ? CustomText(
                                      textName: "fetching_location".tr,
                                      fontFamily: FontFamily.poppins,
                                      fontWeightType: FontWeightType.regular,
                                      textColor: Colors.grey.shade600,
                                      fontSize: 12,
                                    )
                                    : CustomText(
                                      textName:
                                          (_latitude != null &&
                                                  _longitude != null)
                                              ? "Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}"
                                              : "tap_to_fetch_location".tr,
                                      fontFamily: FontFamily.poppins,
                                      fontWeightType: FontWeightType.regular,
                                      textColor:
                                          (_latitude != null)
                                              ? AppColors.blackColor
                                              : Colors.grey.shade500,
                                      fontSize: 12,
                                      maxLines: 1,
                                      overFlow: TextOverflow.ellipsis,
                                    ),
                          ),
                          if (_isFetchingLocation)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _label("currency".tr),
                  const SizedBox(height: 6),
                  _buildCurrencyToggle(),
                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: widget.primary.withOpacity(
                          0.5,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : CustomText(
                                textName: "add_farm".tr,
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.semiBold,
                                textColor: Colors.white,
                                fontSize: 14,
                              ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.primary,
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: CustomText(
                        textName: "cancel".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.semiBold,
                        textColor: Colors.grey.shade700,
                        fontSize: 14,
                      ),
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

  Widget _label(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.semiBold,
      textColor: Colors.grey.shade700,
      fontSize: 11,
    );
  }

  Widget _buildCurrencyToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children:
            _currencies.map((currency) {
              final isSelected = _selectedCurrency == currency;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCurrency = currency),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: CustomText(
                        textName: currency,
                        fontFamily: FontFamily.poppins,
                        fontWeightType:
                            isSelected
                                ? FontWeightType.bold
                                : FontWeightType.regular,
                        textColor:
                            isSelected
                                ? AppColors.blackColor
                                : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color primary,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
      filled: true,
      fillColor: const Color(0xFFF7F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
    );
  }
}
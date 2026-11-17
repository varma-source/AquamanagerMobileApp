import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_images.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/biomass_model.dart' as biomass;
import 'package:superapp/model/over_view/home_tank_over_view_model.dart';
import 'package:superapp/model/over_view/log_feeding_model.dart' as logfeeding;
import 'package:superapp/model/over_view/purchase_model.dart' as purchase;
import 'package:superapp/model/over_view/species_model.dart' as species;
import 'package:superapp/model/tank/all_tank_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/profileService.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/edit_tank_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/expenses/add_expense_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/feed_stock/add_purchase_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/feeding_fcr/feeding_fcr_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/harvest/record_harvest_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/medicine/add_medicine_purchase_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/medicine/log_medicineUsage_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/tank_overview/add_stock.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/tank_overview/edit_stock.dart';
import 'package:superapp/view_model/api_controllers/over_view/biomass_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_feeding_fcr_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_tank_over_view_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/log_feeding_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/purchase_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/species_controller.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';
import 'package:superapp/model/over_view/medicine_data_model.dart' as medicine;
import 'package:superapp/view_model/api_controllers/over_view/medicine_controller.dart';
import 'package:superapp/model/over_view/home_medicine_mosel.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_medicine_controller.dart';
import 'package:superapp/model/over_view/medicine_useage_model.dart'
    as medicineusage;
import 'package:superapp/view_model/api_controllers/over_view/medicine_useage_controller.dart';
import 'package:superapp/model/over_view/home_harvest_model.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_harvest_controller.dart';
import 'package:superapp/model/over_view/harvest_model.dart' as harvest;
import 'package:superapp/view_model/api_controllers/over_view/harvest_controller.dart';
import 'package:superapp/model/over_view/expence_model.dart';
import 'package:superapp/view_model/api_controllers/over_view/expence_controller.dart';
import 'package:superapp/view/screens/bottom_navigation/home_section/tank_overview/pandl_widget.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_pandl_controller.dart';

class TankOverviewScreen extends StatefulWidget {
  final String tankId;
  final String farmId;
  const TankOverviewScreen({
    super.key,
    required this.tankId,
    required this.farmId,
  });

  @override
  State<TankOverviewScreen> createState() => _TankOverviewScreenState();
}

class _TankOverviewScreenState extends State<TankOverviewScreen> {
  static const String _baseUrl = "http://72.60.126.155:7980";
  final Color _primary = const Color(0xFF087FC1);
  final Color _primaryDark = const Color(0xFF005A9C);
  final Color _accent = const Color(0xFF83C5BE);
  final Color _bg = const Color(0xFFF7F9FB);
  final Color _green = const Color(0xFF1B9C4A);
  final Color _red = const Color(0xFFE53935);
  final Color _chipBg = const Color(0xFFEFF3F5);

  int _selectedTab = 0;

  species.Datum? _selectedSpecies;

  final List<String> _tabs = [
    "Overview",
    "Feeding & FCR",
    "Feed Stock",
    "Medicine",
    "Expenses",
    "P&L",
    "Harvest",
  ];

  // 🌐 Tab label — display only
  String _tabLabel(String internal) {
    switch (internal) {
      case "Overview":
        return "tab_overview".tr;
      case "Feeding & FCR":
        return "tab_feeding_fcr".tr;
      case "Feed Stock":
        return "tab_feed_stock".tr;
      case "Medicine":
        return "tab_medicine".tr;
      case "Expenses":
        return "tab_expenses".tr;
      case "P&L":
        return "tab_pl".tr;
      case "Harvest":
        return "tab_harvest".tr;
      default:
        return internal;
    }
  }

  // 🌐 Expense category label — display only
  String _expenseCategoryLabel(String internal) {
    switch (internal) {
      case "All":
        return "all".tr;
      case "Labour":
        return "labour_label".tr;
      case "Salary":
        return "salary_label".tr;
      case "Tiffins/Meals":
        return "tiffins_meals_label".tr;
      case "Petrol":
        return "petrol_label".tr;
      case "Diesel":
        return "diesel_label".tr;
      case "Electrical":
        return "electrical_label".tr;
      case "Plumbing":
        return "plumbing_label".tr;
      case "Transport":
        return "transport_label".tr;
      default:
        return internal;
    }
  }

  // Controllers
  late final HomeTankOverViewController _homeController;
  late final SpeciesController _speciesController;
  late final PurchaseController _purchaseController;
  late final LogFeedingController _logFeedingController;
  late final ProfileController _profileController;
  late final MedicineController _medicineController;
  late final HomeMedicineController _homeMedicineController;
  late final MedicineUseageController _medicineUsageController;
  late final HomeHarvestController _homeHarvestController;
  late final HarvestController _harvestController;
  late final ExpenceController _expenceController;
  late final HomePandlController _homePandlController;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<HomeTankOverViewController>()) {
      _homeController = Get.find<HomeTankOverViewController>();
    } else {
      _homeController = Get.put(HomeTankOverViewController(OverviewService()));
    }
    _homeController.fetchhomeoverviewdata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

    if (Get.isRegistered<SpeciesController>()) {
      _speciesController = Get.find<SpeciesController>();
    } else {
      _speciesController = Get.put(SpeciesController(OverviewService()));
    }

    _speciesController.fetchspeciesdata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

    if (Get.isRegistered<PurchaseController>()) {
      _purchaseController = Get.find<PurchaseController>();
    } else {
      _purchaseController = Get.put(PurchaseController(OverviewService()));
    }
    _purchaseController.fetchpurchasedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

    if (Get.isRegistered<LogFeedingController>()) {
      _logFeedingController = Get.find<LogFeedingController>();
    } else {
      _logFeedingController = Get.put(LogFeedingController(OverviewService()));
    }
    _logFeedingController.fetchlogfeedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
      speciesId: _selectedSpecies?.id ?? "",
    );

    if (Get.isRegistered<ProfileController>()) {
      _profileController = Get.find<ProfileController>();
    } else {
      _profileController = Get.put(ProfileController(ProfileService()));
    }
    _profileController.fetchgetprofiledata();

    if (Get.isRegistered<MedicineController>()) {
      _medicineController = Get.find<MedicineController>();
    } else {
      _medicineController = Get.put(MedicineController(OverviewService()));
    }
    _medicineController.fetchmedicinedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

    if (Get.isRegistered<HomeMedicineController>()) {
      _homeMedicineController = Get.find<HomeMedicineController>();
    } else {
      _homeMedicineController = Get.put(
        HomeMedicineController(OverviewService()),
      );
    }

    ever(_medicineController.medicineDataResponce, (resp) {
      final list = resp.data ?? [];
      if (list.isEmpty) return;

      final sorted = [...list]..sort((a, b) {
        final da = _parseDate(a.purchaseDate as String?) ?? DateTime(1970);
        final db = _parseDate(b.purchaseDate as String?) ?? DateTime(1970);
        return db.compareTo(da);
      });

      final latest = sorted.first;

      _homeMedicineController.fetchhomemedicinedata(
        tankId: widget.tankId,
        medicineId: latest.id ?? "",
        medicineType: "kgs",
        farmId: widget.farmId,
      );
    });

    if (Get.isRegistered<MedicineUseageController>()) {
      _medicineUsageController = Get.find<MedicineUseageController>();
    } else {
      _medicineUsageController = Get.put(
        MedicineUseageController(OverviewService()),
      );
    }
    _medicineUsageController.fetchmedicineuseagedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

    if (Get.isRegistered<HomeHarvestController>()) {
      _homeHarvestController = Get.find<HomeHarvestController>();
    } else {
      _homeHarvestController = Get.put(
        HomeHarvestController(OverviewService()),
      );
    }
    _homeHarvestController.fetchomeharverstdata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

    if (Get.isRegistered<HarvestController>()) {
      _harvestController = Get.find<HarvestController>();
    } else {
      _harvestController = Get.put(HarvestController(OverviewService()));
    }
    _harvestController.fetchharvestdata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

    if (Get.isRegistered<ExpenceController>()) {
      _expenceController = Get.find<ExpenceController>();
    } else {
      _expenceController = Get.put(ExpenceController(OverviewService()));
    }
    _expenceController.fetchexpencedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );
    if (Get.isRegistered<HomePandlController>()) {
      _homePandlController = Get.find<HomePandlController>();
    } else {
      _homePandlController = Get.put(HomePandlController(OverviewService()));
    }
    _homePandlController.fetchgetpandldata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );
  }

  Overview? _currentOverview() {
    final resp = _homeController.hometankoverviewDataResponce.value;
    final list = resp.overview ?? [];
    if (list.isEmpty) return null;
    return list.first;
  }

  double _totalInvested(List<Stock> stocks) {
    double total = 0;
    for (final s in stocks) {
      total += double.tryParse(s.totalAmount ?? "--") ?? 0;
    }
    return total;
  }

  String _daysOfCulture(List<Stock> stocks) {
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
    return diffDays < 0 ? "0" : diffDays.toString();
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

  String _formatDayMonth(DateTime d) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${d.day} ${months[d.month - 1]}";
  }

  String _expenseFilter = "All";

  final List<String> _expenseCategories = [
    "All",
    "Labour",
    "Salary",
    "Tiffins/Meals",
    "Petrol",
    "Diesel",
    "Electrical",
    "Plumbing",
    "Transport",
  ];
  final _overviewservice = Get.find<OverviewService>();

  double _pnlExpenseAmount(dynamic e) {
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

    // Fallback
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
    if (e.electrical?.total != null) return e.electrical!.total!.toDouble();
    if (e.plumbing?.total != null) return e.plumbing!.total!.toDouble();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Obx(() {
                  final resp =
                      _homeController.hometankoverviewDataResponce.value;
                  final loading = resp.overview == null;
                  final overview = _currentOverview();
                  final doc = _daysOfCulture(overview?.stocks ?? []);

                  final tankName = overview?.name ?? "tank".tr;
                  final tankType = overview?.tankType ?? "";
                  final tankIdShort =
                      (overview?.id ?? "").length >= 6
                          ? overview!.id!.substring(0, 6).toUpperCase()
                          : "TANK";

                  final isFish = tankType.toLowerCase() == "fish";

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: Row(
                          children: [
                            _circleBtn(
                              Icons.arrow_back_ios_new,
                              onTap: () => Get.back(),
                            ),
                            const Spacer(),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (loading)
                        _shimmerBox(height: 100, width: 120, radius: 10)
                      else
                        Image.asset(
                          isFish ? AppImages.fishimage : AppImages.prawnimage,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.set_meal,
                                color: Colors.white,
                                size: 70,
                              ),
                        ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child:
                                  loading
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _shimmerLine(width: 100, height: 10),
                                          const SizedBox(height: 8),
                                          _shimmerLine(width: 160, height: 18),
                                        ],
                                      )
                                      : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            textName:
                                                "${tankType.isEmpty ? "tank".tr : (isFish ? "fish".tr : "prawn".tr)} · $tankIdShort",
                                            fontFamily: FontFamily.poppins,
                                            fontWeightType:
                                                FontWeightType.regular,
                                            textColor: Colors.white70,
                                            fontSize: 12,
                                          ),
                                          const SizedBox(height: 4),
                                          CustomText(
                                            textName: tankName,
                                            fontFamily: FontFamily.poppins,
                                            fontWeightType: FontWeightType.bold,
                                            textColor: Colors.white,
                                            fontSize: 22,
                                          ),
                                        ],
                                      ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white24,
                                border: Border.all(
                                  color: Colors.white54,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomText(
                                    textName: loading ? "–" : "$doc",
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.bold,
                                    textColor: Colors.white,
                                    fontSize: 13,
                                  ),
                                  CustomText(
                                    textName: "DOC",
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.regular,
                                    textColor: Colors.white,
                                    fontSize: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            Container(
              color: Colors.white,
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 4),
                itemBuilder: (context, index) {
                  final isActive = _selectedTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive ? _primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: CustomText(
                        textName: _tabLabel(_tabs[index]),
                        fontFamily: FontFamily.poppins,
                        fontWeightType:
                            isActive
                                ? FontWeightType.semiBold
                                : FontWeightType.regular,
                        textColor: isActive ? _primary : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _overviewContent(),
                  _feedingFCRContent(),
                  _feedStockContent(),
                  _medicineContent(),
                  _expensesContent(),
                  _pAndLContent(),
                  _harvestContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewContent() {
    return Obx(() {
      final resp = _homeController.hometankoverviewDataResponce.value;
      final overview = _currentOverview();
      final stocks = overview?.stocks ?? [];
      final loading = resp.overview == null;

      if (loading) return _overviewShimmer();

      final harvestList =
          _harvestController.harvestDataResponce.value.harvests ?? [];

      DateTime? latestFinalMoment;
      for (final h in harvestList) {
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

        if (latestFinalMoment == null || candidate.isAfter(latestFinalMoment)) {
          latestFinalMoment = candidate;
        }
      }

      List<Stock> visibleStocks;
      if (latestFinalMoment == null) {
        visibleStocks = stocks;
      } else {
        visibleStocks =
            stocks.where((s) {
              DateTime? created = s.logCreatedDate;
              if (created == null) {
                final parsed = _parseDate(s.date);
                if (parsed != null) {
                  created = DateTime(parsed.year, parsed.month, parsed.day);
                }
              }
              if (created == null) return false;
              return created.isAfter(latestFinalMoment!);
            }).toList();
      }

      final bool showStockingInfo = visibleStocks.isNotEmpty;

      final invested = _totalInvested(stocks);
      final doc = _daysOfCulture(visibleStocks);

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          children: [
            // _buildCard(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       CustomText(
            //         textName: "stocking_info".tr,
            //         fontFamily: FontFamily.poppins,
            //         fontWeightType: FontWeightType.bold,
            //         textColor: AppColors.blackColor,
            //         fontSize: 14,
            //       ),
            //       const SizedBox(height: 12),

            //       if (!showStockingInfo)
            //         CustomText(
            //           textName: "no_stocking_yet".tr,
            //           fontFamily: FontFamily.poppins,
            //           fontWeightType: FontWeightType.regular,
            //           textColor: Colors.grey.shade600,
            //           fontSize: 13,
            //         )
            //       else
            //         Builder(
            //           builder: (context) {
            //             final sortedStocks = [...visibleStocks]..sort((a, b) {
            //               final da =
            //                   a.logCreatedDate ??
            //                   _parseDate(a.date) ??
            //                   DateTime(1970);
            //               final db =
            //                   b.logCreatedDate ??
            //                   _parseDate(b.date) ??
            //                   DateTime(1970);
            //               return db.compareTo(da);
            //             });

            //             final latest = sortedStocks.first;

            //             double totalStockingCost = 0;
            //             for (final s in visibleStocks) {
            //               totalStockingCost +=
            //                   double.tryParse(s.totalAmount ?? "0") ?? 0;
            //             }

            //             return _buildStockInfo(
            //               latest,
            //               totalStockingCost: totalStockingCost,
            //             );
            //           },
            //         ),
            //     ],
            //   ),
            // ),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        textName: "stocking_info".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: AppColors.blackColor,
                        fontSize: 14,
                      ),

                      // ✅ Added Edit Icon here
                      if (showStockingInfo)
                        Builder(
                          builder: (context) {
                            final sortedStocks = [...visibleStocks]
                              ..sort((a, b) {
                                final da =
                                    a.logCreatedDate ??
                                    _parseDate(a.date) ??
                                    DateTime(1970);
                                final db =
                                    b.logCreatedDate ??
                                    _parseDate(b.date) ??
                                    DateTime(1970);
                                return db.compareTo(da);
                              });
                            final latestStock = sortedStocks.first;

                            return GestureDetector(
                              onTap: () async {
                                await Get.to(
                                  () => EditStockingScreen(
                                    tankId: widget.tankId,
                                    farmId: widget.farmId,
                                    stock:
                                        latestStock, // ✅ Passing the stock object here
                                  ),
                                );
                                // Refresh data when coming back
                                _homeController.fetchhomeoverviewdata(
                                  tankId: widget.tankId,
                                  farmId: widget.farmId,
                                );
                                _homePandlController.fetchgetpandldata(
                                  tankId: widget.tankId,
                                  farmId: widget.farmId,
                                );
                              },
                              child: Icon(
                                Icons.edit_outlined,
                                color: _primary,
                                size: 18,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (!showStockingInfo)
                    CustomText(
                      textName: "no_stocking_yet".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 13,
                    )
                  else
                    Builder(
                      builder: (context) {
                        final sortedStocks = [...visibleStocks]..sort((a, b) {
                          final da =
                              a.logCreatedDate ??
                              _parseDate(a.date) ??
                              DateTime(1970);
                          final db =
                              b.logCreatedDate ??
                              _parseDate(b.date) ??
                              DateTime(1970);
                          return db.compareTo(da);
                        });

                        final latest = sortedStocks.first;

                        double totalStockingCost = 0;
                        for (final s in visibleStocks) {
                          totalStockingCost +=
                              double.tryParse(s.totalAmount ?? "0") ?? 0;
                        }

                        return _buildStockInfo(
                          latest,
                          totalStockingCost: totalStockingCost,
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _buildCard(
              child: SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: CustomText(
                            textName: "$doc",
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.bold,
                            textColor: AppColors.blackColor,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomText(
                        textName: "days_of_culture".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // _buildCard(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       CustomText(
            //         textName: "cycle_summary".tr,
            //         fontFamily: FontFamily.poppins,
            //         fontWeightType: FontWeightType.bold,
            //         textColor: AppColors.blackColor,
            //         fontSize: 14,
            //       ),
            //       const SizedBox(height: 16),
            //       Obx(() {
            //         final income =
            //             (_homeHarvestController
            //                         .homeharvestDataResponce
            //                         .value
            //                         .data
            //                         ?.totalAmount ??
            //                     0)
            //                 .toDouble();

            //         final netPnl = income - invested;

            //         return Row(
            //           children: [
            //             Expanded(
            //               child: _buildInfoBlock(
            //                 label: "invested".tr,
            //                 value: "₹${invested.toStringAsFixed(0)}",
            //                 valueColor: AppColors.blackColor,
            //               ),
            //             ),
            //             Expanded(
            //               child: _buildInfoBlock(
            //                 label: "income".tr,
            //                 value: "₹${income.toStringAsFixed(0)}",
            //                 valueColor: AppColors.blackColor,
            //               ),
            //             ),
            //             Expanded(
            //               child: _buildInfoBlock(
            //                 label: "net_pl".tr,
            //                 value: "₹${netPnl.toStringAsFixed(0)}",
            //                 valueColor: netPnl >= 0 ? _green : _red,
            //               ),
            //             ),
            //           ],
            //         );
            //       }),
            //     ],
            //   ),
            // ),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    textName: "cycle_summary".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 16),

                  Obx(() {
                    final pnl =
                        _homePandlController.homepandlDataResponce.value;
                    final logFeedingResp =
                        _logFeedingController.logfeedDataResponce.value;
                    final medUsageResp =
                        _medicineUsageController.medicineuseDataResponce.value;

                    // ═══════════════════════════════════════════════════
                    // 1. INCOME (From Harvests) — same as P&L widget
                    // ═══════════════════════════════════════════════════
                    double income = 0;
                    for (final h in pnl.harvests ?? []) {
                      income += double.tryParse(h.totalAmount ?? "0") ?? 0;
                    }

                    // ═══════════════════════════════════════════════════
                    // 2. AVG COST PER KG FOR FEED — same as P&L widget
                    // ═══════════════════════════════════════════════════
                    double totalPurchasedKg = 0;
                    double totalPurchasedAmount = 0;
                    for (final p in pnl.purchases ?? []) {
                      totalPurchasedKg +=
                          double.tryParse(p.quantityPurchased ?? "0") ?? 0;
                      totalPurchasedAmount +=
                          double.tryParse(p.totalAmount ?? "0") ?? 0;
                    }
                    final double avgFeedCostPerKg =
                        totalPurchasedKg > 0
                            ? (totalPurchasedAmount / totalPurchasedKg)
                            : 0.0;

                    // ═══════════════════════════════════════════════════
                    // 3. AVG COST PER UNIT FOR MEDICINE — same as P&L widget
                    // ═══════════════════════════════════════════════════
                    double totalMedPurchasedQty = 0;
                    double totalMedPurchasedAmount = 0;
                    for (final m in pnl.medicines ?? []) {
                      totalMedPurchasedQty +=
                          double.tryParse(m.quantityPurchased ?? "0") ?? 0;
                      totalMedPurchasedAmount +=
                          double.tryParse(m.totalAmount ?? "0") ?? 0;
                    }
                    final double avgMedCostPerUnit =
                        totalMedPurchasedQty > 0
                            ? (totalMedPurchasedAmount / totalMedPurchasedQty)
                            : 0.0;

                    // ═══════════════════════════════════════════════════
                    // 4. EXPENSE PIECES — same as P&L widget
                    // ═══════════════════════════════════════════════════

                    // ✅ Feed Consumed Amount (from consumption logs × avg cost)
                    double feedConsumedKg = 0;
                    for (final log in logFeedingResp.data ?? []) {
                      feedConsumedKg += double.tryParse(log.kg ?? "0") ?? 0;
                    }
                    double feedConsumedAmount =
                        feedConsumedKg * avgFeedCostPerKg;

                    // ✅ Medicine Used Amount (from usage logs × avg cost)
                    double medicineUsedQty = 0;
                    for (final log in medUsageResp.data ?? []) {
                      medicineUsedQty +=
                          double.tryParse(log.quanTityUsed ?? "0") ?? 0;
                    }
                    double medicineUsedAmount =
                        medicineUsedQty * avgMedCostPerUnit;

                    // ✅ Stocking
                    double stocking = 0;
                    for (final o in pnl.overview ?? []) {
                      for (final s in o.stocks ?? []) {
                        stocking += double.tryParse(s.totalAmount ?? "0") ?? 0;
                      }
                    }

                    // ✅ Labour/Salary + Other
                    double labourSalaries = 0;
                    double otherExpenses = 0;
                    for (var e in pnl.expenses ?? []) {
                      final cat = (e.category ?? "").toLowerCase().trim();
                      final amt = _pnlExpenseAmount(e);
                      if (cat == "labour" || cat == "salary") {
                        labourSalaries += amt;
                      } else {
                        otherExpenses += amt;
                      }
                    }

                    final double totalExpenses =
                        feedConsumedAmount +
                        medicineUsedAmount +
                        stocking +
                        labourSalaries +
                        otherExpenses;

                    final double netPnl = income - totalExpenses;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildInfoBlock(
                            label: "invested".tr,
                            value: "₹${totalExpenses.toStringAsFixed(0)}",
                            valueColor: AppColors.blackColor,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoBlock(
                            label: "income".tr,
                            value: "₹${income.toStringAsFixed(0)}",
                            valueColor: AppColors.blackColor,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoBlock(
                            label: "net_pl".tr,
                            value: "₹${netPnl.toStringAsFixed(0)}",
                            valueColor: netPnl >= 0 ? _green : _red,
                          ),
                        ),
                      ],
                    );
                  }),

                  // Obx(() {
                  //   final pnl =
                  //       _homePandlController.homepandlDataResponce.value;

                  //   // ──────────────────────────────────────────────
                  //   // ✅ INCOME (from harvests) — same as P&L widget
                  //   // ──────────────────────────────────────────────
                  //   double income = 0;
                  //   for (final h in pnl.harvests ?? []) {
                  //     income += double.tryParse(h.totalAmount ?? "0") ?? 0;
                  //   }

                  //   // ──────────────────────────────────────────────
                  //   // ✅ EXPENSE PIECES — same as P&L widget
                  //   // ──────────────────────────────────────────────
                  //   double feedConsumed = 0;
                  //   for (final p in pnl.purchases ?? []) {
                  //     feedConsumed +=
                  //         double.tryParse(p.totalAmount ?? "0") ?? 0;
                  //   }

                  //   double medicineUsed = 0;
                  //   for (final m in pnl.medicines ?? []) {
                  //     medicineUsed +=
                  //         double.tryParse(m.totalAmount ?? "0") ?? 0;
                  //   }

                  //   double stocking = 0;
                  //   for (final o in pnl.overview ?? []) {
                  //     for (final s in o.stocks ?? []) {
                  //       stocking += double.tryParse(s.totalAmount ?? "0") ?? 0;
                  //     }
                  //   }

                  //   double labourSalaries = 0;
                  //   double otherExpenses = 0;
                  //   for (var e in pnl.expenses ?? []) {
                  //     final cat = (e.category ?? "").toLowerCase().trim();
                  //     final amt = _pnlExpenseAmount(
                  //       e,
                  //     ); // ✅ Uses the dynamic helper
                  //     if (cat == "labour" || cat == "salary") {
                  //       labourSalaries += amt;
                  //     } else {
                  //       otherExpenses += amt;
                  //     }
                  //   }

                  //   final double totalExpenses =
                  //       feedConsumed +
                  //       medicineUsed +
                  //       stocking +
                  //       labourSalaries +
                  //       otherExpenses;
                  //   final double netPnl = income - totalExpenses;

                  //   return Row(
                  //     children: [
                  //       Expanded(
                  //         child: _buildInfoBlock(
                  //           label: "invested".tr,
                  //           value: "₹${totalExpenses.toStringAsFixed(0)}",
                  //           valueColor: AppColors.blackColor,
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: _buildInfoBlock(
                  //           label: "income".tr,
                  //           value: "₹${income.toStringAsFixed(0)}",
                  //           valueColor: AppColors.blackColor,
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: _buildInfoBlock(
                  //           label: "net_pl".tr,
                  //           value: "₹${netPnl.toStringAsFixed(0)}",
                  //           valueColor: netPnl >= 0 ? _green : _red,
                  //         ),
                  //       ),
                  //     ],
                  //   );
                  // }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    textName: "assigned_staff".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 14),

                  if (overview?.staffName == null ||
                      overview!.staffName!.isEmpty)
                    CustomText(
                      textName: "no_staff_assigned".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 13,
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          overview!.staffName!.map((name) {
                            return Chip(
                              label: CustomText(
                                textName: name,
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.medium,
                                textColor: _primaryDark,
                                fontSize: 12,
                              ),
                              backgroundColor: const Color(0xFFE6F2F9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: _primaryDark.withOpacity(0.3),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () async {
                        final overview = _currentOverview();
                        if (overview == null) return;

                        final tank = Tank(
                          id: overview.id,
                          userId: overview.userId,
                          name: overview.name,
                          tankType: overview.tankType,
                          pondSize: overview.pondSize,
                          address: overview.address,
                          status: overview.status,
                          staffId: overview.staffId,
                        );

                        await Get.to(() => EditTankScreen(tank: tank));

                        _homeController.fetchhomeoverviewdata(
                          tankId: widget.tankId,
                          farmId: widget.farmId,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: CustomText(
                        textName: "edit_tank".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.semiBold,
                        textColor: AppColors.blackColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Get.to(
                          () => AddStockingScreen(
                            tankId: widget.tankId,
                            farmId: widget.farmId,
                          ),
                        );
                        _homeController.fetchhomeoverviewdata(
                          tankId: widget.tankId,
                          farmId: widget.farmId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: CustomText(
                        textName: "new_stocking".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.semiBold,
                        textColor: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _overviewShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        children: [
          _shimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerLine(width: 110, height: 14),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerLine(width: 60, height: 10),
                          const SizedBox(height: 8),
                          _shimmerLine(width: 90, height: 12),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerLine(width: 40, height: 10),
                          const SizedBox(height: 8),
                          _shimmerLine(width: 80, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerLine(width: 80, height: 10),
                          const SizedBox(height: 8),
                          _shimmerLine(width: 70, height: 12),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerLine(width: 70, height: 10),
                          const SizedBox(height: 8),
                          _shimmerLine(width: 60, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _shimmerLine(width: 100, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _shimmerCard(
            child: SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
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
                    _shimmerLine(width: 100, height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _shimmerLine({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    required double width,
    double radius = 4,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white54,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildStockInfo(Stock s, {required double totalStockingCost}) {
    final dateStr = _formatDayMonth(_parseDate(s.date) ?? DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _kvBlock("species_col".tr, s.speciesName ?? "—")),
            Expanded(child: _kvBlock("crop_col".tr, s.cropName ?? "—")),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _kvBlock(
                "quantity_stocked_col".tr,
                s.quantityStocked ?? "—",
              ),
            ),
            Expanded(child: _kvBlock("stocking_date_col".tr, dateStr)),
          ],
        ),
        const SizedBox(height: 12),
        _kvBlock(
          "stocking_cost_col".tr,
          "₹${totalStockingCost.toStringAsFixed(0)}",
        ),
      ],
    );
  }

  Widget _kvBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textName: label,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.grey.shade600,
          fontSize: 11,
        ),
        const SizedBox(height: 4),
        CustomText(
          textName: value,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
          fontSize: 13,
        ),
      ],
    );
  }

  Widget _feedingFCRContent() {
    final overview = _currentOverview();
    final allStocks = overview?.stocks ?? [];

    final harvestList =
        _harvestController.harvestDataResponce.value.harvests ?? [];

    DateTime? latestFinal;
    for (final h in harvestList) {
      if ((h.harvestType ?? "").toLowerCase() != "final") continue;
      final precise = h.logCreatedDate;
      final fallback = h.date;
      DateTime? c;
      if (precise != null) {
        c = precise;
      } else if (fallback != null) {
        c = DateTime(fallback.year, fallback.month, fallback.day, 23, 59, 59);
      }
      if (c == null) continue;
      if (latestFinal == null || c.isAfter(latestFinal)) latestFinal = c;
    }

    List<Stock> visibleStocks;
    if (latestFinal == null) {
      visibleStocks = allStocks;
    } else {
      visibleStocks =
          allStocks.where((s) {
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

    final doc = _daysOfCulture(visibleStocks);

    return FeedingFcrBody(
      tankId: widget.tankId,
      farmId: widget.farmId,
      doc: doc,
    );
  }

  Widget _feedStockContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Get.to(
                        AddFeedPurchaseScreen(
                          tankId: widget.tankId,
                          farmId: widget.farmId,
                        ),
                      );
                      _purchaseController.fetchpurchasedata(
                        tankId: widget.tankId,
                        farmId: widget.farmId,
                      );
                      _logFeedingController.fetchlogfeedata(
                        tankId: widget.tankId,
                        farmId: widget.farmId,
                        speciesId: _selectedSpecies?.id ?? "",
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: CustomText(
                      textName: "add_purchase".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      textColor: AppColors.blackColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Get.to(
                        FeedingFCRScreen(
                          tankId: widget.tankId,
                          farmId: widget.farmId,
                        ),
                      );
                      _logFeedingController.fetchlogfeedata(
                        tankId: widget.tankId,
                        farmId: widget.farmId,
                        speciesId: _selectedSpecies?.id ?? "",
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: CustomText(
                      textName: "log_feedings".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      textColor: AppColors.blackColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Obx(() {
            final summary = _computeFeedStockSummary();

            return Row(
              children: [
                Expanded(
                  child: _statCard(
                    label: "total_purchased".tr,
                    value: "${summary.purchasedKg.toStringAsFixed(0)} kg",
                    sub: "₹${summary.purchasedAmount.toStringAsFixed(0)}",
                    bg: Colors.white,
                    valueColor: AppColors.blackColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    label: "total_consumed".tr,
                    value: "${summary.consumedKg.toStringAsFixed(0)} kg",
                    sub:
                        "₹${summary.consumedAmount.toStringAsFixed(0)} ${"to_pl".tr}",
                    bg: Colors.white,
                    valueColor: AppColors.blackColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    label: "closing_stock".tr,
                    value: "${summary.closingKg.toStringAsFixed(0)} kg",
                    sub:
                        "₹${summary.closingAmount.toStringAsFixed(0)} ${"value_suffix".tr}",
                    bg: const Color(0xFFE7F2EA),
                    valueColor: _green,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 18),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final purchases =
                      _purchaseController.purchaseDataResponce.value.data ?? [];
                  final feedName =
                      purchases.isNotEmpty
                          ? (purchases.first.feedName ?? "feed".tr)
                          : "feed".tr;
                  return CustomText(
                    textName: feedName,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 14,
                  );
                }),
                const SizedBox(height: 16),

                Obx(() {
                  final summary = _computeFeedStockSummary();

                  return Row(
                    children: [
                      Expanded(
                        child: _miniBlock(
                          label: "purchased".tr,
                          value: "${summary.purchasedKg.toStringAsFixed(0)} kg",
                          sub: "₹${summary.purchasedAmount.toStringAsFixed(0)}",
                        ),
                      ),
                      Expanded(
                        child: _miniBlock(
                          label: "consumed".tr,
                          value: "${summary.consumedKg.toStringAsFixed(0)} kg",
                          sub: "₹${summary.consumedAmount.toStringAsFixed(0)}",
                        ),
                      ),
                      Expanded(
                        child: _miniBlock(
                          label: "closing".tr,
                          value: "${summary.closingKg.toStringAsFixed(0)} kg",
                          sub: "₹${summary.closingAmount.toStringAsFixed(0)}",
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 18),

                CustomText(
                  textName: "consumption_log".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: Colors.grey.shade700,
                  fontSize: 10,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final list =
                      _logFeedingController.logfeedDataResponce.value.data;

                  if (list == null) return _feedLogShimmer();

                  if (list.isEmpty) {
                    return CustomText(
                      textName: "no_feedings_yet".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 11,
                    );
                  }

                  final sorted = [...list]..sort((a, b) {
                    final da = a.date ?? DateTime(1970);
                    final db = b.date ?? DateTime(1970);
                    return db.compareTo(da);
                  });

                  return Column(
                    children: [
                      for (int i = 0; i < sorted.length; i++) ...[
                        _consumptionLogRow(sorted[i]),
                        if (i != sorted.length - 1) const SizedBox(height: 6),
                      ],
                    ],
                  );
                }),
                const SizedBox(height: 18),

                CustomText(
                  textName: "purchase_log".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: Colors.grey.shade700,
                  fontSize: 10,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final list =
                      _purchaseController.purchaseDataResponce.value.data;

                  if (list == null) return _feedLogShimmer();

                  if (list.isEmpty) {
                    return CustomText(
                      textName: "no_purchases_yet".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 11,
                    );
                  }

                  final sorted = [...list]..sort((a, b) {
                    final da = a.date ?? DateTime(1970);
                    final db = b.date ?? DateTime(1970);
                    return db.compareTo(da);
                  });

                  return Column(
                    children: [
                      for (int i = 0; i < sorted.length; i++) ...[
                        _purchaseLogRow(sorted[i]),
                        if (i != sorted.length - 1) const SizedBox(height: 6),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _FeedStockSummary _computeFeedStockSummary() {
    final purchases = _purchaseController.purchaseDataResponce.value.data ?? [];
    double purchasedKg = 0;
    double purchasedAmount = 0;
    for (final p in purchases) {
      purchasedKg += double.tryParse(p.quantityPurchased ?? "0") ?? 0;
      purchasedAmount += double.tryParse(p.totalAmount ?? "0") ?? 0;
    }

    final double avgCostPerKg =
        purchasedKg > 0 ? purchasedAmount / purchasedKg : 0.0;

    final logs = _logFeedingController.logfeedDataResponce.value.data ?? [];
    double consumedKg = 0;
    for (final l in logs) {
      consumedKg += double.tryParse(l.kg ?? "0") ?? 0;
    }
    final consumedAmount = consumedKg * avgCostPerKg;

    final closingKg = purchasedKg - consumedKg;
    final closingAmount = purchasedAmount - consumedAmount;

    return _FeedStockSummary(
      purchasedKg: purchasedKg < 0 ? 0.0 : purchasedKg,
      purchasedAmount: purchasedAmount < 0 ? 0.0 : purchasedAmount,
      consumedKg: consumedKg < 0 ? 0.0 : consumedKg,
      consumedAmount: consumedAmount < 0 ? 0.0 : consumedAmount,
      closingKg: closingKg < 0 ? 0.0 : closingKg,
      closingAmount: closingAmount < 0 ? 0.0 : closingAmount,
      avgCostPerKg: avgCostPerKg,
    );
  }

  Widget _consumptionLogRow(logfeeding.Datum l) {
    final dateStr = l.date != null ? _formatDayMonth(l.date!) : "—";
    final kg = "${l.kg ?? "—"} kg";

    final staff = (l.staffName ?? "").trim();
    final hasStaff = staff.isNotEmpty;

    final feed = (l.feedName ?? "").trim();
    final hasFeed = feed.isNotEmpty;

    String rightText = "";
    if (hasStaff && hasFeed) {
      rightText = "$staff · $feed";
    } else if (hasStaff) {
      rightText = staff;
    } else if (hasFeed) {
      rightText = feed;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: CustomText(
              textName: dateStr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 80,
            child: CustomText(
              textName: kg,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: AppColors.blackColor,
              fontSize: 12,
            ),
          ),
          Expanded(
            child:
                rightText.isEmpty
                    ? const SizedBox.shrink()
                    : CustomText(
                      textName: rightText,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 11,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _purchaseLogRow(purchase.Datum p) {
    final dateStr = p.date != null ? _formatDayMonth(p.date!) : "—";

    final qty = "${p.quantityPurchased ?? "—"} kg";
    final info =
        "₹${p.totalAmount ?? "—"}${(p.paymentMethod ?? "").isNotEmpty ? " · ${p.paymentMethod}" : ""}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: CustomText(
              textName: dateStr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 80,
            child: CustomText(
              textName: qty,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: AppColors.blackColor,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: CustomText(
              textName: info,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 11,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedLogShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          for (int i = 0; i < 2; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            if (i != 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _medicineContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Get.to(
                        AddMedicinePurchaseScreen(
                          tankId: widget.tankId,
                          farmId: widget.farmId,
                        ),
                      );
                      _medicineController.fetchmedicinedata(
                        tankId: widget.tankId,
                        farmId: widget.farmId,
                      );
                      _medicineUsageController.fetchmedicineuseagedata(
                        tankId: widget.tankId,
                        farmId: widget.farmId,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: CustomText(
                      textName: "add_purchase".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      textColor: AppColors.blackColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Get.to(
                        LogMedicineUsageScreen(
                          tankId: widget.tankId,
                          farmId: widget.farmId,
                        ),
                      );
                      _medicineController.fetchmedicinedata(
                        tankId: widget.tankId,
                        farmId: widget.farmId,
                      );
                      _medicineUsageController.fetchmedicineuseagedata(
                        tankId: widget.tankId,
                        farmId: widget.farmId,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: CustomText(
                      textName: "log_usage".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      textColor: AppColors.blackColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Obx(() {
            final response = _medicineController.medicineDataResponce.value;

            if (response.data == null) {
              return _medicineShimmer();
            }

            final list = response.data ?? [];

            if (list.isEmpty) {
              return _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textName: "no_medicines_yet".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor: AppColors.blackColor,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      textName: "add_purchase_to_track_medicine".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ],
                ),
              );
            }

            double purchasedQty = 0;
            double purchasedAmount = 0;
            for (final m in list) {
              purchasedQty += double.tryParse(m.quantityPurchased ?? "0") ?? 0;
              purchasedAmount += double.tryParse(m.totalAmount ?? "0") ?? 0;
            }

            final allUsage =
                _medicineUsageController.medicineuseDataResponce.value.data ??
                [];

            final usageList =
                allUsage
                    .where((u) => (u.tankId ?? "") == widget.tankId)
                    .toList();

            double usedQty = 0;
            for (final u in usageList) {
              usedQty += double.tryParse(u.quanTityUsed ?? "0") ?? 0;
            }

            final double avgCostPerUnit =
                purchasedQty > 0 ? purchasedAmount / purchasedQty : 0.0;

            final usedAmount = usedQty * avgCostPerUnit;

            final closingQty = purchasedQty - usedQty;
            final closingAmount = purchasedAmount - usedAmount;

            final Map<String, List<medicine.Datum>> grouped = {};
            for (final m in list) {
              final key = (m.medicineName ?? "unknown".tr).trim();
              grouped.putIfAbsent(key, () => []).add(m);
            }

            final Map<String, List<medicineusage.Datum>> usageGrouped = {};
            for (final u in usageList) {
              final key = (u.medicineName ?? "unknown".tr).trim();
              usageGrouped.putIfAbsent(key, () => []).add(u);
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        label: "total_purchased".tr,
                        value:
                            "${purchasedQty.toStringAsFixed(0)} ${"units".tr}",
                        sub: "₹${purchasedAmount.toStringAsFixed(0)}",
                        bg: Colors.white,
                        valueColor: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        label: "total_used".tr,
                        value: "${usedQty.toStringAsFixed(0)} ${"units".tr}",
                        sub: "₹${usedAmount.toStringAsFixed(0)} ${"to_pl".tr}",
                        bg: Colors.white,
                        valueColor: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        label: "closing_stock".tr,
                        value: "${closingQty.toStringAsFixed(0)} ${"units".tr}",
                        sub:
                            "₹${closingAmount.toStringAsFixed(0)} ${"value_suffix".tr}",
                        bg: const Color(0xFFE7F2EA),
                        valueColor: _green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                for (final entry in grouped.entries) ...[
                  _buildMedicineGroupCard(
                    entry.key,
                    entry.value,
                    usageGrouped[entry.key] ?? [],
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMedicineGroupCard(
    String medicineName,
    List<medicine.Datum> items,
    List<medicineusage.Datum> usages,
  ) {
    double purchasedQty = 0;
    double purchasedAmount = 0;
    for (final m in items) {
      purchasedQty += double.tryParse(m.quantityPurchased ?? "0") ?? 0;
      purchasedAmount += double.tryParse(m.totalAmount ?? "0") ?? 0;
    }

    double usedQty = 0;
    for (final u in usages) {
      usedQty += double.tryParse(u.quanTityUsed ?? "0") ?? 0;
    }

    final double avgCostPerUnit =
        purchasedQty > 0 ? purchasedAmount / purchasedQty : 0.0;
    final usedAmount = usedQty * avgCostPerUnit;

    final closingQty = purchasedQty - usedQty;
    final closingAmount = purchasedAmount - usedAmount;

    final String unitLabel =
        (items.isNotEmpty && (items.first.medicineType ?? "").trim().isNotEmpty)
            ? items.first.medicineType!.trim()
            : "units".tr;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: medicineName,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: AppColors.blackColor,
            fontSize: 15,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _miniBlock(
                  label: "purchased".tr,
                  value: "${purchasedQty.toStringAsFixed(0)} $unitLabel",
                  sub: "₹${purchasedAmount.toStringAsFixed(0)}",
                ),
              ),
              Expanded(
                child: _miniBlock(
                  label: "used".tr,
                  value: "${usedQty.toStringAsFixed(0)} $unitLabel",
                  sub: "₹${usedAmount.toStringAsFixed(0)}",
                ),
              ),
              Expanded(
                child: _miniBlock(
                  label: "closing".tr,
                  value: "${closingQty.toStringAsFixed(0)} $unitLabel",
                  sub: "₹${closingAmount.toStringAsFixed(0)}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          CustomText(
            textName: "usage_log".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: Colors.grey.shade700,
            fontSize: 10,
          ),
          const SizedBox(height: 10),
          if (usages.isEmpty)
            CustomText(
              textName: "no_usage_yet".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 11,
            )
          else
            for (int i = 0; i < usages.length; i++) ...[
              _medicineUsageRow(usages[i], unitLabel),
              if (i != usages.length - 1) const SizedBox(height: 6),
            ],
        ],
      ),
    );
  }

  Widget _medicineUsageRow(medicineusage.Datum u, String unitLabel) {
    final dateStr = _formatDayMonth(_parseDate(u.date) ?? DateTime.now());
    final qty = "${u.quanTityUsed ?? "—"} $unitLabel";

    final staff = (u.staffName ?? "").trim();
    final notes = (u.notes ?? "").trim();

    final hasStaff = staff.isNotEmpty;
    final hasNotes = notes.isNotEmpty;

    String rightText = "";
    if (hasStaff && hasNotes) {
      rightText = "$staff · $notes";
    } else if (hasStaff) {
      rightText = staff;
    } else if (hasNotes) {
      rightText = notes;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: CustomText(
              textName: dateStr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 80,
            child: CustomText(
              textName: qty,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: AppColors.blackColor,
              fontSize: 12,
            ),
          ),
          Expanded(
            child:
                rightText.isEmpty
                    ? const SizedBox.shrink()
                    : CustomText(
                      textName: rightText,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 11,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overFlow: TextOverflow.ellipsis,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _medicineLogRow(medicine.Datum m) {
    final dateStr =
        m.purchaseDate != null ? _formatDayMonth(m.purchaseDate!) : "—";

    final qty = "${m.quantityPurchased ?? "—"} ${"units".tr}";
    final info =
        "₹${m.totalAmount ?? "—"}${(m.paidBy ?? "").isNotEmpty ? " · ${m.paidBy}" : ""}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: CustomText(
              textName: dateStr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 80,
            child: CustomText(
              textName: qty,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: AppColors.blackColor,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: CustomText(
              textName: info,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 11,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineShimmer() {
    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              Expanded(child: _shimmerStatCard()),
              if (i != 2) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 18),
        _shimmerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerLine(width: 100, height: 14),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _shimmerLine(width: 60, height: 12)),
                  Expanded(child: _shimmerLine(width: 60, height: 12)),
                  Expanded(child: _shimmerLine(width: 60, height: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmerStatCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerLine(width: 60, height: 10),
          const SizedBox(height: 8),
          _shimmerLine(width: 50, height: 12),
          const SizedBox(height: 6),
          _shimmerLine(width: 40, height: 10),
        ],
      ),
    );
  }

  Widget _expensesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  textName: "expenses".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Get.to(
                      AddExpenseScreen(
                        tankId: widget.tankId,
                        farmId: widget.farmId,
                      ),
                    );
                    _expenceController.fetchexpencedata(
                      tankId: widget.tankId,
                      farmId: widget.farmId,
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: CustomText(
                    textName: "add_owner_expense".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: Colors.white,
                    fontSize: 12,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _expenseCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = _expenseCategories[index];
                final isSelected = _expenseFilter == label;
                return GestureDetector(
                  onTap: () {
                    setState(() => _expenseFilter = label);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? _primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? _primary : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: CustomText(
                      textName: _expenseCategoryLabel(label),
                      fontFamily: FontFamily.poppins,
                      fontWeightType:
                          isSelected
                              ? FontWeightType.semiBold
                              : FontWeightType.regular,
                      textColor:
                          isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          Obx(() {
            final resp = _expenceController.expenceDataResponce.value;

            if (resp.expenses == null) {
              return _expenseListShimmer();
            }

            final all = resp.expenses ?? [];

            final filtered =
                all.where((e) {
                  final filter = _expenseFilter.toLowerCase();

                  if (filter == "all") return true;

                  final cat = (e.category ?? "").toLowerCase();

                  if (filter == "labour") return cat == "labour";
                  if (filter == "salary") return cat == "salary";
                  if (filter == "tiffins/meals") {
                    return cat == "tiffins" ||
                        cat == "tiffinsmeals" ||
                        cat == "tiffins/meals";
                  }
                  if (filter == "petrol") return cat == "petrol";
                  if (filter == "diesel") return cat == "diesel";
                  if (filter == "electrical") return cat == "electrical";
                  if (filter == "plumbing") return cat == "plumbing";
                  if (filter == "transport") return cat == "transport";
                  return false;
                }).toList();

            if (filtered.isEmpty) {
              return _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textName:
                          _expenseFilter == "All"
                              ? "no_expenses_yet".tr
                              : "${"no".tr} ${_expenseCategoryLabel(_expenseFilter)} ${"expenses_yet".tr}",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor: AppColors.blackColor,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      textName: "add_expense_to_track".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ],
                ),
              );
            }

            final sorted = [...filtered]..sort((a, b) {
              final da = a.date ?? a.createdAt ?? DateTime(1970);
              final db = b.date ?? b.createdAt ?? DateTime(1970);
              return db.compareTo(da);
            });

            double total = 0;
            for (final e in sorted) {
              total += _expenseAmount(e);
            }

            return Column(
              children: [
                for (int i = 0; i < sorted.length; i++) ...[
                  _buildExpenseCard(sorted[i]),
                  if (i != sorted.length - 1) const SizedBox(height: 12),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _chipBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          textName: "total".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.medium,
                          textColor: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      CustomText(
                        textName: "₹${total.toStringAsFixed(0)}",
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: AppColors.blackColor,
                        fontSize: 15,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense e) {
    final category = e.category ?? "—";
    final dateStr =
        e.date != null
            ? _formatDayMonth(e.date!)
            : (e.createdAt != null ? _formatDayMonth(e.createdAt!) : "—");

    final amount = _expenseAmount(e);
    final title = _expenseTitle(e);

    final expenseId = e.id ?? "";

    final receiptUrl = _receiptUrl(e);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _chipBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CustomText(
                            textName: _expenseCategoryLabel(category),
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.medium,
                            textColor: Colors.grey.shade700,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomText(
                          textName: dateStr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomText(
                      textName: title,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      textColor: AppColors.blackColor,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      textName: "entered_by_you".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: _primary,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    textName: "₹${amount.toStringAsFixed(0)}",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 15,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () async {
                          await _overviewservice.userdeleteexpenses(
                            expenseId: expenseId,
                          );
                          _expenceController.fetchexpencedata(
                            tankId: widget.tankId,
                            farmId: widget.farmId,
                          );
                        },
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          if (receiptUrl != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap:
                  () => _openImageViewer(
                    receiptUrl,
                    title: "$category ${"receipt_suffix".tr}",
                  ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  color: const Color(0xFFF2F6F7),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        receiptUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder:
                            (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _receiptUrl(Expense e) {
    final candidates = <String?>[
      e.labour?.receiptImage,
      e.salary?.receiptImage,
      e.tiffinsMeals?.receiptImage,
      e.petrol?.receiptImage,
      e.diesel?.receiptImage,
      e.electrical?.receiptImage,
      e.plumbing?.receiptImage,
      e.transport?.receiptImage,
      e.utilities?.receiptImage,
      e.other?.receiptImage,
    ];

    String? path;
    for (final c in candidates) {
      if (c != null && c.trim().isNotEmpty) {
        path = c.trim();
        break;
      }
    }

    if (path == null || path.isEmpty) return null;

    if (path.startsWith("http://") || path.startsWith("https://")) {
      return path;
    }

    if (path.startsWith("/")) {
      return "$_baseUrl$path";
    }
    return "$_baseUrl/$path";
  }

  void _openImageViewer(String imageUrl, {String? title}) {
    if (imageUrl.isEmpty) return;

    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: CustomText(
            textName: title ?? "receipt".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: Colors.white,
            fontSize: 15,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(20),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder:
                    (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
      transition: Transition.fadeIn,
    );
  }

  double _expenseAmount(Expense e) {
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

  String _expenseTitle(Expense e) {
    if (e.labour != null &&
        (e.labour!.noofpersonsWorked != null ||
            e.labour!.totalLabourCost != null)) {
      final persons = e.labour!.noofpersonsWorked ?? "—";
      final charges = e.labour!.chargesPerPerson ?? "—";
      return "${"labour_label".tr}: $persons × ₹$charges";
    }

    if (e.salary != null && (e.salary!.persons?.isNotEmpty ?? false)) {
      final count = e.salary!.persons?.length ?? 0;
      final notes = (e.salary!.notes?.toString() ?? "").trim();
      return "${"salary_label".tr}: $count ${count == 1 ? "person_singular".tr : "person_plural".tr}"
          "${notes.isNotEmpty ? ' · $notes' : ''}";
    }

    for (final pair in [
      ["tiffins_meals_label".tr, e.tiffinsMeals],
      ["petrol_label".tr, e.petrol],
      ["diesel_label".tr, e.diesel],
      ["transport_label".tr, e.transport],
      ["utilities_label".tr, e.utilities],
      ["other_label".tr, e.other],
    ]) {
      final d = pair[1] as Diesel?;
      if (d != null &&
          (d.description?.isNotEmpty == true ||
              d.amount != null ||
              d.dieselAmount != null)) {
        final desc = d.description ?? "";
        return desc.isNotEmpty ? desc : "${pair[0]}";
      }
    }

    if (e.electrical != null && e.electrical!.itemName != null) {
      final name = e.electrical!.itemName ?? "—";
      final qty = e.electrical!.quantity ?? 0;
      final unit = e.electrical!.unit ?? "";
      return "$name: $qty $unit".trim();
    }

    if (e.plumbing != null && e.plumbing!.itemName != null) {
      final name = e.plumbing!.itemName ?? "—";
      final qty = e.plumbing!.quantity ?? 0;
      return "$name: $qty";
    }

    return "expense".tr;
  }

  Widget _expenseListShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          for (int i = 0; i < 3; i++) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 50,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 180,
                    height: 12,
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
            if (i != 2) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _pAndLContent() {
    return PandLWidget(tankId: widget.tankId, farmId: widget.farmId);
  }

  Widget _harvestContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                await Get.to(
                  RecordHarvestScreen(
                    tankId: widget.tankId,
                    farmId: widget.farmId,
                  ),
                );
                _harvestController.fetchharvestdata(
                  tankId: widget.tankId,
                  farmId: widget.farmId,
                );
                _homeHarvestController.fetchomeharverstdata(
                  tankId: widget.tankId,
                  farmId: widget.farmId,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: CustomText(
                textName: "record_harvest".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.semiBold,
                textColor: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Obx(() {
            final d = _homeHarvestController.homeharvestDataResponce.value.data;

            final harvestedKg = d?.totalQuantityHarvested;
            final revenue = d?.totalAmount;

            final feedSummary = _computeFeedStockSummary();
            final double harvested = (harvestedKg ?? 0).toDouble();
            final String fcrText =
                harvested > 0
                    ? (feedSummary.consumedKg / harvested).toStringAsFixed(2)
                    : "—";

            return Row(
              children: [
                Expanded(
                  child: _statCard(
                    label: "harvested".tr,
                    value: harvestedKg == null ? "—" : "$harvestedKg kg",
                    sub: "",
                    bg: Colors.white,
                    valueColor: AppColors.blackColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    label: "revenue".tr,
                    value: revenue == null ? "—" : "₹$revenue",
                    sub: "",
                    bg: Colors.white,
                    valueColor: _green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    label: "fcr".tr,
                    value: fcrText,
                    sub: "",
                    bg: Colors.white,
                    valueColor: AppColors.blackColor,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 18),

          Obx(() {
            final resp = _harvestController.harvestDataResponce.value;

            if (resp.harvests == null) {
              return _harvestListShimmer();
            }

            final list = resp.harvests ?? [];

            if (list.isEmpty) {
              return _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textName: "no_harvests_yet".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor: AppColors.blackColor,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      textName: "record_harvest_to_track".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ],
                ),
              );
            }

            final sorted = [...list]..sort((a, b) {
              final da = a.date ?? DateTime(1970);
              final db = b.date ?? DateTime(1970);
              return db.compareTo(da);
            });

            return Column(
              children: [
                for (int i = 0; i < sorted.length; i++) ...[
                  _harvestRow(sorted[i]),
                  if (i != sorted.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _harvestRow(harvest.Harvest h) {
    final isFinal = (h.harvestType ?? "").toLowerCase() == "final";

    final dateStr = h.date != null ? _formatDayMonth(h.date!) : "—";

    final qty = h.quantityHarvested ?? "—";
    final size = h.averageSizeAtHarvest ?? "—";
    final amount = h.totalAmount ?? "—";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color:
                      isFinal
                          ? const Color(0xFFE7F2EA)
                          : const Color(0xFFEFF3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(
                  textName: h.harvestType ?? "—",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.medium,
                  textColor: isFinal ? _green : Colors.grey.shade700,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              CustomText(
                textName: dateStr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade600,
                fontSize: 11,
              ),
              const Spacer(),
              CustomText(
                textName: "₹$amount",
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: _green,
                fontSize: 14,
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              CustomText(
                textName: "$qty kg",
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.semiBold,
                textColor: AppColors.blackColor,
                fontSize: 13,
              ),
              const SizedBox(width: 6),
              CustomText(
                textName: "×",
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade600,
                fontSize: 12,
              ),
              const SizedBox(width: 6),
              CustomText(
                textName: "₹$size/kg",
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade700,
                fontSize: 13,
              ),
              const Spacer(),
              if ((h.marketName ?? "").isNotEmpty)
                CustomText(
                  textName: h.marketName!,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade500,
                  fontSize: 10,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _harvestListShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          for (int i = 0; i < 3; i++) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 70,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 150,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            if (i != 2) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoBlock({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textName: label,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.grey.shade600,
          fontSize: 11,
        ),
        const SizedBox(height: 4),
        CustomText(
          textName: value,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: valueColor,
          fontSize: 14,
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String sub,
    required Color bg,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: label,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade600,
            fontSize: 10,
          ),
          const SizedBox(height: 6),
          CustomText(
            textName: value,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: valueColor,
            fontSize: 13,
          ),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            CustomText(
              textName: sub,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade600,
              fontSize: 10,
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniBlock({
    required String label,
    required String value,
    required String sub,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textName: label,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.grey.shade600,
          fontSize: 10,
        ),
        const SizedBox(height: 4),
        CustomText(
          textName: value,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: AppColors.blackColor,
          fontSize: 13,
        ),
        const SizedBox(height: 2),
        CustomText(
          textName: sub,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.grey.shade600,
          fontSize: 10,
        ),
      ],
    );
  }

  Widget _logRow(String date, String qty, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: CustomText(
              textName: date,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 70,
            child: CustomText(
              textName: qty,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: AppColors.blackColor,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: CustomText(
              textName: info,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 11,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.18),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _FeedStockSummary {
  final double purchasedKg;
  final double purchasedAmount;
  final double consumedKg;
  final double consumedAmount;
  final double closingKg;
  final double closingAmount;
  final double avgCostPerKg;

  _FeedStockSummary({
    required this.purchasedKg,
    required this.purchasedAmount,
    required this.consumedKg,
    required this.consumedAmount,
    required this.closingKg,
    required this.closingAmount,
    required this.avgCostPerKg,
  });
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final strokeWidth = 22.0;

    final segments = [
      {"value": 0.68, "color": const Color(0xFF3F51B5)},
      {"value": 0.02, "color": const Color(0xFFF9A825)},
      {"value": 0.25, "color": const Color(0xFF1B9C4A)},
      {"value": 0.05, "color": const Color(0xFF616161)},
    ];

    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      final sweep = (seg["value"] as double) * 2 * math.pi;
      final paint =
          Paint()
            ..color = seg["color"] as Color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeedingFcrTabWidget extends StatefulWidget {
  final String tankId;
  final String farmId;
  final String doc;
  const _FeedingFcrTabWidget({
    required this.tankId,
    required this.farmId,
    this.doc = "1",
  });

  @override
  State<_FeedingFcrTabWidget> createState() => _FeedingFcrTabWidgetState();
}

class _FeedingFcrTabWidgetState extends State<_FeedingFcrTabWidget> {
  final Color _primary = const Color(0xFF087FC1);
  final Color _primaryDark = const Color(0xFF005A9C);

  late final HomeFeedingFcrController _homeFeedingController;
  late final SpeciesController _speciesController;
  late final PurchaseController _purchaseController;
  late final BiomassController _biomassController;
  late final LogFeedingController _logFeedingController;

  species.Datum? _selectedSpecies;

  final TextEditingController _dateController = TextEditingController(
    text: "select_date".tr,
  );
  final TextEditingController _biomassInputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<HomeFeedingFcrController>()) {
      _homeFeedingController = Get.find<HomeFeedingFcrController>();
    } else {
      _homeFeedingController = Get.put(
        HomeFeedingFcrController(OverviewService()),
      );
    }

    if (Get.isRegistered<SpeciesController>()) {
      _speciesController = Get.find<SpeciesController>();
    } else {
      _speciesController = Get.put(SpeciesController(OverviewService()));
    }

    _speciesController.fetchspeciesdata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

    if (Get.isRegistered<PurchaseController>()) {
      _purchaseController = Get.find<PurchaseController>();
    } else {
      _purchaseController = Get.put(PurchaseController(OverviewService()));
    }

    if (Get.isRegistered<BiomassController>()) {
      _biomassController = Get.find<BiomassController>();
    } else {
      _biomassController = Get.put(BiomassController(OverviewService()));
    }
    _biomassController.fetchbiomassdata(
      farmId: widget.farmId,
      tankId: widget.tankId,
    );

    if (Get.isRegistered<LogFeedingController>()) {
      _logFeedingController = Get.find<LogFeedingController>();
    } else {
      _logFeedingController = Get.put(LogFeedingController(OverviewService()));
    }
    _logFeedingController.fetchlogfeedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
      speciesId: _selectedSpecies?.id ?? "",
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _biomassInputController.dispose();
    super.dispose();
  }

  void _refreshFcr() {
    final speciesId = _selectedSpecies?.id ?? "";
    if (speciesId.isEmpty) return;

    final purchaseList = _purchaseController.purchaseDataResponce.value.data;
    final purchaseId =
        (purchaseList != null && purchaseList.isNotEmpty)
            ? (purchaseList.first.id ?? "")
            : "";

    _homeFeedingController.fetchfeedingfcrdata(
      speciesId: speciesId,
      tankId: widget.tankId,
      purchaseId: purchaseId,
      farmId: widget.farmId,
    );
  }

  final _overviewservice = Get.find<OverviewService>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "crop_cycle".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: AppColors.blackColor,
            fontSize: 13,
          ),
          const SizedBox(height: 8),
          _buildSpeciesDropdown(),
          const SizedBox(height: 14),
          _buildSummaryCard(),
          const SizedBox(height: 14),
          _buildBiomassCard(),
          const SizedBox(height: 14),
          _buildDailyFeedCard(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final data = _homeFeedingController.homefeedfcrDataResponce.value.data;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primary, _primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _summaryBlock(widget.doc, "culture_day".tr)),
                Expanded(
                  child: _summaryBlock(
                    data?.todaysFeed == null ? "—" : "${data!.todaysFeed} kg",
                    "todays_feed".tr,
                  ),
                ),
                Expanded(
                  child: _summaryBlock(
                    data?.cumulativeFeed == null
                        ? "—"
                        : "${data!.cumulativeFeed} kg",
                    "cumulative_feed".tr,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _summaryBlock(
                    data?.latestBiomass == null
                        ? "—"
                        : "${data!.latestBiomass} kg",
                    "latest_biomass".tr,
                  ),
                ),
                Expanded(
                  child: _summaryBlock(
                    data?.firstBiomass == null
                        ? "—"
                        : "${data!.firstBiomass} kg",
                    "starting_biomass".tr,
                  ),
                ),
                Expanded(
                  child: _summaryBlock(
                    data?.estimatedFcr == null
                        ? "—"
                        : data!.estimatedFcr!.toStringAsFixed(2),
                    "estimated_fcr".tr,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBiomassCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  textName: "biomass_estimates".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 13,
                ),
              ),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: _showAddEstimateDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: CustomText(
                    textName: "add_estimate".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final resp = _biomassController.biomassDataResponce.value;
            if (resp.data == null) return _biomassShimmer();
            final list = resp.data ?? [];

            if (list.isEmpty) {
              return CustomText(
                textName: "no_estimates_yet".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade500,
                fontSize: 10,
              );
            }

            final sorted = [...list]..sort((a, b) {
              final da = a.date ?? DateTime(1970);
              final db = b.date ?? DateTime(1970);
              return db.compareTo(da);
            });

            return Column(
              children: [
                for (int i = 0; i < sorted.length; i++) ...[
                  _biomassRow(sorted[i]),
                  if (i != sorted.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _biomassShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          for (int i = 0; i < 2; i++) ...[
            Row(
              children: [
                Container(
                  width: 46,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 120,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            if (i != 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _biomassRow(biomass.Datum b) {
    final dateStr =
        b.date != null ? "${b.date!.day} ${_monthShort(b.date!.month)}" : "—";
    final biomassKg = b.estimaTedBiomassKg ?? "—";
    final abw = b.averageBodyWeight ?? "—";
    final surv = b.survival ?? "—";
    final remark = (b.reamrks ?? "").trim();

    final meta =
        "ABW $abw g · $surv% ${"surv_short".tr}.${remark.isNotEmpty ? " · $remark" : ""}";

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: CustomText(
            textName: dateStr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: AppColors.blackColor,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 10),
        CustomText(
          textName: "$biomassKg kg",
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: AppColors.blackColor,
          fontSize: 11,
        ),
        const Spacer(),
        Flexible(
          child: CustomText(
            textName: meta,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade500,
            fontSize: 10,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyFeedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "daily_feed".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: AppColors.blackColor,
            fontSize: 13,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _headerCell("day".tr, flex: 2),
              _headerCell("kg".tr, flex: 3),
            ],
          ),
          Divider(height: 14, color: Colors.grey.shade200),
          Obx(() {
            final resp = _logFeedingController.logfeedDataResponce.value;
            if (resp.data == null) return _dailyFeedShimmer();
            final list = resp.data ?? [];

            if (list.isEmpty) {
              return CustomText(
                textName: "no_feedings_yet".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade500,
                fontSize: 10,
              );
            }

            final sorted = [...list]..sort((a, b) {
              final da = a.date ?? DateTime(1970);
              final db = b.date ?? DateTime(1970);
              return db.compareTo(da);
            });

            return Column(
              children: [
                for (int i = 0; i < sorted.length; i++) ...[
                  _dailyFeedRow(sorted[i]),
                  if (i != sorted.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _dailyFeedRow(logfeeding.Datum item) {
    final dateStr =
        item.date != null
            ? "${item.date!.day} ${_monthShort(item.date!.month)}"
            : "—";
    final kg = item.kg ?? "—";

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomText(
            textName: dateStr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: AppColors.blackColor,
            fontSize: 11,
          ),
        ),
        Expanded(
          flex: 3,
          child: CustomText(
            textName: "$kg kg",
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: AppColors.blackColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _dailyFeedShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          for (int i = 0; i < 2; i++) ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            if (i != 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeciesDropdown() {
    return Obx(() {
      final response = _speciesController.speciesDataResponce.value;

      if (response.data == null) {
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
            ),
          ),
        );
      }

      final speciesList = response.data!;

      if (speciesList.isEmpty) {
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: CustomText(
              textName: "no_species_available".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        );
      }

      species.Datum? matched;
      if (_selectedSpecies != null) {
        for (final s in speciesList) {
          if (s.id == _selectedSpecies!.id) {
            matched = s;
            break;
          }
        }
      }

      if (matched == null) {
        matched = speciesList.first;
      }

      final species.Datum safeValue = matched;
      if (_selectedSpecies?.id != safeValue.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_selectedSpecies?.id != safeValue.id) {
            setState(() => _selectedSpecies = safeValue);
            _refreshFcr();
          }
        });
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<species.Datum>(
            value: safeValue,
            isExpanded: true,
            hint: CustomText(
              textName: "select_species".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 12,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade700,
              size: 18,
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items:
                speciesList.map((s) {
                  return DropdownMenuItem<species.Datum>(
                    value: s,
                    child: CustomText(
                      textName: s.speciesName ?? "unnamed".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: AppColors.blackColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedSpecies = value);
              _refreshFcr();
            },
          ),
        ),
      );
    });
  }

  void _showAddEstimateDialog() {
    final TextEditingController dateCtrl = TextEditingController(
      text: "select_date".tr,
    );
    final TextEditingController biomassCtrl = TextEditingController();
    final TextEditingController abwCtrl = TextEditingController();
    final TextEditingController survivalCtrl = TextEditingController();
    final TextEditingController remarksCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    textName: "biomass_estimate".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 18),
                  _dialogLabel("date_of_estimate".tr),
                  const SizedBox(height: 6),
                  _textField(
                    controller: dateCtrl,
                    hint: "dd_mm_yyyy".tr,
                    suffixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        dateCtrl.text =
                            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _dialogLabel("estimated_biomass_kg".tr),
                  const SizedBox(height: 6),
                  _textField(
                    controller: biomassCtrl,
                    hint: "",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogLabel("avg_body_weight_g".tr),
                            const SizedBox(height: 6),
                            _textField(
                              controller: abwCtrl,
                              hint: "",
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogLabel("survival_percent".tr),
                            const SizedBox(height: 6),
                            _textField(
                              controller: survivalCtrl,
                              hint: "",
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _dialogLabel("remarks".tr),
                  const SizedBox(height: 6),
                  _textField(controller: remarksCtrl, hint: ""),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: CustomText(
                              textName: "cancel".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.semiBold,
                              textColor: AppColors.blackColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _overviewservice.useraddbiomassapi(
                                tankId: widget.tankId,
                                date: dateCtrl.text,
                                estimaTedBiomassKg: biomassCtrl.text,
                                averageBodyWeight: abwCtrl.text,
                                survival: survivalCtrl.text,
                                reamrks: remarksCtrl.text,
                                farmId: widget.farmId,
                              );
                              _biomassController.fetchbiomassdata(
                                farmId: widget.farmId,
                                tankId: widget.tankId,
                              );
                              _refreshFcr();
                              if (mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: CustomText(
                              textName: "save".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.semiBold,
                              textColor: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _monthShort(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    if (m < 1 || m > 12) return "";
    return months[m - 1];
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        suffixIcon:
            suffixIcon != null
                ? Icon(suffixIcon, size: 16, color: Colors.grey.shade600)
                : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
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
          borderSide: BorderSide(color: _primary, width: 1.6),
        ),
      ),
    );
  }

  Widget _dialogLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.regular,
      textColor: Colors.grey.shade800,
      fontSize: 12,
    );
  }

  Widget _summaryBlock(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textName: value,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: Colors.white,
          fontSize: 14,
        ),
        const SizedBox(height: 2),
        CustomText(
          textName: label,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.white70,
          fontSize: 9,
        ),
      ],
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.semiBold,
        textColor: Colors.grey.shade700,
        fontSize: 10,
      ),
    );
  }
}

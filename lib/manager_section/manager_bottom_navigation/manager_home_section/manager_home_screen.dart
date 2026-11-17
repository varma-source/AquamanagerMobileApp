import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_images.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/manager_section/manager_bottom_navigation/manager_home_section/manager_add_expence.dart';
import 'package:superapp/manager_section/manager_bottom_navigation/manager_home_section/manager_log_feed_screen.dart';
import 'package:superapp/manager_section/manager_bottom_navigation/manager_home_section/manager_log_medicine_use.dart';
import 'package:superapp/model/over_view/home_tank_over_view_model.dart';
import 'package:superapp/model/staff_module/staff_home_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/staff_module_service.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_tank_over_view_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_home_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_profile_controller.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  // 🎨 Requested Ocean Palette
  final Color _primary = const Color(0xFF087FC1);
  final Color _primaryDark = const Color(0xFF005A9C);
  final Color _cream = const Color(0xFFEDF6F9);
  final Color _green = const Color(0xFF1B9C4A);

  // ✅ Controllers
  late final StaffHomeController _homeController;
  late final StaffProfileController _staffprofileController;

  // ✅ Per-tank overview controllers
  final Map<String, HomeTankOverViewController> _overviewControllers = {};

  // ✅ Local loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<StaffHomeController>()) {
      _homeController = Get.find<StaffHomeController>();
    } else {
      _homeController = Get.put(StaffHomeController(StaffModuleService()));
    }

    if (Get.isRegistered<StaffProfileController>()) {
      _staffprofileController = Get.find<StaffProfileController>();
    } else {
      _staffprofileController = Get.put(
        StaffProfileController(StaffModuleService()),
      );
    }

    // ✅ Trigger a fresh fetch every time this screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });

    // ✅ Spawn per-tank overview controllers when tanks data arrives
    ever(_homeController.staffprofileDataResponce, (data) {
      final tanks = data.data ?? [];
      for (final t in tanks) {
        final tid = t.id ?? t.tankId ?? "";
        if (tid.isEmpty) continue;

        if (!_overviewControllers.containsKey(tid)) {
          final oc = Get.put(
            HomeTankOverViewController(OverviewService()),
            tag: "overview_$tid",
          );
          _overviewControllers[tid] = oc;
          oc.fetchhomeoverviewdata(tankId: tid, farmId: t.farmId ?? "");
        }
      }
    });
  }

  /// ✅ Refresh profile + tanks. Shows shimmer until tanks data arrives.
  Future<void> _refreshAll() async {
    setState(() => _isLoading = true);

    try {
      _staffprofileController.fetchstaffprofiledata();
    } catch (e) {
      debugPrint("profile fetch error: $e");
    }

    try {
      _homeController.fetchstaffhomedata();
    } catch (e) {
      debugPrint("home fetch error: $e");
    }

    final completer = Completer<void>();

    final Worker worker = ever(_homeController.staffprofileDataResponce, (data) {
      if (data.data != null && !completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      if (_homeController.staffprofileDataResponce.value.data != null &&
          !completer.isCompleted) {
        completer.complete();
      }

      await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
    } catch (_) {
      // swallow
    } finally {
      worker.dispose();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (final entry in _overviewControllers.entries) {
      Get.delete<HomeTankOverViewController>(
        tag: "overview_${entry.key}",
        force: true,
      );
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ TIME-BASED GREETING
  // ═══════════════════════════════════════════════════════════
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "good_morning".tr;
    } else if (hour >= 12 && hour < 17) {
      return "good_afternoon".tr;
    } else if (hour >= 17 && hour < 21) {
      return "good_evening".tr;
    } else {
      return "good_night".tr;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ TANK TYPE → IMAGE MAPPING
  // ═══════════════════════════════════════════════════════════
  String _getTankImage(String? tankType) {
    final type = (tankType ?? "").toLowerCase().trim();
    if (type == "fish") {
      return AppImages.fishimage;
    }
    return AppImages.prawnimage;
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ DOC LOGIC
  // ═══════════════════════════════════════════════════════════
  int? _docFromDatum(Datum tank) {
    final tid = tank.id ?? tank.tankId ?? "";
    if (tid.isEmpty) return null;

    final controller = _overviewControllers[tid];
    if (controller == null) return null;

    final resp = controller.hometankoverviewDataResponce.value;
    final overviewList = resp.overview;
    if (overviewList == null) return null;

    if (overviewList.isEmpty) return 0;

    final stocks = overviewList.first.stocks ?? [];
    return _docFromStocks(stocks);
  }

  int _docFromStocks(List<Stock> stocks) {
    if (stocks.isEmpty) return 0;

    DateTime? earliest;
    for (final s in stocks) {
      final d = _parseDate(s.date);
      if (d == null) continue;
      if (earliest == null || d.isBefore(earliest)) earliest = d;
    }
    if (earliest == null) return 0;

    final start = DateTime(earliest.year, earliest.month, earliest.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final diffDays = today.difference(start).inDays;
    return diffDays < 0 ? 0 : diffDays;
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

  // ═══════════════════════════════════════════════════════════
  // ✅ BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- PREMIUM HEADER ----------
            _buildPremiumHeader(),

            const SizedBox(height: 20),

            // ---------- SECTION TITLE ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_primary, _primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        textName: "your_assigned_tanks".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: _primaryDark,
                        fontSize: 18,
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        textName: "tap_to_log".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ---------- TANK LIST ----------
            Expanded(
              child: Obx(() {
                final response = _homeController.staffprofileDataResponce.value;
                final List<Datum>? tanks = response.data;

                if (_isLoading || tanks == null) {
                  return _buildShimmerList();
                }

                if (tanks.isEmpty) {
                  return _buildEmptyState();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (int i = 0; i < tanks.length; i++) ...[
                        _buildTankCard(
                          tank: tanks[i],
                          tankName: tanks[i].tankName ?? "Unnamed Tank",
                          farmName: tanks[i].farmName ?? "",
                          tankType: tanks[i].tankType ?? "",
                          pondSize: tanks[i].pondSize ?? "",
                        ),
                        const SizedBox(height: 18),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ PREMIUM HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A8FD9), Color(0xFF087FC1), Color(0xFF004F8C)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 60,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.waves_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      CustomText(
                        textName: "aqua_manager".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: Colors.white,
                        fontSize: 13,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            CustomText(
                              textName: "online".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.medium,
                              textColor: Colors.white,
                              fontSize: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    "hello_wave".tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final name =
                        _staffprofileController
                            .staffprofileDataResponce
                            .value
                            .data
                            ?.name ??
                        "";
                    return CustomText(
                      textName: "${_getGreeting()}, $name",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor: Colors.white,
                      fontSize: 20,
                    );
                  }),
                  const SizedBox(height: 8),
                  CustomText(
                    textName: "tank_overview_today".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.white.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ EMPTY STATE
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primary.withOpacity(0.15),
                  _primaryDark.withOpacity(0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop_outlined,
              size: 44,
              color: _primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 18),
          CustomText(
            textName: "no_tanks_assigned".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: Colors.grey.shade700,
            fontSize: 15,
          ),
          const SizedBox(height: 6),
          CustomText(
            textName: "tanks_will_appear".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade400,
            fontSize: 12,
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
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildShimmerTankCard(),
            const SizedBox(height: 18),
            _buildShimmerTankCard(),
            const SizedBox(height: 18),
            _buildShimmerTankCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTankCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 130,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 90,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 70,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: 95,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(child: _buildShimmerActionButton()),
                const SizedBox(width: 10),
                Expanded(child: _buildShimmerActionButton()),
                const SizedBox(width: 10),
                Expanded(child: _buildShimmerActionButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerActionButton() {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 65,
            height: 11,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ PREMIUM INDIVIDUAL TANK CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildTankCard({
    required Datum tank,
    required String tankName,
    required String farmName,
    required String tankType,
    required String pondSize,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.12),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---------- CARD HEADER ----------
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primary, _primaryDark],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    top: -35,
                    right: -25,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -40,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 70,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        width: 120,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                        child: Image.asset(
                          _getTankImage(tankType),
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 18,
                    right: 78,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          textName: tankName,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.bold,
                          textColor: Colors.white,
                          fontSize: 19,
                        ),
                        if (farmName.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 11,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: CustomText(
                                  textName: farmName,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.regular,
                                  textColor: Colors.white.withOpacity(0.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (pondSize.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.8,
                              ),
                            ),
                            child: CustomText(
                              textName: "${"pond_size".tr}: $pondSize",
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.medium,
                              textColor: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.28),
                            Colors.white.withOpacity(0.12),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() {
                            final doc = _docFromDatum(tank);
                            if (doc == null) {
                              return Container(
                                width: 24,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }
                            return CustomText(
                              textName: "$doc",
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.bold,
                              fontSize: 16,
                              textColor: Colors.white,
                            );
                          }),
                          CustomText(
                            textName: "DOC",
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.medium,
                            fontSize: 9,
                            textColor: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- CARD BODY (EQUAL-SIZED BUTTONS) ----------
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 76,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Get.to(
                          ManagerLogFeedScreen(
                            farmId: tank.farmId ?? "",
                            tankId: tank.tankId ?? "",
                            tankName: tank.tankName ?? "",
                          ),
                        );
                      },
                      child: _buildActionButton(
                        icon: Icons.eco_outlined,
                        iconColor: _green,
                        label: "log_feed".tr,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 76,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Get.to(
                          ManagerLogMedicineUse(
                            farmId: tank.farmId ?? "",
                            tankId: tank.tankId ?? "",
                          ),
                        );
                      },
                      child: _buildActionButton(
                        icon: Icons.medication_outlined,
                        iconColor: _primary,
                        label: "log_medicine".tr,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 76,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Get.to(
                          ManagerAddExpence(
                            farmId: tank.farmId ?? "",
                            tankId: tank.tankId ?? "",
                          ),
                        );
                      },
                      child: _buildActionButton(
                        icon: Icons.request_quote_outlined,
                        iconColor: _primaryDark,
                        label: "log_expense".tr,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ ACTION BUTTON — EQUAL SIZE FOR ALL THREE
  // ═══════════════════════════════════════════════════════════
  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            iconColor.withOpacity(0.09),
            iconColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.14),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: CustomText(
              textName: label,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.medium,
              textColor: const Color(0xFF4B5563),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/home_tank_over_view_model.dart';
import 'package:superapp/model/staff_module/staff_crop_drop_model.dart';
import 'package:superapp/model/staff_module/staff_feed_drop_model.dart';
import 'package:superapp/services/manager_module_service.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/staff_module_service.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_tank_over_view_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_crop_drop_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_feed_drop_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_get_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_get_biomass_controller.dart';

class ManagerLogFeedScreen extends StatefulWidget {
  final String farmId;
  final String tankId;
  final String tankName;

  const ManagerLogFeedScreen({
    super.key,
    required this.farmId,
    required this.tankId,
    required this.tankName,
  });

  @override
  State<ManagerLogFeedScreen> createState() => _ManagerLogFeedScreenState();
}

class _ManagerLogFeedScreenState extends State<ManagerLogFeedScreen> {
  // 🎨 Colors
  final Color _bgColor = const Color(0xFFF3F4F6);
  final Color _primaryDark = const Color(0xFF1E3A5F);
  final Color _primaryLight = const Color(0xFF2E5077);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _inputBg = const Color(0xFFFFFFFF);
  final Color _errorColor = const Color(0xFFEF4444);
  final Color _green = const Color(0xFF1B9C4A);

  // Controllers
  late final ManagerModuleService _managermoduleService;
  late final StaffCropDropController _cropController;
  late final StaffFeedDropController _feedController;
  late final StaffGetFeedController _getFeedController;
  late final StaffGetBiomassController _getBiomassController;
  late final HomeTankOverViewController _overviewController;

  // Input controllers
  final TextEditingController _dateController = TextEditingController();

  // State
  Species? _selectedCrop;
  bool _isSubmitting = false;
  bool _isInitializing = true;
  String? _initError;

  // ✅ 4 Fixed feeding cards
  final List<_FeedingState> _feedings = [];

  // ✅ Track exact feeding index for log (F1, F2, F3, F4)
  final Map<String, int> _logFeedIndexMap = {};
  final Map<int, String> _feedingLogIds = {};

  // Session-level usage tracking
  final Map<String, double> _sessionUsed = {};

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      _feedings.add(_FeedingState(index: i));
    }

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      if (Get.isRegistered<ManagerModuleService>()) {
        _managermoduleService = Get.find<ManagerModuleService>();
      } else {
        _managermoduleService = Get.put(ManagerModuleService());
      }

      _cropController =
          Get.isRegistered<StaffCropDropController>()
              ? Get.find<StaffCropDropController>()
              : Get.put(StaffCropDropController(StaffModuleService()));

      _feedController =
          Get.isRegistered<StaffFeedDropController>()
              ? Get.find<StaffFeedDropController>()
              : Get.put(StaffFeedDropController(StaffModuleService()));

      _getFeedController =
          Get.isRegistered<StaffGetFeedController>()
              ? Get.find<StaffGetFeedController>()
              : Get.put(StaffGetFeedController(StaffModuleService()));

      _getBiomassController =
          Get.isRegistered<StaffGetBiomassController>()
              ? Get.find<StaffGetBiomassController>()
              : Get.put(StaffGetBiomassController(StaffModuleService()));

      final overviewTag = "overview_${widget.tankId}";
      if (Get.isRegistered<HomeTankOverViewController>(tag: overviewTag)) {
        _overviewController = Get.find<HomeTankOverViewController>(
          tag: overviewTag,
        );
      } else {
        _overviewController = Get.put(
          HomeTankOverViewController(OverviewService()),
          tag: overviewTag,
        );
        _safeFetch(
          () => _overviewController.fetchhomeoverviewdata(
            tankId: widget.tankId,
            farmId: widget.farmId,
          ),
        );
      }

      final now = DateTime.now();
      _dateController.text =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      _safeFetch(
        () => _cropController.fetchstaffcropdropdata(
          tankId: widget.tankId,
          farmId: widget.farmId,
        ),
      );
      _safeFetch(
        () => _feedController.fetchstafffeeddropdata(
          tankId: widget.tankId,
          farmId: widget.farmId,
        ),
      );
      _safeFetch(
        () => _getBiomassController.fetchstaffgetbiomassdata(
          tankId: widget.tankId,
          farmId: widget.farmId,
        ),
      );

      ever(_cropController.staffcropdropDataResponce, (resp) {
        final crops = resp.species ?? [];
        if (crops.isEmpty) return;
        if (_selectedCrop == null) {
          _selectedCrop = crops.first;
          _fetchFeedLogs();
        }
      });

      if (mounted) setState(() => _isInitializing = false);
    } catch (e, st) {
      debugPrint('ManagerLogFeedScreen bootstrap failed: $e\n$st');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initError = e.toString();
        });
      }
    }
  }

  void _safeFetch(Function fn) {
    Future.microtask(() async {
      try {
        final dynamic result = fn();
        if (result is Future) {
          await result;
        }
      } catch (e, st) {
        debugPrint('Fetch error: $e\n$st');
      }
    });
  }

  void _fetchFeedLogs() {
    if (_selectedCrop == null) return;
    _safeFetch(
      () => _getFeedController.fetchstaffgetfeedata(
        tankId: widget.tankId,
        farmId: widget.farmId,
        speciesId: _selectedCrop!.id ?? "",
      ),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _syncFeedingsState();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    for (final f in _feedings) {
      f.kgController.dispose();
      f.remarksController.dispose();
    }
    super.dispose();
  }

  double _toDouble(String? v) => double.tryParse((v ?? "").trim()) ?? 0.0;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  bool _isDateSelected() {
    final t = _dateController.text.trim();
    return t.isNotEmpty && DateTime.tryParse(t) != null;
  }

  double _sessionUsedFor(String purchaseId) => _sessionUsed[purchaseId] ?? 0.0;

  String? _purchaseIdOf(dynamic log) {
    try {
      final dynamic json = (log as dynamic).toJson();
      if (json is Map) {
        final v =
            json['purchaseId'] ??
            json['purchase_id'] ??
            json['feedId'] ??
            json['feed_id'];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
    } catch (_) {}
    return null;
  }

  double _serverUsedFor(String purchaseId) {
    final logs = _getFeedController.staffgetfeedDataResponce.value.data ?? [];
    if (logs.isEmpty) return 0.0;

    final feeds =
        _feedController.stafffeeddropDataResponce.value.purchases ?? [];
    final onlyOneFeed = feeds.length == 1;

    double used = 0.0;
    for (final log in logs) {
      final kg = _toDouble(log.kg);
      if (kg <= 0) continue;
      final pid = _purchaseIdOf(log);
      if (pid != null) {
        if (pid == purchaseId) used += kg;
      } else if (onlyOneFeed) {
        used += kg;
      }
    }
    return used;
  }

  double _usedFor(Purchase? feed) {
    if (feed == null) return 0.0;
    final id = feed.id ?? "";
    final session = _sessionUsedFor(id);
    final server = _serverUsedFor(id);
    return session > server ? session : server;
  }

  double _availableFor(Purchase? feed) {
    if (feed == null) return 0.0;
    final purchased = _toDouble(feed.quantityPurchased);
    final left = purchased - _usedFor(feed);
    return left < 0 ? 0.0 : left;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // ✅ Restrict previous dates
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryDark,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _syncFeedingsState();
    }
  }

  /// ✅ Parse "F1".."F4" (case-insensitive) into 0..3, or null if invalid.
  int? _indexFromFeedingType(String? feedingType) {
    if (feedingType == null) return null;
    final t = feedingType.trim().toUpperCase();
    final match = RegExp(r'^F([1-4])$').firstMatch(t);
    if (match == null) return null;
    return int.parse(match.group(1)!) - 1;
  }

  // ✅ STRICT SYNC: Binds API data strictly to the original saved index
  void _syncFeedingsState() {
    if (!_isDateSelected()) return;

    final logs = _getFeedController.staffgetfeedDataResponce.value.data ?? [];
    final picked = DateTime.tryParse(_dateController.text.trim());
    if (picked == null) return;

    final List<dynamic> todayLogs = [];
    for (final log in logs) {
      if (log.date != null &&
          log.date!.year == picked.year &&
          log.date!.month == picked.month &&
          log.date!.day == picked.day) {
        todayLogs.add(log);
      }
    }

    for (int i = 0; i < 4; i++) {
      if (!_feedings[i].isSaving && !_feedings[i].isSaved) {
        final bool isEditing =
            _feedings[i].kgController.text.trim().isNotEmpty;

        if (!isEditing) {
          _feedings[i].kgController.clear();
          _feedings[i].remarksController.clear();
          _feedings[i].feedType = null;
          _feedingLogIds.remove(i);
        }
      }
    }

    for (final log in todayLogs) {
      final logId = log.id ?? "";
      if (logId.isEmpty) continue;

      // ✅ Prefer server-provided feedingType, fall back to client map
      int? targetIndex = _indexFromFeedingType(log.feedingType);
      targetIndex ??= _logFeedIndexMap[logId];

      if (targetIndex != null && targetIndex >= 0 && targetIndex < 4) {
        _feedings[targetIndex].isSaved = true;
        _feedings[targetIndex].kgController.text = log.kg ?? "";
        _feedings[targetIndex].remarksController.text = log.remarks ?? "";

        final feedList =
            _feedController.stafffeeddropDataResponce.value.purchases ?? [];
        for (final p in feedList) {
          if (p.id == log.purchaseId) {
            _feedings[targetIndex].feedType = p;
            break;
          }
        }

        _feedingLogIds[targetIndex] = logId;
        _logFeedIndexMap[logId] = targetIndex;
      } else {
        // Fallback: assign to first empty card (legacy logs without feedingType)
        for (int i = 0; i < 4; i++) {
          if (_feedingLogIds[i] == null) {
            _feedingLogIds[i] = logId;
            _logFeedIndexMap[logId] = i;

            _feedings[i].isSaved = true;
            _feedings[i].kgController.text = log.kg ?? "";
            _feedings[i].remarksController.text = log.remarks ?? "";

            final feedList =
                _feedController.stafffeeddropDataResponce.value.purchases ?? [];
            for (final p in feedList) {
              if (p.id == log.purchaseId) {
                _feedings[i].feedType = p;
                break;
              }
            }
            break;
          }
        }
      }
    }

    if (mounted) setState(() {});
  }

  // ✅ SAVE: Strictly blocks saving if 4 feeds are already completed for the day
  Future<void> _saveFeeding(int index) async {
    final feeding = _feedings[index];
    if (feeding.isSaving || feeding.isSaved) return;

    if (_selectedCrop == null) {
      _snack("required".tr, "please_select_crop".tr, Colors.orange);
      return;
    }
    if (!_isDateSelected()) {
      _snack("required".tr, "please_select_date".tr, Colors.orange);
      return;
    }

    // ✅ Check if 4 feedings already exist for the selected date
    final logs = _getFeedController.staffgetfeedDataResponce.value.data ?? [];
    final picked = DateTime.tryParse(_dateController.text.trim());
    if (picked != null) {
      int todayCount = 0;
      for (final log in logs) {
        if (log.date != null &&
            log.date!.year == picked.year &&
            log.date!.month == picked.month &&
            log.date!.day == picked.day) {
          todayCount++;
        }
      }
      if (todayCount >= 4) {
        _snack(
          "limit_reached".tr,
          "max_4_feeds_per_day".tr,
          Colors.red,
        );
        return;
      }
    }

    if (feeding.feedType == null) {
      _snack("required".tr, "please_select_feed".tr, Colors.orange);
      return;
    }

    final kg = double.tryParse(feeding.kgController.text.trim());
    if (kg == null || kg <= 0) {
      _snack("required".tr, "please_enter_valid_kg".tr, Colors.orange);
      return;
    }

    final available = _availableFor(feeding.feedType);
    if (kg > available) {
      _snack(
        "not_enough_stock".tr,
        "${"only_available_prefix".tr} ${_fmt(available)} ${"kg_available_suffix".tr}",
        Colors.red,
      );
      return;
    }

    setState(() => feeding.isSaving = true);

    try {
      // ✅ feedingType is derived from the card index: F1, F2, F3, F4
      final String feedingTypeValue = "F${index + 1}";

      await _managermoduleService.usermanageraddfeed(
        tankId: widget.tankId,
        purchaseId: feeding.feedType?.id ?? "",
        farmId: widget.farmId,
        speciesId: _selectedCrop!.id ?? "",
        date: _dateController.text,
        kg: feeding.kgController.text.trim(),
        remarks: feeding.remarksController.text,
        feedingType: feedingTypeValue,
      );

      final pid = feeding.feedType?.id ?? "";
      _sessionUsed[pid] = (_sessionUsed[pid] ?? 0.0) + kg;

      // ✅ Optimistically lock the card
      setState(() {
        feeding.isSaved = true;
        feeding.isSaving = false;
      });

      _safeFetch(
        () => _getFeedController.fetchstaffgetfeedata(
          tankId: widget.tankId,
          farmId: widget.farmId,
          speciesId: _selectedCrop!.id ?? "",
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        _syncFeedingsState();
      }
    } catch (e) {
      if (mounted) setState(() => feeding.isSaving = false);
      _snack("error".tr, "${"failed_save_feeding".tr}: $e", Colors.red);
    }
  }

  void _snack(String title, String msg, Color bg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bg,
      colorText: Colors.white,
    );
  }

  int _getDOC() {
    final resp = _overviewController.hometankoverviewDataResponce.value;
    final overviewList = resp.overview ?? [];
    if (overviewList.isEmpty) return 0;
    final stocks = overviewList.first.stocks ?? [];
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

  Map<String, String> _calculateSummaryStats() {
    final logs = _getFeedController.staffgetfeedDataResponce.value.data ?? [];
    final biomassList =
        _getBiomassController.staffgetbiomassDataResponce.value.data ?? [];

    double cumulativeFeed = 0;
    for (final log in logs) {
      cumulativeFeed += double.tryParse(log.kg ?? "0") ?? 0;
    }
    double latestBiomass = 0;
    if (biomassList.isNotEmpty) {
      latestBiomass =
          double.tryParse(biomassList.first.estimaTedBiomassKg ?? "0") ?? 0;
    }
    String fcr = "0.00";
    if (latestBiomass > 0) {
      fcr = (cumulativeFeed / latestBiomass).toStringAsFixed(2);
    }
    return {
      "cumulativeFeed": cumulativeFeed.toStringAsFixed(0),
      "latestBiomass":
          latestBiomass > 0 ? latestBiomass.toStringAsFixed(0) : "0",
      "fcr": fcr,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: CustomText(
          textName: "${"feedings".tr} · ${widget.tankName}",
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: Colors.black,
          fontSize: 16,
        ),
      ),
      body:
          _initError != null
              ? _buildErrorRetry(_initError!)
              : _isInitializing
              ? _buildShimmerLoading()
              : _buildBody(),
    );
  }

  Widget _buildErrorRetry(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            CustomText(
              textName: "something_went_wrong".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: Colors.black87,
              fontSize: 15,
            ),
            const SizedBox(height: 6),
            CustomText(
              textName: error,
              fontFamily: FontFamily.poppins,
              textColor: Colors.grey,
              fontSize: 11,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initError = null;
                  _isInitializing = true;
                });
                _bootstrap();
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primaryDark),
              child: CustomText(
                textName: "retry".tr,
                fontFamily: FontFamily.poppins,
                textColor: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBlock(height: 12, width: 90),
          const SizedBox(height: 8),
          _shimmerBlock(height: 46, width: double.infinity, radius: 8),
          const SizedBox(height: 16),
          _shimmerBlock(height: 130, width: double.infinity, radius: 12),
          const SizedBox(height: 20),
          _shimmerBlock(height: 12, width: 60),
          const SizedBox(height: 8),
          _shimmerBlock(height: 46, width: double.infinity, radius: 8),
          const SizedBox(height: 16),
          _shimmerBlock(height: 210, width: double.infinity, radius: 12),
          const SizedBox(height: 16),
          _shimmerBlock(height: 210, width: double.infinity, radius: 12),
          const SizedBox(height: 16),
          _shimmerBlock(height: 210, width: double.infinity, radius: 12),
          const SizedBox(height: 16),
          _shimmerBlock(height: 210, width: double.infinity, radius: 12),
          const SizedBox(height: 20),
          _shimmerBlock(height: 220, width: double.infinity, radius: 12),
        ],
      ),
    );
  }

  Widget _shimmerBlock({
    required double height,
    required double width,
    double radius = 6,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "crop_cycle".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: Colors.grey.shade700,
            fontSize: 12,
          ),
          const SizedBox(height: 6),
          _buildCropDropdown(),
          const SizedBox(height: 16),

          _buildSummaryCard(),
          const SizedBox(height: 20),

          // Date
          CustomText(
            textName: "date".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: Colors.grey.shade700,
            fontSize: 12,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey,
              ),
              border: _outline(),
              enabledBorder: _outline(),
              focusedBorder: _outline(focused: true),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 4 Fixed Feeding Cards
          Obx(() {
            final resp = _feedController.stafffeeddropDataResponce.value;
            if (resp.purchases == null) return _buildFeedingLoadingCard();
            final feeds = resp.purchases ?? [];
            if (feeds.isEmpty) return _buildNoFeedCard();

            return Column(
              children: [
                for (int i = 0; i < 4; i++) ...[
                  _buildFeedingCard(index: i),
                  if (i != 3) const SizedBox(height: 12),
                ],
              ],
            );
          }),
          const SizedBox(height: 20),

          _buildBiomassSection(),
          const SizedBox(height: 16),

          _buildDailyFeedSection(),

          const SizedBox(height: 20),
          Center(
            child: CustomText(
              textName: "feed_footer_note".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade600,
              fontSize: 10,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  OutlineInputBorder _outline({bool focused = false}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide:
        focused
            ? BorderSide(color: _primaryDark, width: 1.5)
            : BorderSide(color: _borderColor),
  );

  Widget _emptyBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        textColor: Colors.grey,
        fontSize: 14,
      ),
    );
  }

  Widget _buildCropDropdown() {
    return Obx(() {
      final response = _cropController.staffcropdropDataResponce.value;
      if (response.species == null) {
        return _shimmerBlock(height: 46, width: double.infinity, radius: 8);
      }
      final crops = response.species!;
      if (crops.isEmpty) return _emptyBox("no_crop_cycles".tr);

      final validCrop =
          crops.any((c) => c.id == _selectedCrop?.id) ? _selectedCrop : null;

      // Auto-select first crop if none
      if (validCrop == null && _selectedCrop == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedCrop == null) {
            setState(() => _selectedCrop = crops.first);
            _fetchFeedLogs();
          }
        });
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Species>(
            value: validCrop,
            isExpanded: true,
            hint: CustomText(
              textName: "select_crop_cycle".tr,
              fontFamily: FontFamily.poppins,
              textColor: Colors.grey,
              fontSize: 14,
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            items:
                crops.map((crop) {
                  final isCurrent = crop.isCurrent == true;
                  return DropdownMenuItem<Species>(
                    value: crop,
                    child: Row(
                      children: [
                        CustomText(
                          textName: crop.speciesName ?? "Unknown",
                          fontFamily: FontFamily.poppins,
                          fontWeightType:
                              isCurrent
                                  ? FontWeightType.semiBold
                                  : FontWeightType.medium,
                          textColor: Colors.black87,
                          fontSize: 14,
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F2F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomText(
                              textName: "current_label".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.semiBold,
                              textColor: _primaryDark,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (val) {
              setState(() => _selectedCrop = val);
              if (val != null) {
                _fetchFeedLogs();
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final stats = _calculateSummaryStats();
      final docValue = _getDOC();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryLight, _primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _primaryDark.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatColumn("$docValue", "day_of_culture".tr),
                _buildStatColumn(
                  "${stats['cumulativeFeed']} kg",
                  "todays_feed".tr,
                ),
                _buildStatColumn(
                  "${stats['cumulativeFeed']} kg",
                  "cumulative_feed".tr,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatColumn(
                  "${stats['latestBiomass']} kg",
                  "latest_biomass".tr,
                ),
                _buildStatColumn("0 kg", "starting_biomass".tr),
                _buildStatColumn(stats['fcr']!, "estimated_fcr".tr),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.15), height: 1),
            const SizedBox(height: 12),
            CustomText(
              textName: "projected_fcr_note".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.white60,
              fontSize: 9,
              maxLines: 2,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          textName: value,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: Colors.white,
          fontSize: 16,
        ),
        const SizedBox(height: 2),
        CustomText(
          textName: label,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.white70,
          fontSize: 10,
        ),
      ],
    );
  }

  Widget _buildFeedingLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: _primaryDark),
          ),
          const SizedBox(width: 10),
          CustomText(
            textName: "loading_feed_stock".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade500,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _buildNoFeedCard() {
    return Container(
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
              Icon(Icons.inventory_2_outlined, size: 18, color: _primaryDark),
              const SizedBox(width: 8),
              CustomText(
                textName: "no_feed_purchased_yet".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: Colors.black87,
                fontSize: 13,
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomText(
            textName: "add_feed_purchase_first".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade600,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingCard({required int index}) {
    while (_feedings.length <= index) {
      _feedings.add(_FeedingState(index: _feedings.length));
    }

    final feeding = _feedings[index];
    final title = "${"feeding_prefix".tr} ${index + 1}";
    final locked = feeding.isSaved || feeding.isSaving;

    // ✅ Dynamically lock empty cards if 4 slots are already filled for the selected date
    final logs = _getFeedController.staffgetfeedDataResponce.value.data ?? [];
    final picked = DateTime.tryParse(_dateController.text.trim());
    int todayCount = 0;
    if (picked != null) {
      for (final log in logs) {
        if (log.date != null &&
            log.date!.year == picked.year &&
            log.date!.month == picked.month &&
            log.date!.day == picked.day) {
          todayCount++;
        }
      }
    }
    final bool isDayLimitReached = todayCount >= 4 && !locked;
    final bool finalLocked = locked || isDayLimitReached;

    final Color cardBorderColor =
        feeding.isSaved
            ? _green
            : (feeding.isSaving ? _primaryDark : _borderColor);
    final Color cardBgColor =
        feeding.isSaved ? const Color(0xFFF4FBF7) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDayLimitReached ? Colors.grey.shade50 : cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardBorderColor,
          width: feeding.isSaved ? 1.5 : 1,
        ),
        boxShadow:
            feeding.isSaved
                ? [
                  BoxShadow(
                    color: _green.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  textName: title,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: feeding.isSaved ? _green : Colors.black87,
                  fontSize: 13,
                ),
              ),
              if (feeding.isSaved)
                Icon(Icons.check_circle, color: _green, size: 20),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: feeding.kgController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: !finalLocked,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "kg_given".tr,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: _outline(),
                    enabledBorder: _outline(),
                    disabledBorder: _outline(),
                    focusedBorder: _outline(focused: true),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildFeedDropdown(feeding: feeding, locked: finalLocked)),
            ],
          ),

          // Available stock hint
          if (feeding.feedType != null && !feeding.isSaved && !isDayLimitReached) ...[
            const SizedBox(height: 6),
            Obx(() {
              _getFeedController.staffgetfeedDataResponce.value;
              final stockBefore = _availableFor(feeding.feedType);
              final entered =
                  double.tryParse(feeding.kgController.text.trim()) ?? 0.0;
              final remaining = stockBefore - entered;
              final exceeded = entered > stockBefore;

              final String msg;
              if (exceeded) {
                msg =
                    "${"only_available".tr} ${_fmt(stockBefore)} kg ${"enter_less".tr} ${_fmt(stockBefore)} kg";
              } else if (entered <= 0) {
                msg = "${"available_stock".tr}: ${_fmt(stockBefore)} kg";
              } else {
                msg =
                    "${_fmt(stockBefore)} kg ${"available_dot".tr} ${_fmt(remaining)} kg ${"remaining".tr}";
              }

              return CustomText(
                textName: msg,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: exceeded ? _errorColor : Colors.grey.shade600,
                fontSize: 10,
              );
            }),
          ],
          const SizedBox(height: 10),

          TextField(
            controller: feeding.remarksController,
            enabled: !finalLocked,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "remarks_optional".tr,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: _outline(),
              enabledBorder: _outline(),
              disabledBorder: _outline(),
              focusedBorder: _outline(focused: true),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: finalLocked ? null : () => _saveFeeding(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: feeding.isSaved ? _green : _primaryDark,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    feeding.isSaved
                        ? _green
                        : _primaryDark.withOpacity(0.5),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  feeding.isSaving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (feeding.isSaved) ...[
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                          ],
                          CustomText(
                            textName:
                                feeding.isSaved
                                    ? "saved_check".tr
                                    : "${"save_feeding".tr} $title",
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: Colors.white,
                            fontSize: 13,
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedDropdown({
    required _FeedingState feeding,
    required bool locked,
  }) {
    return Obx(() {
      final response = _feedController.stafffeeddropDataResponce.value;
      final purchases = response.purchases;

      if (purchases == null) {
        return _shimmerBlock(height: 44, width: double.infinity, radius: 8);
      }
      if (purchases.isEmpty) return _emptyBox("no_feeds".tr);

      final feeds = purchases;
      Purchase? safeValue;
      if (feeding.feedType != null) {
        for (final f in feeds) {
          if (f.id == feeding.feedType!.id) {
            safeValue = f;
            break;
          }
        }
      }

      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Purchase>(
            value: safeValue,
            isExpanded: true,
            hint: CustomText(
              textName: "select_feed".tr,
              fontFamily: FontFamily.poppins,
              textColor: Colors.grey,
              fontSize: 11,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey,
              size: 18,
            ),
            items:
                feeds.map((feed) {
                  return DropdownMenuItem<Purchase>(
                    value: feed,
                    child: CustomText(
                      textName: feed.feedName ?? "Unknown",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.black87,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
            onChanged:
                locked
                    ? null
                    : (val) {
                      setState(() => feeding.feedType = val);
                    },
          ),
        ),
      );
    });
  }

  // ==========================================================
  // BIOMASS
  // ==========================================================

  Widget _buildBiomassSection() {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                textName: "biomass_estimates".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.semiBold,
                textColor: Colors.black87,
                fontSize: 14,
              ),
              InkWell(
                onTap: _showAddEstimateDialog,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _primaryDark,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: CustomText(
                    textName: "add_biomass".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final biomassResponse =
                _getBiomassController.staffgetbiomassDataResponce.value;
            final data = biomassResponse.data;
            if (data == null) {
              return Column(
                children: [
                  _shimmerBlock(height: 20, width: double.infinity, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBlock(height: 20, width: double.infinity, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBlock(height: 20, width: double.infinity, radius: 4),
                ],
              );
            }
            if (data.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CustomText(
                    textName: "no_biomass_estimates".tr,
                    fontFamily: FontFamily.poppins,
                    textColor: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              );
            }
            return Column(
              children:
                  data.map((item) {
                    final dateStr =
                        item.date != null
                            ? "${item.date!.day} ${_getMonthShort(item.date!.month)}"
                            : "—";
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildBiomassRow(
                        date: dateStr,
                        kg: "${item.estimaTedBiomassKg ?? '0'} kg",
                        extra:
                            "ABW ${item.averageBodyWeight ?? '—'} g · ${item.survival ?? '—'}% ${"surv_short".tr} · ${item.reamrks ?? ''}",
                      ),
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBiomassRow({
    required String date,
    required String kg,
    required String extra,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: CustomText(
            textName: date,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: Colors.black87,
            fontSize: 12,
          ),
        ),
        SizedBox(
          width: 70,
          child: CustomText(
            textName: kg,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: Colors.black87,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: CustomText(
            textName: extra,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade600,
            fontSize: 11,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ✅ DAILY FEED TABLE (Scrolling exactly like the image)
  // ==========================================================

  Widget _buildDailyFeedSection() {
    // ✅ ScrollController for the horizontal scrollbar
    final ScrollController horizontalController = ScrollController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(
                textName: "daily_feed".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: _primaryDark,
                fontSize: 15,
              ),
              const Spacer(),
              if (_selectedCrop != null)
                CustomText(
                  textName: _selectedCrop!.speciesName ?? "",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade500,
                  fontSize: 11,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── HORIZONTAL SCROLLABLE TABLE WITH SCROLLBAR ──
          Scrollbar(
            controller: horizontalController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 4.0,
            radius: const Radius.circular(10),
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800, // Fixed width to allow scrolling
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table Headers
                      Row(
                        children: [
                          _buildTableHeader("day".tr, flex: 2),
                          _buildTableHeader("F1", flex: 1),
                          _buildTableHeader("F2", flex: 1),
                          _buildTableHeader("F3", flex: 1),
                          _buildTableHeader("F4", flex: 1),
                          _buildTableHeader("daily".tr, flex: 2),
                          _buildTableHeader("cumulative".tr, flex: 2),
                          _buildTableHeader("biomass".tr, flex: 2),
                          _buildTableHeader("est_fcr".tr, flex: 2),
                        ],
                      ),
                      Divider(color: _borderColor, height: 20),

                      // Table Body
                      Obx(() {
                        final feedResponse =
                            _getFeedController.staffgetfeedDataResponce.value;
                        final logs = feedResponse.data;

                        if (_selectedCrop == null) {
                          return _centerMsg("select_crop_view".tr);
                        }
                        if (logs == null) {
                          return Column(
                            children: List.generate(
                              4,
                              (_) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _shimmerBlock(
                                  height: 18,
                                  width: double.infinity,
                                  radius: 4,
                                ),
                              ),
                            ),
                          );
                        }
                        if (logs.isEmpty) return _centerMsg("no_feed_logs".tr);

                        final Map<String, List<dynamic>> groupedByDay = {};
                        for (final log in logs) {
                          if (log.date != null) {
                            final dateKey =
                                "${log.date!.year}-${log.date!.month}-${log.date!.day}";
                            groupedByDay.putIfAbsent(dateKey, () => []).add(log);
                          }
                        }

                        final sortedKeys = groupedByDay.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        return Column(
                          children: [
                            for (int i = 0; i < sortedKeys.length; i++) ...[
                              _buildDailyFeedRow(
                                dateKey: sortedKeys[i],
                                dayLogs: groupedByDay[sortedKeys[i]]!,
                                isLatest: i == 0,
                              ),
                              if (i != sortedKeys.length - 1) const SizedBox(height: 8),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFeedRow({
    required String dateKey,
    required List<dynamic> dayLogs,
    required bool isLatest,
  }) {
    final parts = dateKey.split('-');
    final day = int.tryParse(parts[2]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final dateStr = "$day ${_getMonthShort(month)}";

    double f1 = 0, f2 = 0, f3 = 0, f4 = 0;
    double totalDaily = 0;

    for (int i = 0; i < dayLogs.length; i++) {
      final kg = double.tryParse(dayLogs[i].kg ?? "0") ?? 0;
      totalDaily += kg;

      final logId = dayLogs[i].id ?? "";
      // ✅ Prefer the server feedingType; fall back to client map then list index
      final feedingIndex =
          _indexFromFeedingType(dayLogs[i].feedingType) ??
          _logFeedIndexMap[logId] ??
          i;

      if (feedingIndex == 0) f1 = kg;
      else if (feedingIndex == 1) f2 = kg;
      else if (feedingIndex == 2) f3 = kg;
      else if (feedingIndex == 3) f4 = kg;
    }

    double cumulative = 0;
    final allLogs = _getFeedController.staffgetfeedDataResponce.value.data ?? [];
    for (final log in allLogs) {
      if (log.date != null) {
        final logDateKey =
            "${log.date!.year}-${log.date!.month}-${log.date!.day}";
        if (logDateKey.compareTo(dateKey) <= 0) {
          cumulative += double.tryParse(log.kg ?? "0") ?? 0;
        }
      }
    }

    double biomassOnDate = 0;
    final biomassList =
        _getBiomassController.staffgetbiomassDataResponce.value.data ?? [];
    for (final b in biomassList) {
      if (b.date != null) {
        final bioKey = "${b.date!.year}-${b.date!.month}-${b.date!.day}";
        if (bioKey.compareTo(dateKey) <= 0) {
          final val = double.tryParse(b.estimaTedBiomassKg ?? "0") ?? 0;
          if (val > biomassOnDate) biomassOnDate = val;
        }
      }
    }

    String fcrStr = "—";
    if (biomassOnDate > 0 && cumulative > 0) {
      fcrStr = (cumulative / biomassOnDate).toStringAsFixed(2);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textName: "$day",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: _primaryDark,
                  fontSize: 13,
                ),
                CustomText(
                  textName: dateStr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade500,
                  fontSize: 10,
                ),
              ],
            ),
          ),
          _buildTableCell(f1 > 0 ? _fmt(f1) : "—", flex: 1),
          _buildTableCell(f2 > 0 ? _fmt(f2) : "—", flex: 1),
          _buildTableCell(f3 > 0 ? _fmt(f3) : "—", flex: 1),
          _buildTableCell(f4 > 0 ? _fmt(f4) : "—", flex: 1),
          _buildTableCell(_fmt(totalDaily), flex: 2, isBold: true),
          _buildTableCell(_fmt(cumulative), flex: 2),
          _buildTableCell(biomassOnDate > 0 ? _fmt(biomassOnDate) : "—", flex: 2),
          _buildTableCell(fcrStr, flex: 2),
        ],
      ),
    );
  }

  Widget _centerMsg(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: CustomText(
          textName: text,
          fontFamily: FontFamily.poppins,
          textColor: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.semiBold,
        textColor: Colors.grey.shade600,
        fontSize: 11,
      ),
    );
  }

  Widget _buildTableCell(String text, {required int flex, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType:
            isBold ? FontWeightType.bold : FontWeightType.regular,
        textColor: isBold ? _primaryDark : Colors.black87,
        fontSize: 12,
      ),
    );
  }

  String _getMonthShort(int month) {
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
    if (month < 1 || month > 12) return "";
    return months[month - 1];
  }

  // ==========================================================
  // ADD BIOMASS DIALOG
  // ==========================================================

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
      builder: (dialogContext) {
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
                  _dialogField(
                    controller: dateCtrl,
                    hint: "2026-10-09",
                    suffixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        dateCtrl.text =
                            "${picked.year}-"
                            "${picked.month.toString().padLeft(2, '0')}-"
                            "${picked.day.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _dialogLabel("estimated_biomass_kg".tr),
                  const SizedBox(height: 6),
                  _dialogField(
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
                            _dialogField(
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
                            _dialogField(
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
                  _dialogField(controller: remarksCtrl, hint: ""),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
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
                              if (DateTime.tryParse(dateCtrl.text.trim()) ==
                                  null) {
                                _snack(
                                  "required".tr,
                                  "please_select_date".tr,
                                  Colors.orange,
                                );
                                return;
                              }
                              if (biomassCtrl.text.trim().isEmpty) {
                                _snack(
                                  "required".tr,
                                  "please_enter_biomass".tr,
                                  Colors.orange,
                                );
                                return;
                              }
                              try {
                                await _managermoduleService
                                    .usermanageraddbiomass(
                                      tankId: widget.tankId,
                                      farmId: widget.farmId,
                                      date: dateCtrl.text,
                                      estimaTedBiomassKg: biomassCtrl.text,
                                      averageBodyWeight: abwCtrl.text,
                                      survival: survivalCtrl.text,
                                      reamrks: remarksCtrl.text,
                                    );

                                _safeFetch(
                                  () => _getBiomassController
                                      .fetchstaffgetbiomassdata(
                                        tankId: widget.tankId,
                                        farmId: widget.farmId,
                                      ),
                                );
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                              } catch (e) {
                                _snack(
                                  "error".tr,
                                  "${"failed_save_biomass".tr}: $e",
                                  Colors.red,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryDark,
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

  Widget _dialogLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.regular,
      textColor: Colors.grey.shade800,
      fontSize: 12,
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
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
        border: _outline(),
        enabledBorder: _outline(),
        focusedBorder: _outline(focused: true),
      ),
    );
  }
}

// ✅ Per-feeding state
class _FeedingState {
  final TextEditingController kgController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  Purchase? feedType;
  bool isSaving = false;
  bool isSaved = false;
  final int index;

  _FeedingState({this.index = 0});
}
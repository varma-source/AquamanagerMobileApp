import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/model/over_view/biomass_model.dart' as biomass;
import 'package:superapp/model/over_view/log_feeding_model.dart' as logfeeding;
import 'package:superapp/model/over_view/log_feeding_model.dart';
import 'package:superapp/model/over_view/purchase_model.dart' as purchase;
import 'package:superapp/model/over_view/species_model.dart' as species;
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/profileService.dart';
import 'package:superapp/view_model/api_controllers/over_view/biomass_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_feeding_fcr_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/log_feeding_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/purchase_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/species_controller.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';
import 'package:superapp/model/over_view/home_tank_over_view_model.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_tank_over_view_controller.dart';

class FeedingFCRScreen extends StatefulWidget {
  final String tankId;
  final String farmId;
  const FeedingFCRScreen({
    super.key,
    required this.tankId,
    required this.farmId,
  });

  @override
  State<FeedingFCRScreen> createState() => _FeedingFCRScreenState();
}

class _FeedingFCRScreenState extends State<FeedingFCRScreen> {
  late final HomeTankOverViewController _homeController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: CustomText(
                        textName: "feedings".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: AppColors.blackColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            Expanded(
              child: Obx(() {
                final resp = _homeController.hometankoverviewDataResponce.value;
                final overviewList = resp.overview ?? [];
                final stocks =
                    overviewList.isEmpty
                        ? <Stock>[]
                        : (overviewList.first.stocks ?? []);
                final doc = _daysOfCulture(stocks);

                return FeedingFcrBody(
                  tankId: widget.tankId,
                  farmId: widget.farmId,
                  doc: doc,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedingFcrBody extends StatefulWidget {
  final String tankId;
  final String farmId;
  final String doc;
  const FeedingFcrBody({
    super.key,
    required this.tankId,
    required this.farmId,
    this.doc = "1",
  });

  @override
  State<FeedingFcrBody> createState() => _FeedingFcrBodyState();
}

class _FeedingFcrBodyState extends State<FeedingFcrBody> {
  final Color _primary = const Color(0xFF087FC1);
  final Color _primaryDark = const Color(0xFF005A9C);
  final Color _green = const Color(0xFF1B9C4A);
  final Color _red = const Color(0xFFE53935);

  late final PurchaseController _purchaseController;
  late final SpeciesController _speciesController;
  late final HomeFeedingFcrController _homeFeedingController;
  late final BiomassController _biomassController;
  late final LogFeedingController _logFeedingController;
  late final ProfileController _profileController;
  late final OverviewService _overviewservice;

  species.Datum? _selectedSpecies;
  String? _lastFetchedSpeciesId;

  final TextEditingController _dateController = TextEditingController(
    text: "select_date".tr,
  );

  final List<_FeedingState> _feedings = [];
  final TextEditingController _biomassInputController = TextEditingController();
  final Map<String, double> _sessionUsed = {};

  // ✅ Maps to track feeding indices accurately
  final Map<String, int> _logFeedIndexMap = {};
  final Map<int, String> _feedingLogIds = {};

  @override
  void initState() {
    super.initState();

    _overviewservice =
        Get.isRegistered<OverviewService>()
            ? Get.find<OverviewService>()
            : Get.put(OverviewService());

    if (Get.isRegistered<ProfileController>()) {
      _profileController = Get.find<ProfileController>();
    } else {
      _profileController = Get.put(ProfileController(ProfileService()));
    }

    if (Get.isRegistered<PurchaseController>()) {
      _purchaseController = Get.find<PurchaseController>();
    } else {
      _purchaseController = Get.put(PurchaseController(OverviewService()));
    }
    _purchaseController.fetchpurchasedata(
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

    if (Get.isRegistered<HomeFeedingFcrController>()) {
      _homeFeedingController = Get.find<HomeFeedingFcrController>();
    } else {
      _homeFeedingController = Get.put(
        HomeFeedingFcrController(OverviewService()),
      );
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

    ever(_speciesController.speciesDataResponce, (resp) {
      final speciesList = resp.data ?? [];
      if (speciesList.isEmpty) return;

      if (_selectedSpecies == null) {
        _selectedSpecies = speciesList.first;
        _lastFetchedSpeciesId = null;
        _refreshFcr();
      }
    });

    for (int i = 0; i < 4; i++) {
      _feedings.add(_FeedingState(index: i));
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    for (final f in _feedings) {
      f.kgController.dispose();
      f.remarksController.dispose();
    }
    _biomassInputController.dispose();
    super.dispose();
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _primary,
      colorText: Colors.white,
    );
  }

  double _toDouble(String? v) => double.tryParse((v ?? "").trim()) ?? 0.0;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  bool _isDateSelected() {
    final t = _dateController.text.trim();
    return t.isNotEmpty && DateTime.tryParse(t) != null;
  }

  double _sessionUsedFor(String purchaseId) => _sessionUsed[purchaseId] ?? 0.0;

  double _serverUsedFor(String purchaseId) {
    final logs = _logFeedingController.logfeedDataResponce.value.data ?? [];
    if (logs.isEmpty) return 0.0;

    final purchases = _purchaseController.purchaseDataResponce.value.data ?? [];
    final onlyOneFeed = purchases.length == 1;

    double used = 0.0;
    for (final log in logs) {
      final kg = double.tryParse((log.kg ?? "").trim()) ?? 0.0;
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

  String? _purchaseIdOf(logfeeding.Datum log) {
    try {
      final dynamic d = log;
      final dynamic json = d.toJson();
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

  double _usedFor(purchase.Datum? feed) {
    if (feed == null) return 0.0;
    final id = feed.id ?? "";
    final session = _sessionUsedFor(id);
    final server = _serverUsedFor(id);
    return session > server ? session : server;
  }

  double _availableFor(purchase.Datum? feed) {
    if (feed == null) return 0.0;
    final purchased = _toDouble(feed.quantityPurchased);
    final left = purchased - _usedFor(feed);
    return left < 0 ? 0.0 : left;
  }

  Future<void> _refreshFcr() async {
    final speciesId = _selectedSpecies?.id ?? "";
    if (speciesId.isEmpty) return;

    if (_lastFetchedSpeciesId == speciesId) return;
    _lastFetchedSpeciesId = speciesId;

    purchase.Datum? chosenFeed;
    for (final f in _feedings) {
      if (f.feedType != null) {
        chosenFeed = f.feedType;
        break;
      }
    }

    final purchaseList = _purchaseController.purchaseDataResponce.value.data;
    if (chosenFeed == null && purchaseList != null && purchaseList.isNotEmpty) {
      chosenFeed = purchaseList.first;
    }

    final purchaseId = chosenFeed?.id ?? "";

    _homeFeedingController.fetchfeedingfcrdata(
      speciesId: speciesId,
      tankId: widget.tankId,
      purchaseId: purchaseId,
      farmId: widget.farmId,
    );

    _logFeedingController.logfeedDataResponce.value = logfeeding.Logfeedingdata(
      success: null,
      message: null,
      count: 0,
      data: [],
    );

    _logFeedingController.fetchlogfeedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
      speciesId: speciesId,
    );

    _syncFeedingsState();
  }

  // ✅ STRICT SYNC: Binds API data strictly to the original saved index
  void _syncFeedingsState() {
    if (!_isDateSelected()) return;

    final logs = _logFeedingController.logfeedDataResponce.value.data ?? [];
    final picked = DateTime.tryParse(_dateController.text.trim());
    if (picked == null) return;

    final List<logfeeding.Datum> todayLogs = [];
    for (final log in logs) {
      if (log.date != null &&
          log.date!.year == picked.year &&
          log.date!.month == picked.month &&
          log.date!.day == picked.day) {
        todayLogs.add(log);
      }
    }

    // 1. Clear all cards that are NOT currently saved or saving
    for (int i = 0; i < 4; i++) {
      if (!_feedings[i].isSaving && !_feedings[i].isSaved) {
        final bool isEditing = _feedings[i].kgController.text.trim().isNotEmpty;

        if (!isEditing) {
          _feedings[i].kgController.clear();
          _feedings[i].remarksController.clear();
          _feedings[i].feedType = null;
          _feedingLogIds.remove(i);
        }
      }
    }

    // 2. Map every incoming API log STRICTLY to its assigned index
    for (final log in todayLogs) {
      final logId = log.id ?? "";
      if (logId.isEmpty) continue;

      int? targetIndex;
      if (log.feedingType != null && log.feedingType!.trim().isNotEmpty) {
        final parsedType = int.tryParse(log.feedingType!.trim());
        if (parsedType != null && parsedType >= 1 && parsedType <= 4) {
          targetIndex = parsedType - 1;
        }
      }
      targetIndex ??= _logFeedIndexMap[logId];

      if (targetIndex != null && targetIndex >= 0 && targetIndex < 4) {
        _feedings[targetIndex].isSaved = true;
        _feedings[targetIndex].kgController.text = log.kg ?? "";
        _feedings[targetIndex].remarksController.text = log.remarks ?? "";

        final purchaseList =
            _purchaseController.purchaseDataResponce.value.data ?? [];
        for (final p in purchaseList) {
          if (p.id == log.purchaseId) {
            _feedings[targetIndex].feedType = p;
            break;
          }
        }

        _logFeedIndexMap[logId] = targetIndex;
        _feedingLogIds[targetIndex] = logId;
      } else {
        for (int i = 0; i < 4; i++) {
          if (_feedingLogIds[i] == null) {
            _feedingLogIds[i] = logId;
            _logFeedIndexMap[logId] = i;

            _feedings[i].isSaved = true;
            _feedings[i].kgController.text = log.kg ?? "";
            _feedings[i].remarksController.text = log.remarks ?? "";

            final purchaseList =
                _purchaseController.purchaseDataResponce.value.data ?? [];
            for (final p in purchaseList) {
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

  Future<void> _pickDate() async {
    // ✅ Restricts to only today and future dates
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // <-- This disables yesterday and past dates
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primary,
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
            "${picked.year}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";
      });
      _syncFeedingsState();
    }
  }

  Future<void> _saveFeeding(int index) async {
    final feeding = _feedings[index];
    if (feeding.isSaving || feeding.isSaved) return;

    if (!_isDateSelected()) {
      _snack("required".tr, "please_select_date".tr);
      return;
    }
    if ((_selectedSpecies?.id ?? "").isEmpty) {
      _snack("required".tr, "please_select_crop".tr);
      return;
    }
    if (feeding.feedType == null) {
      _snack("required".tr, "please_select_feed".tr);
      return;
    }

    final kg = double.tryParse(feeding.kgController.text.trim());
    if (kg == null || kg <= 0) {
      _snack("required".tr, "please_enter_valid_kg".tr);
      return;
    }

    final available = _availableFor(feeding.feedType);
    if (kg > available) {
      _snack(
        "not_enough_stock".tr,
        "${"only_available_prefix".tr} ${_fmt(available)} ${"kg_available_suffix".tr} "
        "${feeding.feedType?.feedName ?? "this_feed".tr}. "
        "${"enter_less_prefix".tr} ${_fmt(available)} ${"kg_or_less".tr}.",
      );
      return;
    }

    setState(() => feeding.isSaving = true);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/logfeeding/add'),
      );

      request.body = json.encode({
        "tankId": widget.tankId,
        "purchaseId": feeding.feedType?.id ?? "",
        "date": _dateController.text,
        "kg": feeding.kgController.text.trim(),
        "remarks": feeding.remarksController.text,
        "speciesId": _selectedSpecies?.id ?? "",
        "status": "active",
        "farmId": widget.farmId,
        "feedingType": "${index + 1}",
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          feeding.isSaved = true;
          feeding.isSaving = false;
        });

        String? newLogId;
        if (decodedMap['data'] != null && decodedMap['data']['_id'] != null) {
          newLogId = decodedMap['data']['_id'].toString();
        } else if (decodedMap['_id'] != null) {
          newLogId = decodedMap['_id'].toString();
        }

        if (newLogId != null) {
          _logFeedIndexMap[newLogId] = index;
          _feedingLogIds[index] = newLogId;
        }

        final pid = feeding.feedType?.id ?? "";
        _sessionUsed[pid] = (_sessionUsed[pid] ?? 0.0) + kg;

        _lastFetchedSpeciesId = null;
        await _refreshFcr();
      } else {
        setState(() => feeding.isSaving = false);
        _snack(
          "failed".tr,
          decodedMap['message'] ?? "could_not_save_feeding".tr,
        );
      }
    } catch (e) {
      if (mounted) setState(() => feeding.isSaving = false);
      _snack("failed".tr, "could_not_save_feeding".tr);
    }
  }

  // ✅ Fixed Delete logic
  Future<void> _deleteFeeding(int index) async {
    final logId = _feedingLogIds[index];
    if (logId == null || logId.isEmpty) {
      _snack("error".tr, "Log ID not found");
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text("delete_feeding".tr),
        content: Text("are_you_sure_delete_feeding".tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("cancel".tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text("delete".tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _feedings[index].isSaving = true);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
      };

      var request = http.Request(
        'DELETE',
        Uri.parse(AppBaseUrls.baseUrl + 'app/logfeeding/delete/$logId'),
      );

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // ✅ Show success first
        _snack("success".tr, "feeling_deleted_successfully".tr);

        if (mounted) {
          setState(() {
            _feedings[index].isSaved = false;
            _feedings[index].isSaving = false;
            _feedings[index].kgController.clear();
            _feedings[index].remarksController.clear();
            _feedings[index].feedType = null;
          });
        }
        
        _feedingLogIds.remove(index);
        _logFeedIndexMap.remove(logId);

        _lastFetchedSpeciesId = null;
        await _refreshFcr();
      } else {
        if (mounted) setState(() => _feedings[index].isSaving = false);
        _snack("failed".tr, "could_not_delete_feeding".tr);
      }
    } catch (e) {
      if (mounted) setState(() => _feedings[index].isSaving = false);
      _snack("error".tr, "could_not_delete_feeding".tr);
    }
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
                                _snack("required".tr, "please_select_date".tr);
                                return;
                              }
                              if (biomassCtrl.text.trim().isEmpty) {
                                _snack(
                                  "required".tr,
                                  "please_enter_biomass".tr,
                                );
                                return;
                              }
                              try {
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
                                _lastFetchedSpeciesId = null;
                                _refreshFcr();
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                              } catch (e) {
                                _snack(
                                  "failed".tr,
                                  "could_not_save_estimate".tr,
                                );
                              }
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

          _buildDateCard(),
          const SizedBox(height: 14),

          Obx(() {
            final resp = _purchaseController.purchaseDataResponce.value;
            if (resp.data == null) return _buildFeedingLoadingCard();
            final feeds = resp.data ?? [];
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
          const SizedBox(height: 14),

          _buildBiomassCard(),
          const SizedBox(height: 14),

          _buildDailyFeedCard(),
          const SizedBox(height: 10),

          CustomText(
            textName: "feed_footer_note".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade500,
            fontSize: 10,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFeedingLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
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
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 18, color: _primary),
              const SizedBox(width: 8),
              CustomText(
                textName: "no_feed_purchased_yet".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: AppColors.blackColor,
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

  Widget _buildSummaryCard() {
    return Obx(() {
      final summary = _homeFeedingController.homefeedfcrDataResponce.value.data;
      final logs = _logFeedingController.logfeedDataResponce.value.data ?? [];
      final biomassList =
          _biomassController.biomassDataResponce.value.data ?? [];

      final now = DateTime.now();
      double todayLocal = 0;
      for (final l in logs) {
        final d = l.date;
        if (d == null) continue;
        if (d.year == now.year && d.month == now.month && d.day == now.day) {
          todayLocal += double.tryParse((l.kg ?? "0").trim()) ?? 0;
        }
      }
      final double todaysFeed =
          todayLocal > 0
              ? todayLocal
              : (double.tryParse(summary?.todaysFeed?.toString() ?? "0") ?? 0);

      double cumulativeFeed =
          double.tryParse(summary?.cumulativeFeed?.toString() ?? "0") ?? 0;
      if (cumulativeFeed <= 0) {
        for (final l in logs) {
          cumulativeFeed += double.tryParse((l.kg ?? "0").trim()) ?? 0;
        }
      }

      double? startingBiomass;
      double? latestBiomass;

      if (biomassList.isNotEmpty) {
        final sorted = [...biomassList]..sort((a, b) {
          final da = a.date ?? DateTime(1970);
          final db = b.date ?? DateTime(1970);
          return da.compareTo(db);
        });
        final firstKg = double.tryParse(
          (sorted.first.estimaTedBiomassKg ?? "0").trim(),
        );
        final lastKg = double.tryParse(
          (sorted.last.estimaTedBiomassKg ?? "0").trim(),
        );
        if (firstKg != null && firstKg > 0) startingBiomass = firstKg;
        if (lastKg != null && lastKg > 0) latestBiomass = lastKg;
      }

      startingBiomass ??= double.tryParse(
        summary?.firstBiomass?.toString() ?? "",
      );
      latestBiomass ??= double.tryParse(
        summary?.latestBiomass?.toString() ?? "",
      );

      if (startingBiomass != null && startingBiomass <= 0)
        startingBiomass = null;
      if (latestBiomass != null && latestBiomass <= 0) latestBiomass = null;

      double fcr = 0.0;
      final serverFcr =
          double.tryParse(summary?.estimatedFcr?.toString() ?? "0") ?? 0;

      if (serverFcr > 0 && serverFcr.isFinite) {
        fcr = serverFcr;
      } else if (startingBiomass != null &&
          latestBiomass != null &&
          latestBiomass > startingBiomass &&
          cumulativeFeed > 0) {
        fcr = cumulativeFeed / (latestBiomass - startingBiomass);
      } else if (latestBiomass != null &&
          latestBiomass > 0 &&
          cumulativeFeed > 0) {
        fcr = cumulativeFeed / latestBiomass;
      }

      if (!fcr.isFinite || fcr < 0) fcr = 0.0;

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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _summaryBlock(widget.doc, "culture_day".tr)),
                Expanded(
                  child: _summaryBlock(
                    todaysFeed <= 0 ? "0 kg" : "${_fmt(todaysFeed)} kg",
                    "todays_feed".tr,
                  ),
                ),
                Expanded(
                  child: _summaryBlock(
                    "${_fmt(cumulativeFeed)} kg",
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
                    latestBiomass == null
                        ? "0 kg"
                        : "${_fmt(latestBiomass)} kg",
                    "latest_biomass".tr,
                  ),
                ),
                Expanded(
                  child: _summaryBlock(
                    startingBiomass == null
                        ? "0 kg"
                        : "${_fmt(startingBiomass)} kg",
                    "starting_biomass".tr,
                  ),
                ),
                Expanded(
                  child: _summaryBlock(
                    fcr.toStringAsFixed(2),
                    "estimated_fcr".tr,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomText(
              textName: "projected_fcr_note".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.white70,
              fontSize: 9,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDateCard() {
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
            textName: "date".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: AppColors.blackColor,
            fontSize: 12,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _dateController,
                  hint: "dd_mm_yyyy".tr,
                  readOnly: true,
                  onTap: _pickDate,
                  suffixIcon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Obx(() {
                final logs =
                    _logFeedingController.logfeedDataResponce.value.data ?? [];
                final picked = DateTime.tryParse(_dateController.text.trim());

                double dayTotal = 0;
                double cumulative = 0;
                for (final l in logs) {
                  final kg = double.tryParse(l.kg ?? "0") ?? 0;
                  cumulative += kg;
                  final d = l.date;
                  if (picked != null &&
                      d != null &&
                      d.year == picked.year &&
                      d.month == picked.month &&
                      d.day == picked.day) {
                    dayTotal += kg;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      textName: "${"day_total".tr} ${_fmt(dayTotal)} kg",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      textColor: AppColors.blackColor,
                      fontSize: 11,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      textName:
                          "${"crop_cumulative".tr} ${_fmt(cumulative)} kg",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
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
            if (resp.data == null) return _buildBiomassShimmer();
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
                  _buildBiomassRow(sorted[i]),
                  if (i != sorted.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBiomassShimmer() {
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

  Widget _buildBiomassRow(biomass.Datum b) {
    final dateStr =
        b.date != null ? "${b.date!.day} ${_monthShort(b.date!.month)}" : "—";
    final biomassKg = b.estimaTedBiomassKg ?? "—";
    final abw = b.averageBodyWeight ?? "—";
    final surv = b.survival ?? "—";
    final remark = (b.reamrks ?? "").trim();

    final meta =
        "ABW $abw g · $surv% ${"surv_short".tr}.${remark.isNotEmpty ? " · $remark" : ""}";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildDailyFeedCard() {
    final ScrollController horizontalController = ScrollController();

    return Obx(() {
      final speciesId = _selectedSpecies?.id ?? "";
      final resp = _logFeedingController.logfeedDataResponce.value;

      return Container(
        key: ValueKey("daily_feed_$speciesId"),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
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
                  textColor: const Color(0xFF1E3A5F),
                  fontSize: 15,
                ),
                const Spacer(),
                if (_selectedSpecies != null)
                  CustomText(
                    textName: _selectedSpecies!.speciesName ?? "",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey.shade500,
                    fontSize: 11,
                  ),
              ],
            ),
            const SizedBox(height: 16),

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
                  width: 800,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _headerCell("day".tr, flex: 2),
                            _headerCell("F1", flex: 1),
                            _headerCell("F2", flex: 1),
                            _headerCell("F3", flex: 1),
                            _headerCell("F4", flex: 1),
                            _headerCell("daily".tr, flex: 2),
                            _headerCell("cumulative".tr, flex: 2),
                            _headerCell("biomass".tr, flex: 2),
                            _headerCell("est_fcr".tr, flex: 2),
                          ],
                        ),
                        Divider(height: 20, color: Colors.grey.shade200),

                        if (resp.data == null)
                          _buildDailyFeedShimmer()
                        else if (resp.data!.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: CustomText(
                              textName: "no_feedings_for_crop".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          )
                        else
                          Builder(
                            builder: (_) {
                              final Map<String, List<logfeeding.Datum>>
                                  groupedByDay = {};

                              for (final log in resp.data!) {
                                if (log.date != null) {
                                  final dateKey =
                                      "${log.date!.year}-${log.date!.month}-${log.date!.day}";
                                  groupedByDay
                                      .putIfAbsent(dateKey, () => [])
                                      .add(log);
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
                                    if (i != sortedKeys.length - 1)
                                      Divider(
                                        height: 16,
                                        color: Colors.grey.shade100,
                                      ),
                                  ],
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDailyFeedRow({
    required String dateKey,
    required List<logfeeding.Datum> dayLogs,
    required bool isLatest,
  }) {
    final parts = dateKey.split('-');
    final day = int.tryParse(parts[2]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final dateStr = "$day ${_monthShort(month)}";

    double f1 = 0, f2 = 0, f3 = 0, f4 = 0;
    double totalDaily = 0;

    for (int i = 0; i < dayLogs.length; i++) {
      final kg = double.tryParse(dayLogs[i].kg ?? "0") ?? 0;
      totalDaily += kg;

      final logId = dayLogs[i].id ?? "";
      final feedingIndex = _logFeedIndexMap[logId] ?? i;

      if (feedingIndex == 0) {
        f1 = kg;
      } else if (feedingIndex == 1) {
        f2 = kg;
      } else if (feedingIndex == 2) {
        f3 = kg;
      } else if (feedingIndex == 3) {
        f4 = kg;
      }
    }

    double cumulative = 0;
    final allLogs = _logFeedingController.logfeedDataResponce.value.data ?? [];
    for (final log in allLogs) {
      if (log.date != null) {
        final logDateKey =
            "${log.date!.year}-${log.date!.month}-${log.date!.day}";
        if (logDateKey.compareTo(dateKey) <= 0) {
          cumulative += double.tryParse(log.kg ?? "0") ?? 0;
        }
      }
    }

    String fcrStr = "—";
    final biomassList = _biomassController.biomassDataResponce.value.data ?? [];
    double biomassOnDate = 0;
    for (final b in biomassList) {
      if (b.date != null) {
        final bioKey = "${b.date!.year}-${b.date!.month}-${b.date!.day}";
        if (bioKey.compareTo(dateKey) <= 0) {
          final val = double.tryParse(b.estimaTedBiomassKg ?? "0") ?? 0;
          if (val > biomassOnDate) biomassOnDate = val;
        }
      }
    }

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
                  textColor: const Color(0xFF1E3A5F),
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
          _tableCell(f1 > 0 ? _fmt(f1) : "—", flex: 1),
          _tableCell(f2 > 0 ? _fmt(f2) : "—", flex: 1),
          _tableCell(f3 > 0 ? _fmt(f3) : "—", flex: 1),
          _tableCell(f4 > 0 ? _fmt(f4) : "—", flex: 1),
          _tableCell(_fmt(totalDaily), flex: 2, isBold: true),
          _tableCell(_fmt(cumulative), flex: 2),
          _tableCell(biomassOnDate > 0 ? _fmt(biomassOnDate) : "—", flex: 2),
          _tableCell(fcrStr, flex: 2),
        ],
      ),
    );
  }

  Widget _tableCell(String text, {required int flex, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: isBold ? FontWeightType.bold : FontWeightType.regular,
        textColor: isBold ? const Color(0xFF1E3A5F) : AppColors.blackColor,
        fontSize: 12,
      ),
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.semiBold,
        textColor: const Color(0xFF6B7280),
        fontSize: 11,
      ),
    );
  }

  Widget _buildDailyFeedShimmer() {
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
          child: Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 8),
              CustomText(
                textName: "loading_species".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade500,
                fontSize: 12,
              ),
            ],
          ),
        );
      }

      final speciesList = response.data ?? [];

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
      matched ??= speciesList.first;

      final species.Datum safeValue = matched;
      if (_selectedSpecies?.id != safeValue.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_selectedSpecies?.id != safeValue.id) {
            setState(() => _selectedSpecies = safeValue);
            _lastFetchedSpeciesId = null;
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
                  final isCurrent = s.isCurrent == true;
                  return DropdownMenuItem<species.Datum>(
                    value: s,
                    child: Row(
                      children: [
                        CustomText(
                          textName: s.speciesName ?? "unnamed".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType:
                              isCurrent
                                  ? FontWeightType.semiBold
                                  : FontWeightType.regular,
                          textColor: AppColors.blackColor,
                          fontSize: 12,
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomText(
                              textName: "current_label".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.semiBold,
                              textColor: _primary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) async {
              if (value == null) return;
              if (value.id == _selectedSpecies?.id) return;

              setState(() => _selectedSpecies = value);

              _lastFetchedSpeciesId = null;

              await _refreshFcr();
            },
          ),
        ),
      );
    });
  }

  Widget _buildFeedingCard({required int index}) {
    while (_feedings.length <= index) {
      _feedings.add(_FeedingState(index: _feedings.length));
    }

    final feeding = _feedings[index];
    final title = "${"feeding_prefix".tr} ${index + 1}";
    final isFirst = index == 0;
    final locked = feeding.isSaved || feeding.isSaving;

    final Color cardBorderColor =
        feeding.isSaved
            ? _green
            : (feeding.isSaving ? _primary : Colors.grey.shade200);
    final Color cardBgColor =
        feeding.isSaved ? const Color(0xFFF4FBF7) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgColor,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textName: title,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor:
                          feeding.isSaved ? _green : AppColors.blackColor,
                      fontSize: 13,
                    ),
                    if (isFirst) ...[
                      const SizedBox(height: 1),
                      Obx(
                        () => CustomText(
                          textName:
                              "${"by_prefix".tr} ${_profileController.profileDataResponce.value.data?.email ?? ""}",
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: Colors.grey.shade500,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (feeding.isSaved)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InkWell(
                    onTap:
                        feeding.isSaving ? null : () => _deleteFeeding(index),
                    child: Icon(Icons.delete_outline, color: _red, size: 20),
                  ),
                ),

              if (feeding.isSaved) const SizedBox(width: 8),

              if (feeding.isSaved)
                Icon(Icons.check_circle, color: _green, size: 20),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: feeding.kgController,
                  hint: "kg_given".tr,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: !locked,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFeedDropdown(
                  value: feeding.feedType,
                  onChanged:
                      locked
                          ? null
                          : (v) {
                            setState(() => feeding.feedType = v);
                            _lastFetchedSpeciesId = null;
                            _refreshFcr();
                          },
                ),
              ),
            ],
          ),

          if (feeding.feedType != null && !feeding.isSaved) ...[
            const SizedBox(height: 6),
            Obx(() {
              final stockBefore = _availableFor(feeding.feedType);
              final entered =
                  double.tryParse(feeding.kgController.text.trim()) ?? 0.0;
              final remaining = stockBefore - entered;
              final exceeded = entered > stockBefore;

              final String msg;
              if (exceeded) {
                msg =
                    "${"only_available_prefix".tr} ${_fmt(stockBefore)} ${"kg_available_suffix".tr} — ${"enter_less_prefix".tr} ${_fmt(stockBefore)} ${"kg_or_less".tr}";
              } else if (entered <= 0) {
                msg = "${"available_stock_prefix".tr} ${_fmt(stockBefore)} kg";
              } else {
                msg =
                    "${_fmt(stockBefore)} ${"kg_available_dot".tr} ${_fmt(remaining)} ${"kg_remaining".tr}";
              }

              return CustomText(
                textName: msg,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: exceeded ? Colors.red : Colors.grey.shade600,
                fontSize: 10,
              );
            }),
          ],
          const SizedBox(height: 10),

          _buildTextField(
            controller: feeding.remarksController,
            hint: "remarks_optional".tr,
            enabled: !locked,
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: locked ? null : () => _saveFeeding(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: feeding.isSaved ? _green : _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    feeding.isSaved ? _green : _primary.withOpacity(0.5),
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
    required purchase.Datum? value,
    required ValueChanged<purchase.Datum?>? onChanged,
  }) {
    return Obx(() {
      final response = _purchaseController.purchaseDataResponce.value;

      if (response.data == null) {
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 8),
              CustomText(
                textName: "loading_feeds".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade500,
                fontSize: 11,
              ),
            ],
          ),
        );
      }

      final feeds = response.data ?? [];

      if (feeds.isEmpty) {
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: CustomText(
              textName: "no_feeds".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        );
      }

      purchase.Datum? safeValue;
      if (value != null) {
        for (final f in feeds) {
          if (f.id == value.id) {
            safeValue = f;
            break;
          }
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<purchase.Datum>(
            value: safeValue,
            isExpanded: true,
            hint: CustomText(
              textName: "feed_name_hint".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 11,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade700,
              size: 18,
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items:
                feeds.map((f) {
                  return DropdownMenuItem<purchase.Datum>(
                    value: f,
                    child: CustomText(
                      textName: f.feedName ?? "",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: AppColors.blackColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        ),
      );
    });
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
    return _buildTextField(
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      suffixIcon: suffixIcon,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
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
        disabledBorder: OutlineInputBorder(
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
}

class _FeedingState {
  final TextEditingController kgController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  purchase.Datum? feedType;
  bool isSaving = false;
  bool isSaved = false;
  final int index;

  _FeedingState({this.index = 0});
}
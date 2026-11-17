import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/account_balance_model.dart';
import 'package:superapp/model/over_view/bottom_feed_model.dart' hide Datum;
import 'package:superapp/model/over_view/bottom_madicine_model.dart' hide Datum;
import 'package:superapp/model/over_view/expence_model.dart';
import 'package:superapp/model/over_view/home_pandl_model.dart'
    hide Expense, Medicine, Harvest, Location, Stock, Purchase;
import 'package:superapp/model/over_view/party_model.dart' as party;
import 'package:superapp/model/staff/get_worker_model.dart' hide Datum;
import 'package:superapp/model/tank/get_form_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/view_model/api_controllers/over_view/account_balance_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_medicine_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/expence_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_pandl_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_advance_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/get_worker_controller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_all_tank_conteoller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_form_controller.dart';
import 'package:superapp/model/over_view/account_get_expence_model.dart'
    as acc_exp;
import 'package:superapp/view_model/api_controllers/over_view/account_get_expense_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/account_staff_advance_controller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final OverviewService _overviewService;

  final Color _primary = const Color(0xFF087FC1);
  final Color _green = const Color(0xFF1B9C4A);
  final Color _red = const Color(0xFFE53935);
  final Color _orange = const Color(0xFFF57C00);

  int _selectedTopTab = 0;
  // internal values kept identical; display uses _topTabLabel()
  final List<String> _topTabs = [
    "Balance Sheet",
    "Stock Report",
    "Staff Advances",
    "Expense Claims",
  ];

  String _selectedStockTab = "Feed";
  String _selectedClaimTab = "All";

  final GetAllTankConteoller _tankController = Get.find<GetAllTankConteoller>();
  final AccountBalanceController _balanceController =
      Get.find<AccountBalanceController>();
  final BottomFeedController _feedController = Get.find<BottomFeedController>();
  final BottomMedicineController _medicineController =
      Get.find<BottomMedicineController>();
  final GetWorkerController _workerController = Get.find<GetWorkerController>();
  final ExpenceController _expenseController = Get.find<ExpenceController>();

  late final AccountGetExpenseController _accountGetExpenseController;
  late final AccountStaffAdvanceController _accountStaffAdvanceController;
  late final GetFormController _getFormController;
  late final HomePandlController _homePandlController;

  late final PartyController _partyController;

  final Map<String, PartyAdvanceController> _advanceControllers = {};
  final Set<String> _ownedAdvanceTags = {};
  final Set<String> _fetchInitiated = {};

  Datum? _selectedFarm;
  String _selectedTank = "";

  final TextEditingController _bsFromController = TextEditingController();
  final TextEditingController _bsToController = TextEditingController();
  final TextEditingController _srFromController = TextEditingController();
  final TextEditingController _srToController = TextEditingController();

  double _plHarvestIncome = 0;
  double _plFeedExpense = 0;
  double _plMedicineExpense = 0;
  double _plStockingLaborOther = 0;
  bool _isLoadingPL = false;

  final Map<String, String> _localStatusUpdates = {};
  final Set<String> _updatingClaimIds = {};

  final Map<String, String> _localAdvanceStatusUpdates = {};
  final Set<String> _updatingAdvanceIds = {};

  // 🌐 Top tab label — display only
  String _topTabLabel(String internal) {
    switch (internal) {
      case "Balance Sheet":
        return "tab_balance_sheet".tr;
      case "Stock Report":
        return "tab_stock_report".tr;
      case "Staff Advances":
        return "tab_staff_advances".tr;
      case "Expense Claims":
        return "tab_expense_claims".tr;
      default:
        return internal;
    }
  }

  // 🌐 Stock tab label — display only
  String _stockTabLabel(String internal) {
    return internal == "Feed" ? "feed".tr : "medicine".tr;
  }

  // 🌐 Claim tab label — display only
  String _claimTabLabel(String internal) {
    switch (internal) {
      case "All":
        return "all".tr;
      case "Pending":
        return "pending".tr;
      case "Approved":
        return "approved".tr;
      case "Rejected":
        return "rejected".tr;
      default:
        return internal;
    }
  }

  // 🌐 Status label — display only
  String _statusLabel(String status) {
    switch (status) {
      case "approved":
        return "approved".tr;
      case "rejected":
        return "rejected".tr;
      case "pending":
      default:
        return "pending".tr;
    }
  }

  List<String> get _tankOptions {
    final tanks = _tankController.tanksDataResponce.value.tanks;
    final options = <String>["All"]; // ✅ Added All Tanks option
    if (tanks != null) {
      for (final tank in tanks) {
        if (tank.name != null && tank.name!.isNotEmpty) {
          options.add(tank.name!);
        }
      }
    }
    return options;
  }

  @override
  void initState() {
    super.initState();

    _overviewService = Get.find<OverviewService>();

    if (Get.isRegistered<GetFormController>()) {
      _getFormController = Get.find<GetFormController>();
    } else {
      _getFormController = Get.put(GetFormController(Get.find()));
    }

    if (Get.isRegistered<HomePandlController>()) {
      _homePandlController = Get.find<HomePandlController>();
    } else {
      _homePandlController = Get.put(HomePandlController(Get.find()));
    }

    if (Get.isRegistered<AccountGetExpenseController>()) {
      _accountGetExpenseController = Get.find<AccountGetExpenseController>();
    } else {
      _accountGetExpenseController = Get.put(
        AccountGetExpenseController(Get.find()),
      );
    }

    if (Get.isRegistered<AccountStaffAdvanceController>()) {
      _accountStaffAdvanceController =
          Get.find<AccountStaffAdvanceController>();
    } else {
      _accountStaffAdvanceController = Get.put(
        AccountStaffAdvanceController(Get.find()),
      );
    }

    if (_accountStaffAdvanceController
            .accountstaffadvanceDataResponce
            .value
            .data ==
        null) {
      _accountStaffAdvanceController.fetchgetaccountadvancedata();
    }

    if (Get.isRegistered<PartyController>()) {
      _partyController = Get.find<PartyController>();
    } else {
      _partyController = Get.put(PartyController(Get.find()));
    }
    _partyController.fetchpartydata();

    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    _bsFromController.text = _formatDate(from);
    _bsToController.text = _formatDate(now);
    _srFromController.text = _formatDate(from);
    _srToController.text = _formatDate(now);

    if (_getFormController.getformDataResponce.value.data == null) {
      _getFormController.fetchgetformdata();
    }

    if (_workerController.getworkerDataResponce.value.data == null) {
      _workerController.fetchgetworkerdata();
    }

    ever(_getFormController.getformDataResponce, (Getformdata data) {
      final list = data.data ?? [];
      if (list.isNotEmpty && _selectedFarm == null) {
        final firstFarm = list.first;
        setState(() => _selectedFarm = firstFarm);
        if (firstFarm.id != null && firstFarm.id!.isNotEmpty) {
          _tankController.fetchgetanksdata(farmId: firstFarm.id!);
        }
      }
    });

    ever(_tankController.tanksDataResponce, (_) {
      _fetchBalanceSheet();
      _fetchFeedStock();
      _fetchMedicineStock();
      _fetchPLData();
      _fetchExpenseClaims();
    });

    ever(_homePandlController.homepandlDataResponce, (data) {
      _computePLData(data);
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

    ever(_partyController.partyDataResponce, (_) {
      _ensureAllAdvanceControllers();
    });

    _ensureAllAdvanceControllers();
  }

  @override
  void dispose() {
    _bsFromController.dispose();
    _bsToController.dispose();
    _srFromController.dispose();
    _srToController.dispose();

    for (final tag in _ownedAdvanceTags) {
      Get.delete<PartyAdvanceController>(tag: tag, force: true);
    }

    super.dispose();
  }

  void _ensureAllAdvanceControllers() {
    final parties = _partyController.partyDataResponce.value.data ?? [];
    for (final p in parties) {
      _ensureAdvanceController(p.id ?? "");
    }
  }

  void _ensureAdvanceController(String partyId) {
    if (partyId.isEmpty) return;
    if (_advanceControllers.containsKey(partyId)) return;

    PartyAdvanceController c;
    if (Get.isRegistered<PartyAdvanceController>(tag: partyId)) {
      c = Get.find<PartyAdvanceController>(tag: partyId);
    } else {
      c = Get.put(PartyAdvanceController(OverviewService()), tag: partyId);
      _ownedAdvanceTags.add(partyId);
    }
    _advanceControllers[partyId] = c;

    if (!_fetchInitiated.contains(partyId) &&
        c.partyadvDataResponce.value.data == null) {
      _fetchInitiated.add(partyId);
      c.fetchpartyadvance(partyId: partyId);
    }
  }

  double _vendorAdvanceTotal() {
    double t = 0;
    for (final c in _advanceControllers.values) {
      final list = c.partyadvDataResponce.value.data ?? [];
      for (final d in list) {
        final amt = double.tryParse(d.amount ?? "0") ?? 0;
        final type = (d.paymentType ?? "").toLowerCase().trim();
        if (type == "advance") {
          t += amt;
        } else if (type.isEmpty) {
          final note = (d.notes ?? "").toLowerCase();
          if (note.contains("advance")) t += amt;
        }
      }
    }
    debugPrint("══► ADVANCE TOTAL (parties)= $t");
    return t;
  }

  double _vendorPaymentTotal() {
    double t = 0;
    for (final c in _advanceControllers.values) {
      final list = c.partyadvDataResponce.value.data ?? [];
      for (final d in list) {
        final amt = double.tryParse(d.amount ?? "0") ?? 0;
        final type = (d.paymentType ?? "").toLowerCase().trim();
        if (type == "payment") {
          t += amt;
        } else if (type.isEmpty) {
          final note = (d.notes ?? "").toLowerCase();
          if (!note.contains("advance")) t += amt;
        }
      }
    }
    debugPrint("══► PAYMENT TOTAL (parties)= $t");
    return t;
  }

  String _formatDate(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String _toApiDate(String date) => date;

  String? _resolveTankId() {
    if (_selectedTank == "All") return ""; // ✅ Returns empty string for All Tanks

    final tanks = _tankController.tanksDataResponce.value.tanks;
    if (tanks == null || tanks.isEmpty) return "";
    for (final t in tanks) {
      if (t.name == _selectedTank) return t.id ?? "";
    }
    return "";
  }

  Future<void> _fetchBalanceSheet() async {
    final tankId = _resolveTankId();
    _balanceController.fetchaccountdata(
      tankId: tankId ?? "",
      fromDate: _toApiDate(_bsFromController.text),
      toDate: _toApiDate(_bsToController.text),
      farmId: _selectedFarm?.id ?? "",
    );
    _fetchPLData();
  }

  Future<void> _fetchFeedStock() async {
    final tankId = _resolveTankId();
    _feedController.fetchbottomfeedata(
      tankId: tankId ?? "",
      fromDate: _toApiDate(_srFromController.text),
      toDate: _toApiDate(_srToController.text),
      farmId: _selectedFarm?.id ?? "",
    );
  }

  Future<void> _fetchMedicineStock() async {
    final tankId = _resolveTankId();
    _medicineController.fetchbottomedicinedata(
      tankId: tankId ?? "",
      fromDate: _toApiDate(_srFromController.text),
      toDate: _toApiDate(_srToController.text),
      farmId: _selectedFarm?.id ?? "",
    );
  }

  Future<void> _fetchActiveStock() async {
    if (_selectedStockTab == "Feed") {
      await _fetchFeedStock();
    } else {
      await _fetchMedicineStock();
    }
  }

  Future<void> _fetchExpenseClaims() async {
    final tankId = _resolveTankId() ?? "";
    final farmId = _selectedFarm?.id ?? "";
    _accountGetExpenseController.fetchaccountgetexpencedata(
      tankId: tankId,
      farmId: farmId,
    );
  }

  Future<void> _fetchPLData() async {
    final tankId = _resolveTankId();
    setState(() => _isLoadingPL = true);
    try {
      _homePandlController.fetchgetpandldata(
        tankId: tankId ?? "",
        farmId: _selectedFarm?.id ?? "",
      );
      _computePLData(_homePandlController.homepandlDataResponce.value);
    } catch (e) {
      debugPrint("P&L fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingPL = false);
    }
  }

  void _computePLData(HomePandLdata data) {
    double harvestIncome = 0;
    for (final h in data.harvests ?? []) {
      harvestIncome += double.tryParse(h.totalAmount ?? "0") ?? 0;
    }

    double feedExpense = 0;
    for (final p in data.purchases ?? []) {
      feedExpense += double.tryParse(p.totalAmount ?? "0") ?? 0;
    }

    double medicineExpense = 0;
    for (final m in data.medicines ?? []) {
      medicineExpense += double.tryParse(m.totalAmount ?? "0") ?? 0;
    }

    double stockingExpense = 0;
    for (final o in data.overview ?? []) {
      for (final s in o.stocks ?? []) {
        stockingExpense += double.tryParse(s.totalAmount ?? "0") ?? 0;
      }
    }

    for (final e in data.expenses ?? []) {
      if (e.labour?.totalLabourCost != null) {
        stockingExpense += double.tryParse(e.labour!.totalLabourCost!) ?? 0;
      }
      if (e.salary?.totalSalaries != null) {
        stockingExpense += double.tryParse(e.salary!.totalSalaries!) ?? 0;
      }
      stockingExpense += (e.diesel?.amount ?? 0).toDouble();
      stockingExpense += (e.petrol?.amount ?? 0).toDouble();
      stockingExpense += (e.tiffinsMeals?.amount ?? 0).toDouble();
      stockingExpense += (e.transport?.amount ?? 0).toDouble();
      stockingExpense += (e.utilities?.amount ?? 0).toDouble();
      stockingExpense += (e.other?.amount ?? 0).toDouble();
      stockingExpense += (e.electrical?.total ?? 0).toDouble();
      stockingExpense += (e.plumbing?.total ?? 0).toDouble();
    }

    setState(() {
      _plHarvestIncome = harvestIncome;
      _plFeedExpense = feedExpense;
      _plMedicineExpense = medicineExpense;
      _plStockingLaborOther = stockingExpense;
    });
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: _primary,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() => controller.text = _formatDate(picked));
    }
  }

  Future<void> _onStatusChanged(
    acc_exp.Datum e,
    String currentStatus,
    String? newStatus,
  ) async {
    if (newStatus == null || newStatus == currentStatus) return;
    if (e.id == null || e.id!.isEmpty) return;
    if (_updatingClaimIds.contains(e.id)) return;
    if (currentStatus != "pending") return;

    setState(() {
      _localStatusUpdates[e.id!] = newStatus;
      _updatingClaimIds.add(e.id!);
    });

    bool ok = false;
    try {
      final result = await _overviewService.userupdatexpense(
        staffExpenseId: e.id!,
        status: newStatus,
      );
      ok = result == true;
    } catch (err) {
      debugPrint("userupdatexpense error: $err");
      ok = false;
    }

    if (!mounted) return;

    if (ok) {
      setState(() => _updatingClaimIds.remove(e.id!));
      await _fetchExpenseClaims();
    } else {
      setState(() {
        _localStatusUpdates.remove(e.id!);
        _updatingClaimIds.remove(e.id!);
      });
    }
  }

  Future<void> _onAdvanceStatusChanged(
    dynamic advance,
    String currentStatus,
    String? newStatus,
  ) async {
    if (newStatus == null || newStatus == currentStatus) return;

    final String? id = advance.id;
    if (id == null || id.isEmpty) return;
    if (_updatingAdvanceIds.contains(id)) return;
    if (currentStatus != "pending") return;

    setState(() {
      _localAdvanceStatusUpdates[id] = newStatus;
      _updatingAdvanceIds.add(id);
    });

    bool ok = false;
    try {
      ok = await _overviewService.updatestaffadvance(
        staffAdvanceId: id,
        status: newStatus,
      );
    } catch (err) {
      debugPrint("updatestaffadvance error: $err");
      ok = false;
    }

    if (!mounted) return;

    if (ok) {
      setState(() => _updatingAdvanceIds.remove(id));
      _accountStaffAdvanceController.fetchgetaccountadvancedata();
    } else {
      setState(() {
        _localAdvanceStatusUpdates.remove(id);
        _updatingAdvanceIds.remove(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  const Spacer(),
                  CustomText(
                    textName: "accounts".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 15,
                  ),
                  const Spacer(),
                  const SizedBox(width: 18),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Container(
              color: Colors.white,
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                itemCount: _topTabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isActive = _selectedTopTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTopTab = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? _primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? _primary : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: CustomText(
                        textName: _topTabLabel(_topTabs[index]),
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.medium,
                        textColor:
                            isActive ? Colors.white : Colors.grey.shade700,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child:
                  _selectedTopTab == 0
                      ? _buildBalanceSheet()
                      : _selectedTopTab == 1
                      ? _buildStockReport()
                      : _selectedTopTab == 2
                      ? _buildStaffAdvances()
                      : _buildExpenseClaims(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmDropdown() {
    return Obx(() {
      final response = _getFormController.getformDataResponce.value;

      if (response.data == null || response.data!.isEmpty) {
        final isLoading = response.success == null;
        if (isLoading) {
          return Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
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
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: CustomText(
              textName: "no_farms_available".tr,
              fontFamily: FontFamily.poppins,
              textColor: Colors.grey.shade500,
              fontSize: 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Datum>(
            value: safeValue,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade700,
              size: 16,
            ),
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            items:
                farmList.map((farm) {
                  return DropdownMenuItem<Datum>(
                    value: farm,
                    child: CustomText(
                      textName: farm.farmName ?? "Unnamed Farm",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.medium,
                      textColor: AppColors.blackColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
            onChanged: (Datum? value) {
              if (value == null) return;
              setState(() {
                _selectedFarm = value;
                _selectedTank = ""; // Resets back to "All" in the logic below
                _localStatusUpdates.clear();
                _localAdvanceStatusUpdates.clear();
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

  Widget _buildTankDropdown() {
    return Obx(() {
      final isLoading = _tankController.tanksDataResponce.value.tanks == null;
      if (isLoading) {
        return Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
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

      final options = _tankOptions;

      if (_selectedTank.isEmpty || !options.contains(_selectedTank)) {
        _selectedTank = options.first;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedTank,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade700,
              size: 16,
            ),
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            items:
                options.map((t) {
                  return DropdownMenuItem<String>(
                    value: t,
                    child: CustomText(
                      textName: t == "All" 
                          ? "all_tanks".tr // ✅ Display All Tanks
                          : (t == "No tanks" ? "no_tanks".tr : t),
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: AppColors.blackColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _selectedTank = v;
                  _localStatusUpdates.clear();
                  _localAdvanceStatusUpdates.clear();
                });
                _fetchBalanceSheet();
                _fetchFeedStock();
                _fetchMedicineStock();
                _fetchPLData();
                _fetchExpenseClaims();
              }
            },
          ),
        ),
      );
    });
  }

  Widget _dateFieldDynamic(TextEditingController controller) {
    return GestureDetector(
      onTap: () => _pickDate(controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomText(
                textName:
                    controller.text.isEmpty
                        ? "yyyy_mm_dd".tr
                        : controller.text,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor:
                    controller.text.isEmpty
                        ? Colors.grey.shade500
                        : AppColors.blackColor,
                fontSize: 11,
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey.shade600,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSheet() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textName: "filters".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: Colors.grey.shade600,
                  fontSize: 9,
                ),
                const SizedBox(height: 10),
                _buildFarmDropdown(),
                const SizedBox(height: 10),
                CustomText(
                  textName: "tank".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade700,
                  fontSize: 10,
                ),
                const SizedBox(height: 4),
                _buildTankDropdown(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            textName: "from".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: Colors.grey.shade700,
                            fontSize: 10,
                          ),
                          const SizedBox(height: 4),
                          _dateFieldDynamic(_bsFromController),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            textName: "to".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: Colors.grey.shade700,
                            fontSize: 10,
                          ),
                          const SizedBox(height: 4),
                          _dateFieldDynamic(_bsToController),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _fetchBalanceSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: CustomText(
                      textName: "apply".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      textColor: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Obx(() {
            final data = _balanceController.accountbalDataResponce.value;
            final overviews = data.overview ?? [];

            final partyResp = _partyController.partyDataResponce.value;
            final parties = partyResp.data ?? [];

            for (final p in parties) {
              _ensureAdvanceController(p.id ?? "");
            }

            final int advanceTotal = _vendorAdvanceTotal().round();
            final int paymentTotal = _vendorPaymentTotal().round();

            final int totalVendorPayable = advanceTotal + paymentTotal;

            num totalStockQty = 0;
            num totalStockValue = 0;
            num totalMedicineQty = 0;
            num totalMedicineValue = 0;

            for (final o in overviews) {
              totalStockQty += o.stockSummary?.quantityStocked ?? 0;
              totalStockValue += o.stockSummary?.totalAmount ?? 0;
              totalMedicineQty += o.medicineSummary?.quantityPurchased ?? 0;
              totalMedicineValue += o.medicineSummary?.totalAmount ?? 0;
            }

            final num totalAssets = totalStockValue + totalMedicineValue;

            final num netPosition = totalAssets + totalVendorPayable;

            return _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    textName: "balance_sheet".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    textName:
                        "${_bsFromController.text} → ${_bsToController.text}",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle("assets".tr),
                  if (totalStockQty > 0 || totalStockValue > 0)
                    _rowKV(
                      "${"feed_stock".tr} (${_numStr(totalStockQty)} ${"units".tr})",
                      _formatCurrency(num2int(totalStockValue)),
                    ),
                  if (totalMedicineQty > 0 || totalMedicineValue > 0)
                    _rowKV(
                      "${"medicine_stock".tr} (${_numStr(totalMedicineQty)} ${"units".tr})",
                      _formatCurrency(num2int(totalMedicineValue)),
                    ),
                  _rowKV(
                    "total_assets".tr,
                    _formatCurrency(num2int(totalAssets)),
                    bold: true,
                  ),

                  const SizedBox(height: 12),
                  _sectionTitle("vendor_payable".tr),
                  _rowKV(
                    "total_vendor_payable_advance".tr,
                    _formatCurrency(advanceTotal),
                    valueColor: _green,
                  ),
                  _rowKV(
                    "total_vendor_payable_payment".tr,
                    _formatCurrency(paymentTotal),
                    valueColor: _red,
                  ),
                  _rowKV(
                    "total_vendor_payable_overall".tr,
                    _formatCurrency(totalVendorPayable),
                    bold: true,
                    valueColor: _orange,
                  ),

                  const SizedBox(height: 12),
                  _sectionTitle("liabilities".tr),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 10),
                  _rowKV(
                    "net_position".tr,
                    _formatCurrency(num2int(netPosition)),
                    bold: true,
                    valueColor: _green,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          Obx(() {
            final data = _balanceController.accountbalDataResponce.value;
            final overviews = data.overview ?? [];

            if (overviews.isEmpty) {
              return _buildCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: CustomText(
                      textName: "no_data_available".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }

            return _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    textName: "per_tank_breakdown".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _headerCell("tank_col".tr, flex: 4),
                      _headerCell("stock_col".tr, flex: 3),
                      _headerCell("medicine_col".tr, flex: 3),
                      _headerCell("total_col".tr, flex: 3),
                    ],
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  ...overviews.map((o) {
                    final num stockValue = o.stockSummary?.totalAmount ?? 0;
                    final num medValue = o.medicineSummary?.totalAmount ?? 0;
                    final num total = stockValue + medValue;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  textName: o.name ?? "-",
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.semiBold,
                                  textColor: AppColors.blackColor,
                                  fontSize: 10,
                                ),
                                CustomText(
                                  textName: o.tankType ?? "",
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.regular,
                                  textColor: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ],
                            ),
                          ),
                          _bodyCell(
                            _formatCurrency(num2int(stockValue)),
                            flex: 3,
                          ),
                          _bodyCell(
                            _formatCurrency(num2int(medValue)),
                            flex: 3,
                          ),
                          _bodyCell(
                            _formatCurrency(num2int(total)),
                            flex: 3,
                            color: _green,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textName: "pl_all_time".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 13,
                ),
                const SizedBox(height: 12),
                if (_isLoadingPL)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _plShimmerRow(),
                        const SizedBox(height: 10),
                        _plShimmerRow(),
                        const SizedBox(height: 10),
                        _plShimmerRow(),
                        const SizedBox(height: 10),
                        _plShimmerRow(),
                      ],
                    ),
                  )
                else ...[
                  if (_plHarvestIncome > 0)
                    _rowKV(
                      "harvest_income".tr,
                      _formatCurrency(_plHarvestIncome.round()),
                      valueColor: _green,
                    ),
                  if (_plFeedExpense > 0)
                    _rowKV(
                      "feed_consumption".tr,
                      _formatCurrency(_plFeedExpense.round()),
                    ),
                  if (_plMedicineExpense > 0)
                    _rowKV(
                      "medicine_consumption".tr,
                      _formatCurrency(_plMedicineExpense.round()),
                    ),
                  if (_plStockingLaborOther > 0)
                    _rowKV(
                      "stocking_labor_other".tr,
                      _formatCurrency(_plStockingLaborOther.round()),
                    ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final netPl =
                          _plHarvestIncome -
                          (_plFeedExpense +
                              _plMedicineExpense +
                              _plStockingLaborOther);
                      final isLoss = netPl < 0;
                      return _rowKV(
                        "net_profit_loss".tr,
                        _formatCurrency(netPl.round()),
                        bold: true,
                        valueColor: isLoss ? _red : _green,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    textName: "pl_note".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey.shade500,
                    fontSize: 9,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plShimmerRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 70,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildStockReport() {
    final bool isFeed = _selectedStockTab == "Feed";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _toggleItem(
                  "Feed",
                  _selectedStockTab,
                  (v) => setState(() => _selectedStockTab = v),
                ),
                _toggleItem(
                  "Medicine",
                  _selectedStockTab,
                  (v) => setState(() => _selectedStockTab = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildFarmDropdown(),
          const SizedBox(height: 12),
          _buildTankDropdown(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textName: "from".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade700,
                      fontSize: 10,
                    ),
                    const SizedBox(height: 4),
                    _dateFieldDynamic(_srFromController),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textName: "to".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade700,
                      fontSize: 10,
                    ),
                    const SizedBox(height: 4),
                    _dateFieldDynamic(_srToController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: _fetchActiveStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: CustomText(
                textName: "apply".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.semiBold,
                textColor: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (isFeed) _buildFeedSection() else _buildMedicineSection(),
        ],
      ),
    );
  }

  Widget _buildFeedSection() {
    return Obx(() {
      final data = _feedController.bottomfeedDataResponce.value;
      final summary = data.summary;
      final rows = data.data ?? [];

      final double totalPurchasedD = _parseNum(summary?.quantityPurchased);
      final double totalValueD = _parseNum(summary?.totalAmount);
      final int totalPurchased = totalPurchasedD.round();
      final int totalValue = totalValueD.round();
      final int totalRecords = _parseNum(summary?.totalRecords).round();
      final double avgPrice =
          totalPurchasedD > 0 ? (totalValueD / totalPurchasedD) : 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _summaryBlock(
                        label: "total_quantity".tr,
                        value: "$totalPurchased kg",
                      ),
                    ),
                    Expanded(
                      child: _summaryBlock(
                        label: "total_value".tr,
                        value: _formatCurrency(totalValue),
                        valueColor: _green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _summaryBlock(
                        label: "total_records".tr,
                        value: "$totalRecords",
                      ),
                    ),
                    Expanded(
                      child: _summaryBlock(
                        label: "avg_price_kg".tr,
                        value: "₹${avgPrice.toStringAsFixed(0)}",
                        valueColor: _red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _headerCell("feed_col".tr, flex: 4),
                    _headerCell("qty_col".tr, flex: 3),
                    _headerCell("price_kg_col".tr, flex: 3),
                    _headerCell("total_col".tr, flex: 3),
                  ],
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CustomText(
                        textName: "no_feed_purchases".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  ...rows.map((row) {
                    final qty = _parseNum(row.quantityPurchased).round();
                    final price = _parseNum(row.pricePerKg).round();
                    final total = _parseNum(row.totalAmount).round();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  textName: row.feedName ?? "feed".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.semiBold,
                                  textColor: AppColors.blackColor,
                                  fontSize: 10,
                                ),
                                CustomText(
                                  textName: row.tankName ?? (row.brand ?? ""),
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.regular,
                                  textColor: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ],
                            ),
                          ),
                          _bodyCell("$qty", flex: 3),
                          _bodyCell("₹$price", flex: 3),
                          _bodyCell(
                            _formatCurrency(total),
                            flex: 3,
                            color: _green,
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CustomText(
            textName: "feed_note".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade500,
            fontSize: 9,
          ),
        ],
      );
    });
  }

  Widget _buildMedicineSection() {
    return Obx(() {
      final data = _medicineController.bottommedicineDataResponce.value;
      final rows = data.data ?? [];
      final count = data.count ?? rows.length;

      double totalQtyD = 0;
      double totalValueD = 0;
      for (final r in rows) {
        totalQtyD += _parseNum(r.quantityPurchased);
        totalValueD += _parseNum(r.totalAmount);
      }
      final int totalQty = totalQtyD.round();
      final int totalValue = totalValueD.round();
      final double avgPrice = totalQtyD > 0 ? (totalValueD / totalQtyD) : 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _summaryBlock(
                        label: "total_quantity".tr,
                        value: "$totalQty ${"units".tr}",
                      ),
                    ),
                    Expanded(
                      child: _summaryBlock(
                        label: "total_value".tr,
                        value: _formatCurrency(totalValue),
                        valueColor: _green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _summaryBlock(
                        label: "total_records".tr,
                        value: "$count",
                      ),
                    ),
                    Expanded(
                      child: _summaryBlock(
                        label: "avg_price_unit".tr,
                        value: "₹${avgPrice.toStringAsFixed(0)}",
                        valueColor: _red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _headerCell("medicine_col".tr, flex: 4),
                    _headerCell("qty_col".tr, flex: 3),
                    _headerCell("price_unit_col".tr, flex: 3),
                    _headerCell("total_col".tr, flex: 3),
                  ],
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CustomText(
                        textName: "no_medicine_purchases".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  ...rows.map((row) {
                    final qty = _parseNum(row.quantityPurchased).round();
                    final price = _parseNum(row.pricePerUnits).round();
                    final total = _parseNum(row.totalAmount).round();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  textName: row.medicineName ?? "medicine".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.semiBold,
                                  textColor: AppColors.blackColor,
                                  fontSize: 10,
                                ),
                                CustomText(
                                  textName: row.tankName ?? (row.brand ?? ""),
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.regular,
                                  textColor: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ],
                            ),
                          ),
                          _bodyCell("$qty", flex: 3),
                          _bodyCell("₹$price", flex: 3),
                          _bodyCell(
                            _formatCurrency(total),
                            flex: 3,
                            color: _green,
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CustomText(
            textName: "medicine_note".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade500,
            fontSize: 9,
          ),
        ],
      );
    });
  }

  Widget _buildStaffAdvances() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Obx(() {
        final data =
            _accountStaffAdvanceController
                .accountstaffadvanceDataResponce
                .value;
        final rows = data.data ?? [];
        final count = data.count ?? rows.length;

        int totalAdvance = 0;
        int approvedCount = 0;
        int pendingCount = 0;
        int rejectedCount = 0;

        for (final r in rows) {
          final amt = int.tryParse(r.amount ?? "0") ?? 0;
          totalAdvance += amt;

          final status =
              (_localAdvanceStatusUpdates[r.id] ?? (r.status ?? "pending"))
                  .toLowerCase();

          if (status == "approved") {
            approvedCount++;
          } else if (status == "pending") {
            pendingCount++;
          } else if (status == "rejected") {
            rejectedCount++;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _smallStatCard(
                    label: "total_advances".tr,
                    value: _formatCurrency(totalAdvance),
                    valueColor: AppColors.blackColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _smallStatCard(
                    label: "records".tr,
                    value: "$count",
                    valueColor: _primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _smallStatCard(
                    label: "approved".tr,
                    value: "$approvedCount",
                    valueColor: _green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _smallStatCard(
                    label: "pending".tr,
                    value: "$pendingCount",
                    valueColor: _red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _smallStatCard(
                    label: "rejected".tr,
                    value: "$rejectedCount",
                    valueColor: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 14),
            if (rows.isEmpty)
              _buildCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        CustomText(
                          textName: "no_advances_recorded".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.medium,
                          textColor: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildWorkerAdvanceCard(row),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildWorkerAdvanceCard(dynamic row) {
    final amount = int.tryParse(row.amount ?? "0") ?? 0;

    final String? rowId = row.id;
    final effectiveStatus =
        (_localAdvanceStatusUpdates[rowId] ?? (row.status ?? "pending"))
            .toLowerCase();

    final isUpdating = rowId != null && _updatingAdvanceIds.contains(rowId);

    Color statusColor;
    if (effectiveStatus == "approved") {
      statusColor = _green;
    } else if (effectiveStatus == "rejected") {
      statusColor = _red;
    } else {
      statusColor = _primary;
    }

    String dateStr = "-";
    if (row.date != null) {
      try {
        final DateTime dt = row.date;
        dateStr =
            "${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)}";
      } catch (_) {
        dateStr = "-";
      }
    }

    return Container(
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
                  textName: dateStr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(
                  textName: _statusLabel(effectiveStatus).toUpperCase(),
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.medium,
                  textColor: statusColor,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statLine(
                  label: "amount".tr,
                  value: _formatCurrency(amount),
                ),
              ),
              Expanded(
                child: _statLine(label: "staff".tr, value: row.staffName ?? "-"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _statLine(label: "purpose".tr, value: row.purpose ?? "-"),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isUpdating) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
              ],

              if (effectiveStatus == "pending")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: effectiveStatus,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.grey,
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "pending",
                          child: Text("pending".tr),
                        ),
                        DropdownMenuItem(
                          value: "approved",
                          child: Text("approved".tr),
                        ),
                        DropdownMenuItem(
                          value: "rejected",
                          child: Text("rejected".tr),
                        ),
                      ],
                      onChanged:
                          isUpdating
                              ? null
                              : (newStatus) => _onAdvanceStatusChanged(
                                row,
                                effectiveStatus,
                                newStatus,
                              ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: CustomText(
                    textName: _statusLabel(effectiveStatus).toUpperCase(),
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: statusColor,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortId(String? id) {
    if (id == null || id.isEmpty) return "-";
    if (id.length <= 8) return id;
    return "${id.substring(0, 8)}…";
  }

  String _monthName(int month) {
    const names = [
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
    return names[month - 1];
  }

  Widget _buildExpenseClaims() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFarmDropdown(),
          const SizedBox(height: 10),
          _buildTankDropdown(),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _claimToggleItem("Pending"),
                _claimToggleItem("Approved"),
                _claimToggleItem("Rejected"),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Obx(() {
            final data =
                _accountGetExpenseController
                    .accountgetexpenseDataResponce
                    .value;
            final allExpenses = data.data ?? [];

            final filtered =
                allExpenses.where((e) {
                  final currentStatus =
                      _localStatusUpdates[e.id] ??
                      (e.status ?? "pending").toLowerCase();

                  if (_selectedClaimTab == "Pending") {
                    return currentStatus == "pending";
                  }
                  if (_selectedClaimTab == "Approved") {
                    return currentStatus == "approved";
                  }
                  if (_selectedClaimTab == "Rejected") {
                    return currentStatus == "rejected";
                  }
                  return true;
                }).toList();

            int totalValue = 0;
            for (final e in filtered) {
              totalValue += _accountExpenseAmount(e);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _smallStatCard(
                        label:
                            "${"total_claims".tr} ${_claimTabLabel(_selectedClaimTab)}",
                        value: _formatCurrency(totalValue),
                        valueColor: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _smallStatCard(
                        label: "records".tr,
                        value: "${filtered.length}",
                        valueColor: _primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  _buildCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            CustomText(
                              textName:
                                  "${"no_claims_found".tr} ${_claimTabLabel(_selectedClaimTab)}",
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.medium,
                              textColor: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAccountExpenseClaimCard(e),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccountExpenseClaimCard(acc_exp.Datum e) {
    final amount = _accountExpenseAmount(e);
    final category = e.category ?? "expense".tr;

    final currentStatus =
        _localStatusUpdates[e.id] ?? (e.status ?? "pending").toLowerCase();

    final isUpdating = e.id != null && _updatingClaimIds.contains(e.id);

    String dateStr = "-";
    if (e.date != null) {
      dateStr =
          "${e.date!.day.toString().padLeft(2, '0')} ${_monthName(e.date!.month)}";
    }

    Color categoryColor = _primary;
    final cat = category.toLowerCase();
    if (cat.contains("labour") || cat.contains("salary")) {
      categoryColor = const Color(0xFF6A1B9A);
    } else if (cat.contains("diesel") || cat.contains("petrol")) {
      categoryColor = const Color(0xFFE65100);
    } else if (cat.contains("electrical")) {
      categoryColor = const Color(0xFF0277BD);
    } else if (cat.contains("plumbing")) {
      categoryColor = const Color(0xFF00838F);
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomText(
                        textName: _categoryLabel(category).toUpperCase(),
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.semiBold,
                        textColor: categoryColor,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomText(
                      textName: dateStr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ],
                ),
              ),
              CustomText(
                textName: _formatCurrency(amount),
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: AppColors.blackColor,
                fontSize: 13,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._accountExpenseDetailLines(e),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isUpdating) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
              ],

              if (currentStatus == "pending")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentStatus,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.grey,
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "pending",
                          child: Text("pending".tr),
                        ),
                        DropdownMenuItem(
                          value: "approved",
                          child: Text("approved".tr),
                        ),
                        DropdownMenuItem(
                          value: "rejected",
                          child: Text("rejected".tr),
                        ),
                      ],
                      onChanged:
                          isUpdating
                              ? null
                              : (newStatus) =>
                                  _onStatusChanged(e, currentStatus, newStatus),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(currentStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _statusColor(currentStatus).withOpacity(0.3),
                    ),
                  ),
                  child: CustomText(
                    textName: _statusLabel(currentStatus).toUpperCase(),
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: _statusColor(currentStatus),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 🌐 Category display label
  String _categoryLabel(String cat) {
    final c = cat.toLowerCase().trim();
    if (c == "labour") return "labour_label".tr;
    if (c == "salary") return "salary_label".tr;
    if (c == "tiffins" || c == "tiffinsmeals" || c == "tiffins/meals") {
      return "tiffins_meals_label".tr;
    }
    if (c == "petrol") return "petrol_label".tr;
    if (c == "diesel") return "diesel_label".tr;
    if (c == "transport") return "transport_label".tr;
    if (c == "utilities") return "utilities_label".tr;
    if (c == "electrical") return "electrical_label".tr;
    if (c == "plumbing") return "plumbing_label".tr;
    if (c == "other") return "other_label".tr;
    if (c == "expense") return "expense".tr;
    return cat;
  }

  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return _green;
      case "rejected":
        return _red;
      case "pending":
      default:
        return _primary;
    }
  }

  List<Widget> _accountExpenseDetailLines(acc_exp.Datum e) {
    final lines = <Widget>[];

    if (e.labour != null) {
      final persons = e.labour!.noofpersonsWorked ?? "0";
      final charge = e.labour!.chargesPerPerson ?? "0";
      lines.add(_detailLine("persons".tr, persons));
      lines.add(_detailLine("charges_per_person".tr, "₹$charge"));
    }
    if (e.salary != null) {
      final count = e.salary!.persons?.length ?? 0;
      lines.add(_detailLine("staff_count".tr, "$count"));
      lines.add(
        _detailLine(
          "total_salaries".tr,
          "₹${e.salary!.totalSalaries ?? '0'}",
        ),
      );
    }
    if (e.electrical != null) {
      lines.add(_detailLine("item".tr, e.electrical!.itemName ?? "-"));
      lines.add(
        _detailLine(
          "qty_x_price".tr,
          "${e.electrical!.quantity ?? 0} × ₹${e.electrical!.pricePerUnit ?? 0}",
        ),
      );
    }
    if (e.plumbing != null) {
      lines.add(_detailLine("item".tr, e.plumbing!.itemName ?? "-"));
      lines.add(
        _detailLine(
          "qty_x_price".tr,
          "${e.plumbing!.quantity ?? 0} × ₹${e.plumbing!.pricePerQuantity ?? 0}",
        ),
      );
    }
    if (lines.isEmpty) {
      lines.add(_detailLine("category".tr, _categoryLabel(e.category ?? "-")));
    }
    return lines;
  }

  int _accountExpenseAmount(acc_exp.Datum e) {
    int total = 0;
    if (e.labour?.totalLabourCost != null) {
      total += int.tryParse(e.labour!.totalLabourCost!) ?? 0;
    }
    if (e.salary?.totalSalaries != null) {
      total += int.tryParse(e.salary!.totalSalaries!) ?? 0;
    }
    total += (e.diesel?.amount ?? 0).round();
    total += (e.petrol?.amount ?? 0).round();
    total += (e.tiffinsMeals?.amount ?? 0).round();
    total += (e.transport?.amount ?? 0).round();
    total += (e.utilities?.amount ?? 0).round();
    total += (e.other?.amount ?? 0).round();
    total += (e.electrical?.total ?? 0).round();
    total += (e.plumbing?.total ?? 0).round();
    return total;
  }

  Widget _claimToggleItem(String label) {
    final isSelected = _selectedClaimTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedClaimTab = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              textName: _claimTabLabel(label),
              fontFamily: FontFamily.poppins,
              fontWeightType:
                  isSelected ? FontWeightType.semiBold : FontWeightType.regular,
              textColor:
                  isSelected ? AppColors.blackColor : Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleItem(String label, String current, Function(String) onTap) {
    final isSelected = current == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(label),
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
              textName: _stockTabLabel(label),
              fontFamily: FontFamily.poppins,
              fontWeightType:
                  isSelected ? FontWeightType.semiBold : FontWeightType.regular,
              textColor:
                  isSelected ? AppColors.blackColor : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.semiBold,
        textColor: Colors.grey.shade700,
        fontSize: 9,
      ),
    );
  }

  Widget _rowKV(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              textName: label,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade700,
              fontSize: 11,
            ),
          ),
          CustomText(
            textName: value,
            fontFamily: FontFamily.poppins,
            fontWeightType:
                bold ? FontWeightType.bold : FontWeightType.semiBold,
            textColor: valueColor ?? AppColors.blackColor,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _summaryBlock({
    required String label,
    required String value,
    Color? valueColor,
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
          textColor: valueColor ?? AppColors.blackColor,
          fontSize: 13,
        ),
      ],
    );
  }

  Widget _smallStatCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 4),
          CustomText(
            textName: value,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: valueColor,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _statLine({required String label, required String value}) {
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
        const SizedBox(height: 2),
        CustomText(
          textName: value,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
          fontSize: 11,
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
        fontSize: 8,
      ),
    );
  }

  Widget _bodyCell(String text, {required int flex, Color? color}) {
    return Expanded(
      flex: flex,
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.regular,
        textColor: color ?? AppColors.blackColor,
        fontSize: 9,
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              textName: label,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
          CustomText(
            textName: value,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.semiBold,
            textColor: AppColors.blackColor,
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  int num2int(num? n) => (n ?? 0).round();

  String _numStr(num? n) {
    if (n == null) return "0";
    if (n is int) return n.toString();
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toString();
  }

  String _formatCurrency(int value) {
    final isNegative = value < 0;
    final abs = value.abs();
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

  double _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9.\-]'), '');
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  void showReimburseDialog(BuildContext context, String staffName) {}
  void showBalanceReturnedDialog(BuildContext context, String staffName) {}
}
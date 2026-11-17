import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/account_get_expence_model.dart'
    as account_expense;
import 'package:superapp/model/over_view/bottom_pandl_model.dart';
import 'package:superapp/model/tank/get_form_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/view_model/api_controllers/over_view/account_get_expense_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/bottom_pandl_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/feed_party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/expense_party_controller.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_all_tank_conteoller.dart';
import 'package:superapp/view_model/api_controllers/tank/get_form_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

typedef ExpenseDatum = account_expense.Datum;

class FarmPLExportScreen extends StatefulWidget {
  const FarmPLExportScreen({super.key});

  @override
  State<FarmPLExportScreen> createState() => _FarmPLExportScreenState();
}

class _FarmPLExportScreenState extends State<FarmPLExportScreen> {
  final Color _primary = const Color(0xFF006D77);
  final Color _green = const Color(0xFF1B9C4A);
  final Color _red = const Color(0xFFE53935);

  final _profileController = Get.find<ProfileController>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  final GetAllTankConteoller _tankController = Get.find<GetAllTankConteoller>();
  final BottomPandlController _bottomPandlController =
      Get.find<BottomPandlController>();
  final GetFormController _getFormController = Get.find<GetFormController>();

  late final MedicinePartyController _medicinePartyController;
  late final FeedPartyController _feedPartyController;
  late final ExpensePartyController _expensePartyController;

  late final AccountGetExpenseController _accountGetExpenseController;

  Datum? _selectedFarm;

  static const String _allTanksLabel = "All tanks";
  String _selectedTank = _allTanksLabel;

  final RxBool _isLoadingPl = false.obs;

  final RxList<Harvest> _aggregatedHarvests = <Harvest>[].obs;
  final RxList<Expense> _aggregatedExpenses = <Expense>[].obs;
  final RxList<ExpenseDatum> _aggregatedAccountExpenses =
      <ExpenseDatum>[].obs;
  final RxList<Medicine> _aggregatedMedicines = <Medicine>[].obs;
  final RxList<Purchase> _aggregatedPurchases = <Purchase>[].obs;
  final RxList<Stock> _aggregatedStocks = <Stock>[].obs;

  List<String> get _tankOptions {
    final List<String> options = [_allTanksLabel];
    final tanks = _tankController.tanksDataResponce.value.tanks;
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

    if (Get.isRegistered<MedicinePartyController>()) {
      _medicinePartyController = Get.find<MedicinePartyController>();
    } else {
      _medicinePartyController = Get.put(
        MedicinePartyController(OverviewService()),
      );
    }
    _medicinePartyController.fetchmedicinepartydata();

    if (Get.isRegistered<FeedPartyController>()) {
      _feedPartyController = Get.find<FeedPartyController>();
    } else {
      _feedPartyController = Get.put(FeedPartyController(OverviewService()));
    }
    _feedPartyController.fetchfeddpartydata();

    if (Get.isRegistered<ExpensePartyController>()) {
      _expensePartyController = Get.find<ExpensePartyController>();
    } else {
      _expensePartyController = Get.put(
        ExpensePartyController(OverviewService()),
      );
    }
    _expensePartyController.fetchexpensepartydata();

    if (Get.isRegistered<AccountGetExpenseController>()) {
      _accountGetExpenseController = Get.find<AccountGetExpenseController>();
    } else {
      _accountGetExpenseController = Get.put(
        AccountGetExpenseController(OverviewService()),
      );
    }

    if (_getFormController.getformDataResponce.value.data == null) {
      _getFormController.fetchgetformdata();
    }

    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    _fromController.text = _formatDate(from);
    _toController.text = _formatDate(now);

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
      _fetchBottomPandl();
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
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
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
      setState(() => controller.text = _formatDate(picked));
    }
  }

  Future<void> _fetchBottomPandl() async {
    final fromDate = _fromController.text;
    final toDate = _toController.text;

    _isLoadingPl.value = true;

    try {
      if (_selectedTank == _allTanksLabel) {
        await _fetchAllTanksAggregated(fromDate: fromDate, toDate: toDate);
      } else {
        await _fetchSingleTank(fromDate: fromDate, toDate: toDate);
      }
    } catch (e) {
      debugPrint("P&L fetch error: $e");
    } finally {
      _isLoadingPl.value = false;
    }
  }

  Future<void> _fetchAllTanksAggregated({
    required String fromDate,
    required String toDate,
  }) async {
    final tanks = _tankController.tanksDataResponce.value.tanks ?? [];

    _aggregatedHarvests.clear();
    _aggregatedExpenses.clear();
    _aggregatedAccountExpenses.clear();
    _aggregatedMedicines.clear();
    _aggregatedPurchases.clear();
    _aggregatedStocks.clear();

    for (final tank in tanks) {
      final tankId = tank.id;
      if (tankId == null || tankId.isEmpty) continue;

      await _bottomPandlController.fetchbottompandl(
        tankId: tankId,
        fromDate: fromDate,
        toDate: toDate,
        farmId: _selectedFarm?.id ?? "",
      );

      _accountGetExpenseController.fetchaccountgetexpencedata(
        tankId: tankId,
        farmId: _selectedFarm?.id ?? "",
      );

      final data = _bottomPandlController.bottomplDataResponce.value;

      if (data.harvests != null) {
        _aggregatedHarvests.addAll(data.harvests!);
      }
      if (data.expenses != null) {
        _aggregatedExpenses.addAll(data.expenses!);
      }
      if (data.medicines != null) {
        _aggregatedMedicines.addAll(data.medicines!);
      }
      if (data.purchases != null) {
        _aggregatedPurchases.addAll(data.purchases!);
      }
      if (data.overview != null) {
        for (final ov in data.overview!) {
          if (ov.stocks != null) {
            _aggregatedStocks.addAll(ov.stocks!);
          }
        }
      }

      final expenseData =
          _accountGetExpenseController.accountgetexpenseDataResponce.value;
      if (expenseData.data != null) {
        _aggregatedAccountExpenses.addAll(
          expenseData.data!
              .where((e) => (e.status ?? '').toLowerCase() == 'approved'),
        );
      }
    }
  }

  Future<void> _fetchSingleTank({
    required String fromDate,
    required String toDate,
  }) async {
    final tankId = _resolveTankId();
    if (tankId == null || tankId.isEmpty) return;

    _aggregatedHarvests.clear();
    _aggregatedExpenses.clear();
    _aggregatedAccountExpenses.clear();
    _aggregatedMedicines.clear();
    _aggregatedPurchases.clear();
    _aggregatedStocks.clear();

    await _bottomPandlController.fetchbottompandl(
      tankId: tankId,
      fromDate: fromDate,
      toDate: toDate,
      farmId: _selectedFarm?.id ?? "",
    );

    _accountGetExpenseController.fetchaccountgetexpencedata(
      tankId: tankId,
      farmId: _selectedFarm?.id ?? "",
    );
  }

  String? _resolveTankId() {
    final tanks = _tankController.tanksDataResponce.value.tanks;
    if (tanks == null || tanks.isEmpty) return null;

    for (final t in tanks) {
      if (t.name == _selectedTank) return t.id;
    }
    return tanks.first.id;
  }

  String? _tankNameForId(String? tankId) {
    if (tankId == null || tankId.isEmpty) return null;
    final tanks = _tankController.tanksDataResponce.value.tanks ?? [];
    for (final t in tanks) {
      if (t.id == tankId) return t.name;
    }
    return null;
  }

  List<Harvest> _currentHarvests() {
    if (_selectedTank == _allTanksLabel) return _aggregatedHarvests;
    return _bottomPandlController.bottomplDataResponce.value.harvests ?? [];
  }

  List<Expense> _currentExpenses() {
    if (_selectedTank == _allTanksLabel) return _aggregatedExpenses;
    return _bottomPandlController.bottomplDataResponce.value.expenses ?? [];
  }

  List<ExpenseDatum> _currentAccountExpenses() {
    if (_selectedTank == _allTanksLabel) return _aggregatedAccountExpenses;
    final list =
        _accountGetExpenseController.accountgetexpenseDataResponce.value.data ??
            [];
    return list
        .where((e) => (e.status ?? '').toLowerCase() == 'approved')
        .toList();
  }

  List<Medicine> _currentMedicines() {
    if (_selectedTank == _allTanksLabel) return _aggregatedMedicines;
    return _bottomPandlController.bottomplDataResponce.value.medicines ?? [];
  }

  List<Purchase> _currentPurchases() {
    if (_selectedTank == _allTanksLabel) return _aggregatedPurchases;
    return _bottomPandlController.bottomplDataResponce.value.purchases ?? [];
  }

  List<Stock> _currentStocks() {
    if (_selectedTank == _allTanksLabel) return _aggregatedStocks;
    final overview =
        _bottomPandlController.bottomplDataResponce.value.overview ?? [];
    final List<Stock> list = [];
    for (final ov in overview) {
      if (ov.stocks != null) list.addAll(ov.stocks!);
    }
    return list;
  }

  double _incomeTotal(List<Harvest> harvests) {
    double t = 0;
    for (final h in harvests) {
      t += double.tryParse(h.totalAmount ?? "0") ?? 0;
    }
    return t;
  }

  double _medicineTotal(List<Medicine> medicines) {
    double t = 0;
    for (final m in medicines) {
      t += double.tryParse(m.totalAmount ?? "0") ?? 0;
    }
    return t;
  }

  double _expenseTotal(List<Expense> expenses) {
    double t = 0;
    for (final e in expenses) {
      t += _expenseAmount(e);
    }
    return t;
  }

  double _accountExpenseTotal(List<ExpenseDatum> expenses) {
    double t = 0;
    for (final e in expenses) {
      t += _accountExpenseAmount(e);
    }
    return t;
  }

  double _stockTotal(List<Stock> stocks) {
    double t = 0;
    for (final s in stocks) {
      t += double.tryParse(s.totalAmount ?? "0") ?? 0;
    }
    return t;
  }

  double _feedTotal(List<Purchase> purchases) {
    double t = 0;
    for (final p in purchases) {
      t += double.tryParse(p.totalAmount ?? "0") ?? 0;
    }
    return t;
  }

  double _partyPurchasesTotal() {
    double t = 0;

    final medList =
        _medicinePartyController.medicinepartyDataResponce.value.data ?? [];
    for (final item in medList) {
      t += double.tryParse(item.amount ?? "0") ?? 0;
    }

    final feedList =
        _feedPartyController.feedpartyDataResponce.value.data ?? [];
    for (final item in feedList) {
      t += double.tryParse(item.totalAmount ?? "0") ?? 0;
    }

    final expList =
        _expensePartyController.expenseDataResponce.value.data ?? [];
    for (final item in expList) {
      t += double.tryParse(item.amount ?? "0") ?? 0;
    }

    return t;
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
                    textName: "farm_pl_export".tr,
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("farm_name".tr),
                    const SizedBox(height: 6),
                    _buildFarmDropdown(),
                    const SizedBox(height: 14),

                    _buildLabel("tank".tr),
                    const SizedBox(height: 6),
                    Obx(() {
                      final tanks =
                          _tankController.tanksDataResponce.value.tanks;

                      if (tanks == null) {
                        return _shimmerBox(height: 48, radius: 8);
                      }

                      final options = _tankOptions;
                      if (!options.contains(_selectedTank)) {
                        _selectedTank = options.first;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTank,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade700,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            items: options.map((t) {
                              return DropdownMenuItem<String>(
                                value: t,
                                child: CustomText(
                                  textName: t == _allTanksLabel
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
                              if (v == null || v == _selectedTank) return;
                              setState(() => _selectedTank = v);
                              _fetchBottomPandl();
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("from".tr),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _fromController,
                                hint: "yyyy_mm_dd".tr,
                                readOnly: true,
                                onTap: () => _pickDate(_fromController),
                                suffixIcon: Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("to".tr),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _toController,
                                hint: "yyyy_mm_dd".tr,
                                readOnly: true,
                                onTap: () => _pickDate(_toController),
                                suffixIcon: Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _fetchBottomPandl,
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
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(() {
                      _medicinePartyController.medicinepartyDataResponce.value;
                      _feedPartyController.feedpartyDataResponce.value;
                      _expensePartyController.expenseDataResponce.value;
                      _accountGetExpenseController
                          .accountgetexpenseDataResponce.value;

                      if (_isLoadingPl.value) {
                        return _buildShimmerLoading();
                      }

                      final harvests = _currentHarvests();
                      final expenses = _currentExpenses();
                      final accountExpenses = _currentAccountExpenses();
                      final medicines = _currentMedicines();
                      final purchases = _currentPurchases();
                      final stocks = _currentStocks();

                      final double totalIncome = _incomeTotal(harvests);
                      final double medicineAmt = _medicineTotal(medicines);
                      final double expenseAmt = _expenseTotal(expenses);
                      final double accountExpenseAmt =
                          _accountExpenseTotal(accountExpenses);
                      final double stockAmt = _stockTotal(stocks);
                      final double feedAmt = _feedTotal(purchases);

                      final double partyPurchases = _partyPurchasesTotal();

                      final double totalExpense = medicineAmt +
                          expenseAmt +
                          accountExpenseAmt +
                          stockAmt +
                          feedAmt +
                          partyPurchases;

                      final double netPl = totalIncome - totalExpense;
                      final bool isNetLoss = netPl < 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _miniStat(
                                  label: "total_income".tr,
                                  value: _formatCurrency(totalIncome),
                                  valueColor: _green,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _miniStat(
                                  label: "total_expenses".tr,
                                  value: _formatCurrency(totalExpense),
                                  valueColor: _red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _miniStat(
                            label: "net_pl".tr,
                            value: _formatCurrency(netPl),
                            valueColor: isNetLoss ? _red : _green,
                          ),
                          const SizedBox(height: 16),

                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  textName: "expense_breakdown".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.bold,
                                  textColor: AppColors.blackColor,
                                  fontSize: 13,
                                ),
                                const SizedBox(height: 12),
                                _itemRow(
                                  "medicine".tr,
                                  _formatCurrency(medicineAmt),
                                ),
                                _itemRow(
                                  "expense".tr,
                                  _formatCurrency(expenseAmt),
                                ),
                                _itemRow(
                                  "account_expense_approved".tr,
                                  _formatCurrency(accountExpenseAmt),
                                ),
                                _itemRow("stock".tr, _formatCurrency(stockAmt)),
                                _itemRow("feed".tr, _formatCurrency(feedAmt)),
                                _itemRow(
                                  "party_purchases".tr,
                                  _formatCurrency(partyPurchases),
                                ),
                                Divider(
                                  height: 18,
                                  color: Colors.grey.shade200,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomText(
                                        textName: "total_expenses_lbl".tr,
                                        fontFamily: FontFamily.poppins,
                                        fontWeightType:
                                            FontWeightType.semiBold,
                                        textColor: AppColors.blackColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    CustomText(
                                      textName: _formatCurrency(totalExpense),
                                      fontFamily: FontFamily.poppins,
                                      fontWeightType: FontWeightType.bold,
                                      textColor: _red,
                                      fontSize: 13,
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
                                    _tableHeader("tank_col".tr, flex: 4),
                                    _tableHeader("income_col".tr, flex: 4),
                                    _tableHeader("expenses_col".tr, flex: 4),
                                    _tableHeader("net_pl_col".tr, flex: 4),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Divider(
                                  height: 1,
                                  color: Colors.grey.shade200,
                                ),
                                if (harvests.isEmpty &&
                                    expenses.isEmpty &&
                                    accountExpenses.isEmpty &&
                                    medicines.isEmpty &&
                                    purchases.isEmpty &&
                                    stocks.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Center(
                                      child: CustomText(
                                        textName: "no_data_available".tr,
                                        fontFamily: FontFamily.poppins,
                                        fontWeightType:
                                            FontWeightType.regular,
                                        textColor: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                else
                                  ..._buildTankSummaryRows(
                                    harvests,
                                    expenses,
                                    accountExpenses,
                                    medicines,
                                    purchases,
                                    stocks,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  textName: "item_wise_detail".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.bold,
                                  textColor: AppColors.blackColor,
                                  fontSize: 13,
                                ),
                                const SizedBox(height: 12),

                                if (medicines.isNotEmpty) ...[
                                  _sectionLabel("medicine_items_used".tr),
                                  ...medicines.map((m) {
                                    final qty = m.quantityPurchased ?? "0";
                                    final amt =
                                        double.tryParse(m.totalAmount ?? "0") ??
                                            0;
                                    final label =
                                        "${m.medicineName ?? 'Medicine'} · $qty";
                                    return _itemRow(
                                      label,
                                      _formatCurrency(amt),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                ],

                                if (expenses.isNotEmpty) ...[
                                  _sectionLabel("expense_items".tr),
                                  ...expenses.map((e) {
                                    final label = _expenseLabel(e);
                                    final amt = _expenseAmount(e);
                                    return _itemRow(
                                      label,
                                      _formatCurrency(amt),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                ],

                                if (accountExpenses.isNotEmpty) ...[
                                  _sectionLabel(
                                      "approved_account_expense_items".tr),
                                  ...accountExpenses.map((e) {
                                    final label = _accountExpenseLabel(e);
                                    final amt = _accountExpenseAmount(e);
                                    return _itemRow(
                                      label,
                                      _formatCurrency(amt),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                ],

                                if (purchases.isNotEmpty) ...[
                                  _sectionLabel("feed_items".tr),
                                  ...purchases.map((p) {
                                    final qty = p.quantityPurchased ?? "0";
                                    final amt =
                                        double.tryParse(p.totalAmount ?? "0") ??
                                            0;
                                    final label =
                                        "${p.feedName ?? 'Feed'} · $qty kg";
                                    return _itemRow(
                                      label,
                                      _formatCurrency(amt),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                ],

                                if (stocks.isNotEmpty) ...[
                                  _sectionLabel("stock_items".tr),
                                  ...stocks.map((s) {
                                    final qty = s.quantityStocked ?? "0";
                                    final amt =
                                        double.tryParse(s.totalAmount ?? "0") ??
                                            0;
                                    final label =
                                        "${s.speciesName ?? 'Stock'} · $qty";
                                    return _itemRow(
                                      label,
                                      _formatCurrency(amt),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                ],

                                if (harvests.isNotEmpty) ...[
                                  _sectionLabel("income_items".tr),
                                  ...harvests.map((h) {
                                    final qty = h.quantityHarvested ?? "0";
                                    final amt =
                                        double.tryParse(h.totalAmount ?? "0") ??
                                            0;
                                    final label =
                                        "${h.harvestType ?? 'Harvest'} — ${h.tankName ?? ''} · $qty";
                                    return _itemRow(
                                      label,
                                      _formatCurrency(amt),
                                      valueColor: _green,
                                    );
                                  }),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  textName: "income_vs_expenses".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.bold,
                                  textColor: AppColors.blackColor,
                                  fontSize: 13,
                                ),
                                const SizedBox(height: 16),
                                _buildSyncfusionChart(
                                  harvests,
                                  expenses,
                                  accountExpenses,
                                  medicines,
                                  purchases,
                                  stocks,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _exportPdf,
                            icon: Icon(
                              Icons.share_outlined,
                              size: 16,
                              color: _primary,
                            ),
                            label: CustomText(
                              textName: "share_pdf".tr,
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _exportCsv,
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _downloadPdf,
                            icon: Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 16,
                              color: _primary,
                            ),
                            label: CustomText(
                              textName: "download_pdf".tr,
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildSyncfusionChart(
    List<Harvest> harvests,
    List<Expense> expenses,
    List<ExpenseDatum> accountExpenses,
    List<Medicine> medicines,
    List<Purchase> purchases,
    List<Stock> stocks,
  ) {
    final chartData = _buildChartData(
      harvests,
      expenses,
      accountExpenses,
      medicines,
      purchases,
      stocks,
    );

    if (chartData.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: CustomText(
            textName: "no_data_to_display".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      );
    }

    return SizedBox(
      height: 270,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          labelStyle: const TextStyle(fontSize: 9),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          labelStyle: const TextStyle(fontSize: 9),
          numberFormat: NumberFormat.compactCurrency(
            locale: 'en_IN',
            symbol: '₹',
            decimalDigits: 0,
          ),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          textStyle: const TextStyle(fontSize: 10),
        ),
        series: <CartesianSeries>[
          ColumnSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData d, _) => d.label,
            yValueMapper: (_ChartData d, _) => d.income,
            name: 'income_col'.tr,
            color: _green,
            width: 0.4,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(fontSize: 8),
            ),
          ),
          ColumnSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData d, _) => d.label,
            yValueMapper: (_ChartData d, _) => d.expense,
            name: 'expenses_col'.tr,
            color: _red,
            width: 0.4,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              textStyle: TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  List<_ChartData> _buildChartData(
    List<Harvest> harvests,
    List<Expense> expenses,
    List<ExpenseDatum> accountExpenses,
    List<Medicine> medicines,
    List<Purchase> purchases,
    List<Stock> stocks,
  ) {
    final Set<String> tankNames = {};

    for (final h in harvests) {
      if (h.tankName != null && h.tankName!.isNotEmpty) {
        tankNames.add(h.tankName!);
      }
    }
    for (final e in expenses) {
      if (e.tankName != null && e.tankName!.isNotEmpty) {
        tankNames.add(e.tankName!);
      }
    }
    for (final e in accountExpenses) {
      final tn = _tankNameForId(e.tankId);
      if (tn != null && tn.isNotEmpty) tankNames.add(tn);
    }
    for (final m in medicines) {
      if (m.tankName != null && m.tankName!.isNotEmpty) {
        tankNames.add(m.tankName!);
      }
    }
    for (final p in purchases) {
      if (p.tankName != null && p.tankName!.isNotEmpty) {
        tankNames.add(p.tankName!);
      }
    }

    if (tankNames.isEmpty) {
      final tanks = _tankController.tanksDataResponce.value.tanks ?? [];
      for (final t in tanks) {
        if (t.name != null && t.name!.isNotEmpty) {
          tankNames.add(t.name!);
        }
      }
    }

    final double partyTotal = _partyPurchasesTotal();
    final int denom = tankNames.isEmpty ? 1 : tankNames.length;
    final double partyPerTank = partyTotal / denom;

    final double totalStock = _stockTotal(stocks);
    final double stockPerTank = totalStock / denom;

    final List<_ChartData> result = [];
    for (final name in tankNames) {
      double income = 0;
      double expense = 0;

      for (final h in harvests) {
        if (h.tankName == name) {
          income += double.tryParse(h.totalAmount ?? "0") ?? 0;
        }
      }

      for (final e in expenses) {
        if (e.tankName == name) {
          expense += _expenseAmount(e);
        }
      }

      for (final e in accountExpenses) {
        if (_tankNameForId(e.tankId) == name) {
          expense += _accountExpenseAmount(e);
        }
      }

      for (final m in medicines) {
        if (m.tankName == name) {
          expense += double.tryParse(m.totalAmount ?? "0") ?? 0;
        }
      }

      for (final p in purchases) {
        if (p.tankName == name) {
          expense += double.tryParse(p.totalAmount ?? "0") ?? 0;
        }
      }

      expense += partyPerTank + stockPerTank;

      result.add(_ChartData(label: name, income: income, expense: expense));
    }

    return result;
  }

  Widget _buildFarmDropdown() {
    return Obx(() {
      final response = _getFormController.getformDataResponce.value;

      if (response.data == null || response.data!.isEmpty) {
        final isLoading = response.success == null;

        if (isLoading) {
          return _shimmerBox(height: 48, radius: 8);
        }

        return Container(
          height: 48,
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
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        );
      }

      final farmList = response.data!;
      final bool isValid = _selectedFarm != null &&
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
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            items: farmList.map((farm) {
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
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedFarm = value;
                _selectedTank = _allTanksLabel;
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

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _shimmerBox(height: 60, radius: 10)),
            const SizedBox(width: 10),
            Expanded(child: _shimmerBox(height: 60, radius: 10)),
          ],
        ),
        const SizedBox(height: 10),
        _shimmerBox(height: 60, radius: 10),
        const SizedBox(height: 16),
        _buildCard(child: _shimmerBox(height: 100, radius: 6)),
        const SizedBox(height: 14),
        _buildCard(child: _shimmerBox(height: 100, radius: 6)),
      ],
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    double radius = 6,
  }) =>
      _ShimmerBox(height: height, width: width, radius: radius);

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
        return (e.tiffinsMeals?.amount ?? 0).toDouble();
      case "petrol":
        return (e.petrol?.amount ?? 0).toDouble();
      case "diesel":
        return (e.diesel?.amount ?? 0).toDouble();
      case "transport":
        return (e.transport?.amount ?? 0).toDouble();
      case "utilities":
        return (e.utilities?.amount ?? 0).toDouble();
      case "other":
        return (e.other?.amount ?? 0).toDouble();
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
    if (e.tiffinsMeals?.amount != null) {
      return e.tiffinsMeals!.amount!.toDouble();
    }
    if (e.petrol?.amount != null) return e.petrol!.amount!.toDouble();
    if (e.diesel?.amount != null) return e.diesel!.amount!.toDouble();
    if (e.transport?.amount != null) return e.transport!.amount!.toDouble();
    if (e.utilities?.amount != null) return e.utilities!.amount!.toDouble();
    if (e.other?.amount != null) return e.other!.amount!.toDouble();
    if (e.electrical?.total != null) return e.electrical!.total!.toDouble();
    if (e.plumbing?.total != null) return e.plumbing!.total!.toDouble();

    return 0;
  }

  String _expenseLabel(Expense e) {
    final cat = (e.category ?? "").toLowerCase().trim();

    switch (cat) {
      case "labour":
        final p = e.labour?.noofpersonsWorked ?? "0";
        final c = e.labour?.chargesPerPerson ?? "0";
        return "${"labour_label".tr} — $p ${"persons".tr} × ₹$c";
      case "salary":
        final n = e.salary?.persons?.length ?? 0;
        return "${"salary_label".tr} — $n ${"person_s".tr}";
      case "tiffins":
      case "tiffinsmeals":
      case "tiffins/meals":
        return "${"tiffins_meals_label".tr} — ${e.tiffinsMeals?.description ?? ''}";
      case "petrol":
        return "${"petrol_label".tr} — ${e.petrol?.description ?? ''}";
      case "diesel":
        return "${"diesel_label".tr} — ${e.diesel?.description ?? ''}";
      case "transport":
        return "${"transport_label".tr} — ${e.transport?.description ?? ''}";
      case "utilities":
        return "${"utilities_label".tr} — ${e.utilities?.description ?? ''}";
      case "electrical":
        return "${"electrical_label".tr} — ${e.electrical?.itemName ?? ''}";
      case "plumbing":
        return "${"plumbing_label".tr} — ${e.plumbing?.itemName ?? ''}";
      case "other":
        return "${"other_label".tr} — ${e.other?.description ?? ''}";
    }

    if (e.labour != null && e.labour!.totalLabourCost != null) {
      final p = e.labour!.noofpersonsWorked ?? "0";
      final c = e.labour!.chargesPerPerson ?? "0";
      return "${"labour_label".tr} — $p ${"persons".tr} × ₹$c";
    }
    if (e.salary != null && e.salary!.totalSalaries != null) {
      final n = e.salary!.persons?.length ?? 0;
      return "${"salary_label".tr} — $n ${"person_s".tr}";
    }
    if (e.diesel != null && e.diesel!.amount != null) {
      return "${"diesel_label".tr} — ${e.diesel!.description ?? ''}";
    }
    if (e.petrol != null && e.petrol!.amount != null) {
      return "${"petrol_label".tr} — ${e.petrol!.description ?? ''}";
    }
    if (e.tiffinsMeals != null && e.tiffinsMeals!.amount != null) {
      return "${"tiffins_meals_label".tr} — ${e.tiffinsMeals!.description ?? ''}";
    }
    if (e.transport != null && e.transport!.amount != null) {
      return "${"transport_label".tr} — ${e.transport!.description ?? ''}";
    }
    if (e.utilities != null && e.utilities!.amount != null) {
      return "${"utilities_label".tr} — ${e.utilities!.description ?? ''}";
    }
    if (e.electrical != null && e.electrical!.total != null) {
      return "${"electrical_label".tr} — ${e.electrical!.itemName ?? ''}";
    }
    if (e.plumbing != null && e.plumbing!.total != null) {
      return "${"plumbing_label".tr} — ${e.plumbing!.itemName ?? ''}";
    }
    if (e.other != null && e.other!.amount != null) {
      return "${"other_label".tr} — ${e.other!.description ?? ''}";
    }

    return e.category ?? "expense".tr;
  }

  double _accountExpenseAmount(ExpenseDatum e) {
    final cat = (e.category ?? "").toLowerCase().trim();

    switch (cat) {
      case "labour":
        return double.tryParse(e.labour?.totalLabourCost ?? "0") ?? 0;
      case "salary":
        return double.tryParse(e.salary?.totalSalaries ?? "0") ?? 0;
      case "tiffins":
      case "tiffinsmeals":
      case "tiffins/meals":
        return (e.tiffinsMeals?.amount ?? 0).toDouble();
      case "petrol":
        return (e.petrol?.amount ?? 0).toDouble();
      case "diesel":
        return (e.diesel?.amount ?? 0).toDouble();
      case "transport":
        return (e.transport?.amount ?? 0).toDouble();
      case "utilities":
        return (e.utilities?.amount ?? 0).toDouble();
      case "other":
        return (e.other?.amount ?? 0).toDouble();
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
    if (e.tiffinsMeals?.amount != null) {
      return e.tiffinsMeals!.amount!.toDouble();
    }
    if (e.petrol?.amount != null) return e.petrol!.amount!.toDouble();
    if (e.diesel?.amount != null) return e.diesel!.amount!.toDouble();
    if (e.transport?.amount != null) return e.transport!.amount!.toDouble();
    if (e.utilities?.amount != null) return e.utilities!.amount!.toDouble();
    if (e.other?.amount != null) return e.other!.amount!.toDouble();
    if (e.electrical?.total != null) return e.electrical!.total!.toDouble();
    if (e.plumbing?.total != null) return e.plumbing!.total!.toDouble();

    return 0;
  }

  String _accountExpenseLabel(ExpenseDatum e) {
    final cat = (e.category ?? "").toLowerCase().trim();

    switch (cat) {
      case "labour":
        final p = e.labour?.noofpersonsWorked ?? "0";
        final c = e.labour?.chargesPerPerson ?? "0";
        return "${"labour_label".tr} — $p ${"persons".tr} × ₹$c";
      case "salary":
        final n = e.salary?.persons?.length ?? 0;
        return "${"salary_label".tr} — $n ${"person_s".tr}";
      case "tiffins":
      case "tiffinsmeals":
      case "tiffins/meals":
        return "${"tiffins_meals_label".tr} — ${e.tiffinsMeals?.description ?? ''}";
      case "petrol":
        return "${"petrol_label".tr} — ${e.petrol?.description ?? ''}";
      case "diesel":
        return "${"diesel_label".tr} — ${e.diesel?.description ?? ''}";
      case "transport":
        return "${"transport_label".tr} — ${e.transport?.description ?? ''}";
      case "utilities":
        return "${"utilities_label".tr} — ${e.utilities?.description ?? ''}";
      case "electrical":
        return "${"electrical_label".tr} — ${e.electrical?.itemName ?? ''}";
      case "plumbing":
        return "${"plumbing_label".tr} — ${e.plumbing?.itemName ?? ''}";
      case "other":
        return "${"other_label".tr} — ${e.other?.description ?? ''}";
    }

    if (e.labour != null && e.labour!.totalLabourCost != null) {
      final p = e.labour!.noofpersonsWorked ?? "0";
      final c = e.labour!.chargesPerPerson ?? "0";
      return "${"labour_label".tr} — $p ${"persons".tr} × ₹$c";
    }
    if (e.salary != null && e.salary!.totalSalaries != null) {
      final n = e.salary!.persons?.length ?? 0;
      return "${"salary_label".tr} — $n ${"person_s".tr}";
    }
    if (e.diesel != null && e.diesel!.amount != null) {
      return "${"diesel_label".tr} — ${e.diesel!.description ?? ''}";
    }
    if (e.petrol != null && e.petrol!.amount != null) {
      return "${"petrol_label".tr} — ${e.petrol!.description ?? ''}";
    }
    if (e.tiffinsMeals != null && e.tiffinsMeals!.amount != null) {
      return "${"tiffins_meals_label".tr} — ${e.tiffinsMeals!.description ?? ''}";
    }
    if (e.transport != null && e.transport!.amount != null) {
      return "${"transport_label".tr} — ${e.transport!.description ?? ''}";
    }
    if (e.utilities != null && e.utilities!.amount != null) {
      return "${"utilities_label".tr} — ${e.utilities!.description ?? ''}";
    }
    if (e.electrical != null && e.electrical!.total != null) {
      return "${"electrical_label".tr} — ${e.electrical!.itemName ?? ''}";
    }
    if (e.plumbing != null && e.plumbing!.total != null) {
      return "${"plumbing_label".tr} — ${e.plumbing!.itemName ?? ''}";
    }
    if (e.other != null && e.other!.amount != null) {
      return "${"other_label".tr} — ${e.other!.description ?? ''}";
    }

    return e.category ?? "expense".tr;
  }

  List<Widget> _buildTankSummaryRows(
    List<Harvest> harvests,
    List<Expense> expenses,
    List<ExpenseDatum> accountExpenses,
    List<Medicine> medicines,
    List<Purchase> purchases,
    List<Stock> stocks,
  ) {
    final Set<String> tankNames = {};

    for (final h in harvests) {
      if (h.tankName != null && h.tankName!.isNotEmpty) {
        tankNames.add(h.tankName!);
      }
    }
    for (final e in expenses) {
      if (e.tankName != null && e.tankName!.isNotEmpty) {
        tankNames.add(e.tankName!);
      }
    }
    for (final e in accountExpenses) {
      final tn = _tankNameForId(e.tankId);
      if (tn != null && tn.isNotEmpty) tankNames.add(tn);
    }
    for (final m in medicines) {
      if (m.tankName != null && m.tankName!.isNotEmpty) {
        tankNames.add(m.tankName!);
      }
    }
    for (final p in purchases) {
      if (p.tankName != null && p.tankName!.isNotEmpty) {
        tankNames.add(p.tankName!);
      }
    }

    if (tankNames.isEmpty && _selectedTank == _allTanksLabel) {
      final tanks = _tankController.tanksDataResponce.value.tanks ?? [];
      for (final t in tanks) {
        if (t.name != null && t.name!.isNotEmpty) {
          tankNames.add(t.name!);
        }
      }
    }

    if (_selectedTank != _allTanksLabel) {
      tankNames
        ..clear()
        ..add(_selectedTank);
    }

    if (tankNames.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: CustomText(
              textName: "no_tank_data".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
      ];
    }

    final double totalStockAll = _stockTotal(stocks);
    final double totalPartyAll = _partyPurchasesTotal();
    final int denom = tankNames.isEmpty ? 1 : tankNames.length;
    final double stockPerTank = totalStockAll / denom;
    final double partyPerTank = totalPartyAll / denom;

    return tankNames.map((tankName) {
      double income = 0;
      for (final h in harvests) {
        if (h.tankName == tankName) {
          income += double.tryParse(h.totalAmount ?? "0") ?? 0;
        }
      }

      double tankMedicine = 0;
      for (final m in medicines) {
        if (m.tankName == tankName) {
          tankMedicine += double.tryParse(m.totalAmount ?? "0") ?? 0;
        }
      }

      double tankExpense = 0;
      for (final e in expenses) {
        if (e.tankName == tankName) {
          tankExpense += _expenseAmount(e);
        }
      }

      double tankAccountExpense = 0;
      for (final e in accountExpenses) {
        if (_tankNameForId(e.tankId) == tankName) {
          tankAccountExpense += _accountExpenseAmount(e);
        }
      }

      double tankFeed = 0;
      for (final p in purchases) {
        if (p.tankName == tankName) {
          tankFeed += double.tryParse(p.totalAmount ?? "0") ?? 0;
        }
      }

      final expense = tankMedicine +
          tankExpense +
          tankAccountExpense +
          tankFeed +
          stockPerTank +
          partyPerTank;
      final net = income - expense;
      final isLoss = net < 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _tableCell(tankName, flex: 4, bold: true),
            _tableCell(_formatCurrency(income), flex: 4, color: _green),
            _tableCell(_formatCurrency(expense), flex: 4, color: _red),
            _tableCell(
              _formatCurrency(net),
              flex: 4,
              color: isLoss ? _red : _green,
              bold: true,
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final abs = value.abs();
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return isNegative ? "-${formatter.format(abs)}" : formatter.format(abs);
  }

  Widget _miniStat({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
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

  Widget _sectionLabel(String text) {
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

  Widget _itemRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
            fontWeightType: FontWeightType.semiBold,
            textColor: valueColor ?? _red,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.semiBold,
        textColor: Colors.grey.shade700,
        fontSize: 9,
      ),
    );
  }

  Widget _tableCell(
    String text, {
    required int flex,
    Color? color,
    bool bold = false,
  }) {
    return Expanded(
      flex: flex,
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: bold ? FontWeightType.semiBold : FontWeightType.regular,
        textColor: color ?? AppColors.blackColor,
        fontSize: 9,
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
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.regular,
      textColor: Colors.grey.shade700,
      fontSize: 11,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 14, color: Colors.grey.shade600)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primary, width: 1.6),
        ),
      ),
    );
  }

  _OverallData _getOverallData() {
    final harvests = _currentHarvests();
    final expenses = _currentExpenses();
    final accountExpenses = _currentAccountExpenses();
    final medicines = _currentMedicines();
    final purchases = _currentPurchases();
    final stocks = _currentStocks();

    final totalIncome = _incomeTotal(harvests);
    final medicineTotal = _medicineTotal(medicines);
    final expenseTotal = _expenseTotal(expenses);
    final accountExpenseTotal = _accountExpenseTotal(accountExpenses);
    final stockTotal = _stockTotal(stocks);
    final feedTotal = _feedTotal(purchases);
    final partyPurchasesTotal = _partyPurchasesTotal();
    final totalExpenses = medicineTotal +
        expenseTotal +
        accountExpenseTotal +
        stockTotal +
        feedTotal +
        partyPurchasesTotal;
    final netPl = totalIncome - totalExpenses;

    return _OverallData(
      totalIncome: totalIncome,
      medicineTotal: medicineTotal,
      expenseTotal: expenseTotal,
      accountExpenseTotal: accountExpenseTotal,
      stockTotal: stockTotal,
      feedTotal: feedTotal,
      partyPurchasesTotal: partyPurchasesTotal,
      totalExpenses: totalExpenses,
      netPl: netPl,
      harvests: harvests,
      expenses: expenses,
      accountExpenses: accountExpenses,
      medicines: medicines,
      purchases: purchases,
      stocks: stocks,
    );
  }

  bool _hasNoData(_OverallData overall, List<TankSummary> tankData) {
    return overall.harvests.isEmpty &&
        overall.expenses.isEmpty &&
        overall.accountExpenses.isEmpty &&
        overall.medicines.isEmpty &&
        overall.purchases.isEmpty &&
        overall.stocks.isEmpty &&
        tankData.isEmpty;
  }

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

  String? _buildCsvString() {
    final overall = _getOverallData();
    final tankData = _getTankSummaryData();

    if (_hasNoData(overall, tankData)) return null;

    final farmName = _selectedFarm?.farmName ?? 'Unknown Farm';
    final fromDate = _fromController.text;
    final toDate = _toController.text;
    final period = fromDate == toDate ? fromDate : '$fromDate ${"to".tr} $toDate';
    final generatedDate = DateFormat('M/d/yyyy').format(DateTime.now());

    final List<List<dynamic>> rows = [];

    rows.add(['csv_farm'.tr, farmName]);
    rows.add(['csv_period'.tr, period]);
    rows.add(['csv_generated'.tr, generatedDate]);
    rows.add(<dynamic>[]);

    rows.add(['csv_overall_summary'.tr, 'csv_amount'.tr]);
    rows.add(['total_income'.tr, overall.totalIncome.toStringAsFixed(0)]);
    rows.add(['medicine'.tr, overall.medicineTotal.toStringAsFixed(0)]);
    rows.add(['expense'.tr, overall.expenseTotal.toStringAsFixed(0)]);
    rows.add([
      'account_expense_approved'.tr,
      overall.accountExpenseTotal.toStringAsFixed(0),
    ]);
    rows.add(['stock'.tr, overall.stockTotal.toStringAsFixed(0)]);
    rows.add(['feed'.tr, overall.feedTotal.toStringAsFixed(0)]);
    rows.add([
      'party_purchases'.tr,
      overall.partyPurchasesTotal.toStringAsFixed(0),
    ]);
    rows.add(['total_expenses_lbl'.tr, overall.totalExpenses.toStringAsFixed(0)]);
    rows.add(['net_pl'.tr, overall.netPl.toStringAsFixed(0)]);
    rows.add(<dynamic>[]);

    rows.add([
      'tank_col'.tr,
      'income_col'.tr,
      'expenses_col'.tr,
      'net_pl_col'.tr,
    ]);
    for (final summary in tankData) {
      rows.add([
        summary.tankName,
        summary.income.toStringAsFixed(0),
        summary.expenses.toStringAsFixed(0),
        summary.net.toStringAsFixed(0),
      ]);
    }
    if (tankData.isNotEmpty) {
      final totalIncome = tankData.fold<double>(0, (a, b) => a + b.income);
      final totalExpenses = tankData.fold<double>(0, (a, b) => a + b.expenses);
      final totalNet = totalIncome - totalExpenses;
      rows.add([
        'csv_total'.tr,
        totalIncome.toStringAsFixed(0),
        totalExpenses.toStringAsFixed(0),
        totalNet.toStringAsFixed(0),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<Uint8List?> _buildPdfBytes() async {
    final overall = _getOverallData();
    final tankData = _getTankSummaryData();

    if (_hasNoData(overall, tankData)) return null;

    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: 0,
    );

    final farmName = _selectedFarm?.farmName ?? 'Unknown Farm';
    final fromDate = _fromController.text;
    final toDate = _toController.text;
    final period = fromDate == toDate ? fromDate : '$fromDate ${"to".tr} $toDate';
    final generatedDate = DateFormat('M/d/yyyy').format(DateTime.now());

    final tankTableData = <List<String>>[];
    tankTableData.add([
      'tank_col'.tr,
      'income_col'.tr,
      'expenses_col'.tr,
      'net_pl_col'.tr,
    ]);
    for (final summary in tankData) {
      tankTableData.add([
        summary.tankName,
        currencyFormat.format(summary.income),
        currencyFormat.format(summary.expenses),
        currencyFormat.format(summary.net),
      ]);
    }
    if (tankData.isNotEmpty) {
      final totalIncome = tankData.fold<double>(0, (a, b) => a + b.income);
      final totalExpenses = tankData.fold<double>(0, (a, b) => a + b.expenses);
      tankTableData.add([
        'csv_total'.tr,
        currencyFormat.format(totalIncome),
        currencyFormat.format(totalExpenses),
        currencyFormat.format(totalIncome - totalExpenses),
      ]);
    }

    final expenseBreakdownData = <List<String>>[
      ['csv_category'.tr, 'csv_amount'.tr],
      ['medicine'.tr, currencyFormat.format(overall.medicineTotal)],
      ['expense'.tr, currencyFormat.format(overall.expenseTotal)],
      [
        'account_expense_approved'.tr,
        currencyFormat.format(overall.accountExpenseTotal)
      ],
      ['stock'.tr, currencyFormat.format(overall.stockTotal)],
      ['feed'.tr, currencyFormat.format(overall.feedTotal)],
      ['party_purchases'.tr, currencyFormat.format(overall.partyPurchasesTotal)],
      ['total_expenses_lbl'.tr, currencyFormat.format(overall.totalExpenses)],
    ];

    final maxNet = tankData.isEmpty
        ? 0.0
        : tankData.map((e) => e.net.abs()).reduce((a, b) => a > b ? a : b);
    const barMaxWidth = 200.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "pdf_report_title".tr,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text("${"csv_farm".tr}: $farmName",
              style: const pw.TextStyle(fontSize: 10)),
          pw.Text("${"csv_period".tr}: $period",
              style: const pw.TextStyle(fontSize: 10)),
          pw.Text("${"csv_generated".tr}: $generatedDate",
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),

          pw.Text(
            "csv_overall_summary".tr,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: _pdfKpiCard(
                  "total_income".tr,
                  overall.totalIncome,
                  PdfColors.green700,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _pdfKpiCard(
                  "total_expenses".tr,
                  overall.totalExpenses,
                  PdfColors.red700,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _pdfKpiCard(
                  "net_pl".tr,
                  overall.netPl,
                  overall.netPl >= 0
                      ? PdfColors.green700
                      : PdfColors.red700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Text(
            "pdf_expense_breakdown".tr,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            data: expenseBreakdownData,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
            },
          ),
          pw.SizedBox(height: 20),

          if (tankTableData.length > 1) ...[
            pw.Text(
              "pdf_tank_summary".tr,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              data: tankTableData,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
            ),
            pw.SizedBox(height: 20),
          ],

          if (tankData.isNotEmpty) ...[
            pw.Text(
              "pdf_net_pl_by_tank".tr,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            ...tankData.map((summary) {
              final double barWidth = maxNet > 0
                  ? ((summary.net.abs() / maxNet) * barMaxWidth)
                      .clamp(2.0, barMaxWidth)
                  : 2.0;
              final PdfColor barColor =
                  summary.net >= 0 ? PdfColors.green : PdfColors.red;
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(
                      width: 100,
                      child: pw.Text(
                        summary.tankName,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Container(
                      width: barWidth,
                      height: 14,
                      decoration: pw.BoxDecoration(color: barColor),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      currencyFormat.format(summary.net),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              );
            }),
          ],

          if (overall.medicines.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text(
              "pdf_medicine_items".tr,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            _pdfItemTable(
              headers: [
                'medicine'.tr,
                'csv_tank'.tr,
                'csv_qty'.tr,
                'csv_amount'.tr,
              ],
              rows: overall.medicines.map((m) {
                return [
                  m.medicineName ?? 'Medicine',
                  m.tankName ?? '-',
                  m.quantityPurchased ?? '0',
                  currencyFormat.format(
                    double.tryParse(m.totalAmount ?? '0') ?? 0,
                  ),
                ];
              }).toList(),
            ),
          ],

          if (overall.purchases.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              "pdf_feed_items".tr,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            _pdfItemTable(
              headers: [
                'feed'.tr,
                'csv_tank'.tr,
                'csv_qty_kg'.tr,
                'csv_amount'.tr,
              ],
              rows: overall.purchases.map((p) {
                return [
                  p.feedName ?? 'Feed',
                  p.tankName ?? '-',
                  p.quantityPurchased ?? '0',
                  currencyFormat.format(
                    double.tryParse(p.totalAmount ?? '0') ?? 0,
                  ),
                ];
              }).toList(),
            ),
          ],

          if (overall.stocks.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              "pdf_stock_items".tr,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            _pdfItemTable(
              headers: [
                'csv_species'.tr,
                'csv_qty'.tr,
                'csv_amount'.tr,
              ],
              rows: overall.stocks.map((s) {
                return [
                  s.speciesName ?? 'Stock',
                  s.quantityStocked ?? '0',
                  currencyFormat.format(
                    double.tryParse(s.totalAmount ?? '0') ?? 0,
                  ),
                ];
              }).toList(),
            ),
          ],

          if (overall.expenses.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              "pdf_expense_items".tr,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            _pdfItemTable(
              headers: [
                'csv_category'.tr,
                'csv_tank'.tr,
                'csv_amount'.tr,
              ],
              rows: overall.expenses.map((e) {
                return [
                  _expenseLabel(e),
                  e.tankName ?? '-',
                  currencyFormat.format(_expenseAmount(e)),
                ];
              }).toList(),
            ),
          ],

          if (overall.accountExpenses.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              "pdf_account_expense_items".tr,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            _pdfItemTable(
              headers: [
                'csv_category'.tr,
                'csv_tank'.tr,
                'csv_amount'.tr,
              ],
              rows: overall.accountExpenses.map((e) {
                return [
                  _accountExpenseLabel(e),
                  _tankNameForId(e.tankId) ?? '-',
                  currencyFormat.format(_accountExpenseAmount(e)),
                ];
              }).toList(),
            ),
          ],

          if (overall.harvests.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              "pdf_income_items".tr,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            _pdfItemTable(
              headers: [
                'csv_harvest_type'.tr,
                'csv_tank'.tr,
                'csv_qty'.tr,
                'csv_amount'.tr,
              ],
              rows: overall.harvests.map((h) {
                return [
                  h.harvestType ?? 'Harvest',
                  h.tankName ?? '-',
                  h.quantityHarvested ?? '0',
                  currencyFormat.format(
                    double.tryParse(h.totalAmount ?? '0') ?? 0,
                  ),
                ];
              }).toList(),
            ),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfKpiCard(String label, double value, PdfColor color) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: 0,
    );
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            currencyFormat.format(value),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfItemTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final data = <List<String>>[headers, ...rows];
    final Map<int, pw.TableColumnWidth> widths = {};
    for (int i = 0; i < headers.length; i++) {
      widths[i] =
          i == 0 ? const pw.FlexColumnWidth(3) : const pw.FlexColumnWidth(2);
    }
    return pw.Table.fromTextArray(
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      columnWidths: widths,
    );
  }

  Future<void> _exportCsv() async {
    final csv = _buildCsvString();
    if (csv == null) {
      _showNoDataSnack();
      return;
    }
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/farm_pl.csv';
      final file = File(path);
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(path)], text: 'farm_pl_csv'.tr);
    } catch (e) {
      _showErrorSnack("csv_share".tr, e);
    }
  }

  Future<void> _exportPdf() async {
    final bytes = await _buildPdfBytes();
    if (bytes == null) {
      _showNoDataSnack();
      return;
    }
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'farm_pl_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      _showErrorSnack("pdf_share".tr, e);
    }
  }

  Future<void> _downloadCsv() async {
    final csv = _buildCsvString();
    if (csv == null) {
      _showNoDataSnack();
      return;
    }

    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = "farm_pl_$timestamp.csv";

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

  Future<void> _downloadPdf() async {
    final bytes = await _buildPdfBytes();
    if (bytes == null) {
      _showNoDataSnack();
      return;
    }

    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = "farm_pl_$timestamp.pdf";

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);
      debugPrint('══► PDF temp file: ${tempFile.path}');

      final params = SaveFileDialogParams(
        sourceFilePath: tempFile.path,
        fileName: fileName,
        mimeTypesFilter: const ['application/pdf'],
      );
      final result = await FlutterFileDialog.saveFile(params: params);
      debugPrint('══► PDF save result: $result');

      if (result != null && result.isNotEmpty) {
        _showSuccessSnack("${"pdf_saved".tr}: $fileName");
      }
    } catch (e) {
      debugPrint('══► PDF download error: $e');
      _showErrorSnack("pdf_download".tr, e);
    }
  }

  List<TankSummary> _getTankSummaryData() {
    final harvests = _currentHarvests();
    final expenses = _currentExpenses();
    final accountExpenses = _currentAccountExpenses();
    final medicines = _currentMedicines();
    final purchases = _currentPurchases();
    final stocks = _currentStocks();

    final Set<String> tankNames = {};

    for (final h in harvests) {
      if (h.tankName != null && h.tankName!.isNotEmpty) {
        tankNames.add(h.tankName!);
      }
    }
    for (final e in expenses) {
      if (e.tankName != null && e.tankName!.isNotEmpty) {
        tankNames.add(e.tankName!);
      }
    }
    for (final e in accountExpenses) {
      final tn = _tankNameForId(e.tankId);
      if (tn != null && tn.isNotEmpty) tankNames.add(tn);
    }
    for (final m in medicines) {
      if (m.tankName != null && m.tankName!.isNotEmpty) {
        tankNames.add(m.tankName!);
      }
    }
    for (final p in purchases) {
      if (p.tankName != null && p.tankName!.isNotEmpty) {
        tankNames.add(p.tankName!);
      }
    }

    if (tankNames.isEmpty && _selectedTank == _allTanksLabel) {
      final tanks = _tankController.tanksDataResponce.value.tanks ?? [];
      for (final t in tanks) {
        if (t.name != null && t.name!.isNotEmpty) {
          tankNames.add(t.name!);
        }
      }
    }

    if (_selectedTank != _allTanksLabel) {
      tankNames
        ..clear()
        ..add(_selectedTank);
    }

    if (tankNames.isEmpty) return [];

    final double totalStockAll = _stockTotal(stocks);
    final double totalPartyAll = _partyPurchasesTotal();
    final int denom = tankNames.isEmpty ? 1 : tankNames.length;
    final double stockPerTank = totalStockAll / denom;
    final double partyPerTank = totalPartyAll / denom;

    final List<TankSummary> result = [];
    for (final tankName in tankNames) {
      double income = 0;
      for (final h in harvests) {
        if (h.tankName == tankName) {
          income += double.tryParse(h.totalAmount ?? "0") ?? 0;
        }
      }

      double tankMedicine = 0;
      for (final m in medicines) {
        if (m.tankName == tankName) {
          tankMedicine += double.tryParse(m.totalAmount ?? "0") ?? 0;
        }
      }

      double tankExpense = 0;
      for (final e in expenses) {
        if (e.tankName == tankName) {
          tankExpense += _expenseAmount(e);
        }
      }

      double tankAccountExpense = 0;
      for (final e in accountExpenses) {
        if (_tankNameForId(e.tankId) == tankName) {
          tankAccountExpense += _accountExpenseAmount(e);
        }
      }

      double tankFeed = 0;
      for (final p in purchases) {
        if (p.tankName == tankName) {
          tankFeed += double.tryParse(p.totalAmount ?? "0") ?? 0;
        }
      }

      final expense = tankMedicine +
          tankExpense +
          tankAccountExpense +
          tankFeed +
          stockPerTank +
          partyPerTank;
      final net = income - expense;

      result.add(
        TankSummary(
          tankName: tankName,
          income: income,
          expenses: expense,
          net: net,
        ),
      );
    }
    return result;
  }
}

class _ChartData {
  final String label;
  final double income;
  final double expense;

  _ChartData({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class TankSummary {
  final String tankName;
  final double income;
  final double expenses;
  final double net;

  TankSummary({
    required this.tankName,
    required this.income,
    required this.expenses,
    required this.net,
  });
}

class _OverallData {
  final double totalIncome;
  final double medicineTotal;
  final double expenseTotal;
  final double accountExpenseTotal;
  final double stockTotal;
  final double feedTotal;
  final double partyPurchasesTotal;
  final double totalExpenses;
  final double netPl;

  final List<Harvest> harvests;
  final List<Expense> expenses;
  final List<ExpenseDatum> accountExpenses;
  final List<Medicine> medicines;
  final List<Purchase> purchases;
  final List<Stock> stocks;

  _OverallData({
    required this.totalIncome,
    required this.medicineTotal,
    required this.expenseTotal,
    required this.accountExpenseTotal,
    required this.stockTotal,
    required this.feedTotal,
    required this.partyPurchasesTotal,
    required this.totalExpenses,
    required this.netPl,
    required this.harvests,
    required this.expenses,
    required this.accountExpenses,
    required this.medicines,
    required this.purchases,
    required this.stocks,
  });
}

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;

  const _ShimmerBox({required this.height, this.width, this.radius = 6});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
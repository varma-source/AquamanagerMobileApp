import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/staff_module/staff_expense_model.dart'
    as exp_model;
import 'package:superapp/model/staff_module/staff_get_medicine_model.dart'
    as med_model;
import 'package:superapp/model/staff_module/staff_my_feed_model.dart'
    as feed_model;
import 'package:superapp/model/staff_module/staff_request_advance_model.dart'
    as advance_model;
import 'package:superapp/services/manager_module_service.dart';
import 'package:superapp/services/staff_module_service.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_expence_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_get_medicine_conntroller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_my_feed_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_request_advance_controller.dart';

class ManagerMyEntiresScreen extends StatefulWidget {
  const ManagerMyEntiresScreen({super.key});

  @override
  State<ManagerMyEntiresScreen> createState() => _ManagerMyEntiresScreenState();
}

class _ManagerMyEntiresScreenState extends State<ManagerMyEntiresScreen> {
  final Color _bgColor = const Color(0xFFF3F4F6);
  final Color _primaryDark = const Color(0xFF1E3A5F);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _textDark = const Color(0xFF1F2937);
  final Color _textGrey = const Color(0xFF6B7280);

  // Controllers
  late final StaffExpenceController _expenseController;
  late final StaffGetMedicineConntroller _medicineController;
  late final StaffMyFeedController _feedController;
  late final StaffRequestAdvanceController _advanceController;

  // Filter Tabs
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["All", "Feed", "Medicine", "Expenses"];
  int _selectedDateFilterIndex = 0; // Default to "Today"
  final List<String> _dateFilters = ["Today", "This Week", "This Month"];

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<StaffExpenceController>()) {
      _expenseController = Get.find<StaffExpenceController>();
    } else {
      _expenseController = Get.put(
        StaffExpenceController(StaffModuleService()),
      );
    }

    if (Get.isRegistered<StaffGetMedicineConntroller>()) {
      _medicineController = Get.find<StaffGetMedicineConntroller>();
    } else {
      _medicineController = Get.put(
        StaffGetMedicineConntroller(StaffModuleService()),
      );
    }

    if (Get.isRegistered<StaffMyFeedController>()) {
      _feedController = Get.find<StaffMyFeedController>();
    } else {
      _feedController = Get.put(StaffMyFeedController(StaffModuleService()));
    }

    if (Get.isRegistered<StaffRequestAdvanceController>()) {
      _advanceController = Get.find<StaffRequestAdvanceController>();
    } else {
      _advanceController = Get.put(
        StaffRequestAdvanceController(StaffModuleService()),
      );
    }

    _expenseController.fetchstaffexpensedata();
    _medicineController.fetchgetmedicinedata();
    _feedController.fetchstaffmyfeedata();
    _advanceController.fetchrequestadvancedata();
  }

  void _refreshAll() {
    _expenseController.fetchstaffexpensedata();
    _medicineController.fetchgetmedicinedata();
    _feedController.fetchstaffmyfeedata();
    _advanceController.fetchrequestadvancedata();
  }

  // 🌐 Translate filter labels
  String _translatedFilter(int index) {
    switch (index) {
      case 0:
        return "all".tr;
      case 1:
        return "feed".tr;
      case 2:
        return "medicine".tr;
      case 3:
        return "expenses".tr;
      default:
        return _filters[index];
    }
  }

  String _translatedDateFilter(int index) {
    switch (index) {
      case 0:
        return "today".tr;
      case 1:
        return "this_week".tr;
      case 2:
        return "this_month".tr;
      default:
        return _dateFilters[index];
    }
  }

  String _translatedStatus(String statusKey) {
    switch (statusKey) {
      case "approved":
        return "approved".tr;
      case "rejected":
        return "rejected".tr;
      default:
        return "pending".tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshAll();
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: CustomText(
            textName: "my_entries".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: _primaryDark,
            fontSize: 16,
          ),
        ),
        body: Obx(() {
          final expResponse = _expenseController.staffexpenceDataResponce.value;
          final medResponse =
              _medicineController.staffgetmedicineDataResponce.value;
          final feedResponse = _feedController.staffmyfeedDataResponce.value;

          if (expResponse.expenses == null &&
              medResponse.data == null &&
              feedResponse.data == null) {
            return _buildShimmerList();
          }

          List<Map<String, dynamic>> mappedEntries = [];

          if (expResponse.expenses != null) {
            mappedEntries.addAll(
              expResponse.expenses!
                  .where((e) => e.category?.toLowerCase() != "feed")
                  .map((e) => _mapExpenseToEntry(e)),
            );
          }

          if (medResponse.data != null) {
            mappedEntries.addAll(
              medResponse.data!.map((m) => _mapMedicineToEntry(m)),
            );
          }

          if (feedResponse.data != null) {
            mappedEntries.addAll(
              feedResponse.data!.map((f) => _mapFeedToEntry(f)),
            );
          }

          final filteredList =
              mappedEntries.where((e) {
                final type = e['type'];
                final rawDate = e['rawDate'] as DateTime;

                if (!_isDateInSelectedRange(rawDate)) return false;

                if (_selectedFilterIndex == 0) return true;
                if (_selectedFilterIndex == 1) return type == 'feed';
                if (_selectedFilterIndex == 2) return type == 'medicine';
                if (_selectedFilterIndex == 3) return type == 'expense';
                return false;
              }).toList();

          filteredList.sort((a, b) => b['rawDate'].compareTo(a['rawDate']));

          final Map<String, List<Map<String, dynamic>>> groupedEntries = {};
          for (var entry in filteredList) {
            final dateStr = entry['dateHeader'];
            if (!groupedEntries.containsKey(dateStr)) {
              groupedEntries[dateStr] = [];
            }
            groupedEntries[dateStr]!.add(entry);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- 1. FILTER TABS ----------
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilterIndex == index;
                      return GestureDetector(
                        onTap:
                            () => setState(() => _selectedFilterIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _primaryDark : _borderColor,
                              width: 1,
                            ),
                          ),
                          child: CustomText(
                            textName: _translatedFilter(index),
                            fontFamily: FontFamily.poppins,
                            fontWeightType:
                                isSelected
                                    ? FontWeightType.semiBold
                                    : FontWeightType.regular,
                            textColor: isSelected ? Colors.white : _textGrey,
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- 2. ADVANCE CARD (DYNAMIC) ----------
                Obx(() {
                  final advanceResponse =
                      _advanceController.staffrequestadvanceDataResponce.value;
                  final advances = advanceResponse.data ?? [];

                  double approvedAdvance = 0;
                  double pendingAdvance = 0;

                  for (var item in advances) {
                    final amt = double.tryParse(item.amount ?? "0") ?? 0;
                    final status = (item.status ?? "pending").toLowerCase();

                    if (status == "approved") {
                      approvedAdvance += amt;
                    } else if (status == "pending") {
                      pendingAdvance += amt;
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                textName: "advance_balance".tr,
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.regular,
                                textColor: _textGrey,
                                fontSize: 10,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  CustomText(
                                    textName:
                                        "₹${approvedAdvance.toStringAsFixed(0)}",
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.bold,
                                    textColor: _primaryDark,
                                    fontSize: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap:
                                        () => _showAdvanceListBottomSheet(
                                          advances,
                                        ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    textName: "requested_waiting".tr,
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.regular,
                                    textColor: _textGrey,
                                    fontSize: 8,
                                  ),
                                  const SizedBox(width: 6),
                                  CustomText(
                                    textName:
                                        "₹${pendingAdvance.toStringAsFixed(0)}",
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.bold,
                                    textColor: _primaryDark,
                                    fontSize: 15,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.4),
                              builder:
                                  (context) => const RequestAdvanceDialog(),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryDark,
                            side: BorderSide(color: _primaryDark, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: CustomText(
                            textName: "request_advance".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.medium,
                            textColor: _primaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // ---------- DATE FILTER TABS ----------
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: List.generate(_dateFilters.length, (index) {
                      final isSelected = _selectedDateFilterIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap:
                              () => setState(
                                () => _selectedDateFilterIndex = index,
                              ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow:
                                  isSelected
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
                              textName: _translatedDateFilter(index),
                              fontFamily: FontFamily.poppins,
                              fontWeightType:
                                  isSelected
                                      ? FontWeightType.semiBold
                                      : FontWeightType.medium,
                              textColor: isSelected ? _primaryDark : _textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- 4. DYNAMIC LIST OR EMPTY STATE ----------
                if (filteredList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: CustomText(
                        textName:
                            "${"no_entries".tr} ${_translatedFilter(_selectedFilterIndex)} ${"for".tr} ${_translatedDateFilter(_selectedDateFilterIndex).toLowerCase()}",
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: _textGrey,
                        fontSize: 14,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...groupedEntries.entries.map((group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(group.key),
                        ...group.value.map((entry) => _buildEntryItem(entry)),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),

                const SizedBox(height: 30),
              ],
            ),
          );
        }),
      ),
    );
  }

  bool _isDateInSelectedRange(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    switch (_selectedDateFilterIndex) {
      case 0:
        return d == today;
      case 1:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return !d.isBefore(startOfWeek) && !d.isAfter(endOfWeek);
      case 2:
        return d.year == now.year && d.month == now.month;
      default:
        return true;
    }
  }

  void _showAdvanceListBottomSheet(List<advance_model.Datum> advances) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomText(
                textName: "advance_requests".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: _primaryDark,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
              if (advances.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CustomText(
                      textName: "no_advance_requests".tr,
                      fontFamily: FontFamily.poppins,
                      textColor: _textGrey,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: advances.length,
                    separatorBuilder: (_, __) => Divider(color: _borderColor),
                    itemBuilder: (context, index) {
                      final item = advances[index];

                      final statusKey =
                          (item.status ?? "pending").toLowerCase();
                      final statusStr = _translatedStatus(statusKey);

                      final dateStr =
                          item.date != null
                              ? "${item.date!.day}-${item.date!.month}-${item.date!.year}"
                              : "N/A";

                      Color statusColor;
                      Color statusBgColor;
                      if (statusKey == "approved") {
                        statusColor = const Color(0xFF10B981);
                        statusBgColor = const Color(0xFFD1FAE5);
                      } else if (statusKey == "rejected") {
                        statusColor = const Color(0xFFEF4444);
                        statusBgColor = const Color(0xFFFEE2E2);
                      } else {
                        statusColor = const Color(0xFFF59E0B);
                        statusBgColor = const Color(0xFFFEF3C7);
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              textName: "₹${item.amount ?? '0'}",
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.bold,
                              textColor: _textDark,
                              fontSize: 14,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: CustomText(
                                textName: statusStr,
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.medium,
                                textColor: statusColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: CustomText(
                            textName:
                                "${item.purpose ?? 'no_purpose'.tr} · $dateStr",
                            fontFamily: FontFamily.poppins,
                            textColor: _textGrey,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Map<String, dynamic> _mapExpenseToEntry(exp_model.Expense exp) {
    String title = "Entry";
    String amount = "₹0";
    String status = (exp.status ?? "PENDING").toLowerCase();

    Color accentColor = const Color(0xFFF59E0B);
    IconData iconData = Icons.receipt_long;

    if (exp.labour != null && exp.labour!.totalLabourCost != null) {
      title =
          "${exp.labour!.noofpersonsWorked} persons × ₹${exp.labour!.chargesPerPerson}";
      amount = "₹${exp.labour!.totalLabourCost}";
      iconData = Icons.people_outline;
    } else if (exp.salary != null && exp.salary!.totalSalaries != null) {
      title = "Salary payment (${exp.salary!.persons?.length ?? 0} persons)";
      amount = "₹${exp.salary!.totalSalaries}";
      iconData = Icons.account_balance_wallet_outlined;
    } else if (exp.tiffinsMeals != null && exp.tiffinsMeals!.amount != null) {
      title = exp.tiffinsMeals!.description ?? "Tiffins/Meals";
      amount = "₹${exp.tiffinsMeals!.amount}";
      iconData = Icons.restaurant_outlined;
    } else if (exp.petrol != null && exp.petrol!.amount != null) {
      title = exp.petrol!.description ?? "Petrol";
      amount = "₹${exp.petrol!.amount}";
      iconData = Icons.local_gas_station_outlined;
    } else if (exp.diesel != null && exp.diesel!.amount != null) {
      title = exp.diesel!.description ?? "Diesel";
      amount = "₹${exp.diesel!.amount}";
      iconData = Icons.local_gas_station_outlined;
    } else if (exp.electrical != null && exp.electrical!.total != null) {
      title =
          "${exp.electrical!.itemName} (${exp.electrical!.quantity} ${exp.electrical!.unit})";
      amount = "₹${exp.electrical!.total}";
      iconData = Icons.electrical_services_outlined;
    } else if (exp.plumbing != null && exp.plumbing!.total != null) {
      title = "${exp.plumbing!.itemName} (${exp.plumbing!.quantity} pcs)";
      amount = "₹${exp.plumbing!.total}";
      iconData = Icons.plumbing_outlined;
    } else if (exp.transport != null && exp.transport!.amount != null) {
      title = exp.transport!.description ?? "Transport";
      amount = "₹${exp.transport!.amount}";
      iconData = Icons.directions_bus_outlined;
    } else if (exp.utilities != null && exp.utilities!.amount != null) {
      title = exp.utilities!.description ?? "Utilities";
      amount = "₹${exp.utilities!.amount}";
      iconData = Icons.water_drop_outlined;
    } else if (exp.other != null && exp.other!.amount != null) {
      title = exp.other!.description ?? "Other";
      amount = "₹${exp.other!.amount}";
      iconData = Icons.more_horiz;
    }

    DateTime dt = exp.date ?? exp.createdAt ?? DateTime.now();
    String dateHeader = _formatDateHeader(dt);

    final tankName = exp.tankName ?? "Unknown Tank";

    return {
      "title": title,
      "subtitle": tankName,
      "amount": amount,
      "status": status,
      "accentColor": accentColor,
      "iconData": iconData,
      "dateHeader": dateHeader,
      "rawDate": dt,
      "type": "expense",
    };
  }

  Map<String, dynamic> _mapMedicineToEntry(med_model.Datum med) {
    String status = (med.status ?? "PENDING").toLowerCase();

    Color accentColor = const Color(0xFF8B5CF6);
    IconData iconData = Icons.medication_outlined;

    String title = "${med.medicineName ?? 'Medicine'} Usage";
    String amount = "- ${med.quanTityUsed ?? '0'} units";

    DateTime dt = med.date ?? med.createdAt ?? DateTime.now();
    String dateHeader = _formatDateHeader(dt);

    final tankName = med.tankName ?? "Unknown Tank";

    return {
      "title": title,
      "subtitle": tankName,
      "amount": amount,
      "status": status,
      "accentColor": accentColor,
      "iconData": iconData,
      "dateHeader": dateHeader,
      "rawDate": dt,
      "type": "medicine",
    };
  }

  Map<String, dynamic> _mapFeedToEntry(feed_model.Datum feed) {
    String status = (feed.status ?? "PENDING").toLowerCase();

    Color accentColor = const Color(0xFF10B981);
    IconData iconData = Icons.eco_outlined;

    String title = "${feed.feedName ?? 'Feed'} Usage";
    String amount = "- ${feed.kg ?? '0'} kg";

    DateTime dt = feed.date ?? DateTime.now();
    String dateHeader = _formatDateHeader(dt);

    final tankName = feed.tankName ?? "Unknown Tank";

    return {
      "title": title,
      "subtitle": tankName,
      "amount": amount,
      "status": status,
      "accentColor": accentColor,
      "iconData": iconData,
      "dateHeader": dateHeader,
      "rawDate": dt,
      "type": "feed",
    };
  }

  String _formatDateHeader(DateTime date) {
    final months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    final weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

    String month = months[date.month - 1];
    String weekday = weekdays[date.weekday - 1];

    return "$weekday, ${date.day} $month";
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: CustomText(
        textName: date,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.medium,
        textColor: _textGrey,
        fontSize: 11,
      ),
    );
  }

  Widget _buildEntryItem(Map<String, dynamic> entry) {
    final String statusKey = (entry['status'] ?? "pending").toLowerCase();
    final String statusStr = _translatedStatus(statusKey);

    Color statusColor;
    Color statusBgColor;

    if (statusKey == "approved") {
      statusColor = const Color(0xFF10B981);
      statusBgColor = const Color(0xFFD1FAE5);
    } else if (statusKey == "rejected") {
      statusColor = const Color(0xFFEF4444);
      statusBgColor = const Color(0xFFFEE2E2);
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusBgColor = const Color(0xFFFEF3C7);
    }

    final Color accentColor = entry['accentColor'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(entry['iconData'], color: accentColor, size: 18),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      textName: entry['title'],
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.medium,
                      textColor: _textDark,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      textName: entry['subtitle'],
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: _textGrey,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    textName: entry['amount'],
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: _textDark,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomText(
                      textName: statusStr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.medium,
                      textColor: statusColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 70,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              3,
              (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // ═══════════════════════════════════════════════════════════
// // ✅ POPUP DIALOG: REQUEST ADVANCE (WITH DATE SELECTOR)
// // ═══════════════════════════════════════════════════════════
// class RequestAdvanceDialog extends StatefulWidget {
//   const RequestAdvanceDialog({super.key});

//   @override
//   State<RequestAdvanceDialog> createState() => _RequestAdvanceDialogState();
// }

// class _RequestAdvanceDialogState extends State<RequestAdvanceDialog> {
//   final Color _primaryDark = const Color(0xFF1E3A5F);
//   final Color _borderColor = const Color(0xFFE5E7EB);
//   final Color _textDark = const Color(0xFF1F2937);

//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _purposeController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();

//   bool _isSubmitting = false;

//   late final ManagerModuleService _managermoduleService;
//   final _advanceController = Get.find<StaffRequestAdvanceController>();

//   @override
//   void initState() {
//     super.initState();

//     if (Get.isRegistered<ManagerModuleService>()) {
//       _managermoduleService = Get.find<ManagerModuleService>();
//     } else {
//       _managermoduleService = Get.put(ManagerModuleService());
//     }

//     final now = DateTime.now();
//     _dateController.text =
//         "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _purposeController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: _primaryDark,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _dateController.text =
//             "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//       });
//     }
//   }

//   Future<void> _submitRequest() async {
//     if (_amountController.text.isEmpty) {
//       Get.snackbar(
//         "required".tr,
//         "please_enter_amount".tr,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       await _managermoduleService.usermanagerrequestadvance(
//         date: _dateController.text,
//         amount: _amountController.text,
//         purpose: _purposeController.text,
//       );

//       _advanceController.fetchrequestadvancedata();
//     } catch (e) {
//       Get.snackbar(
//         "error".tr,
//         "${"failed_to_send".tr}: $e",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       backgroundColor: Colors.white,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomText(
//               textName: "request_advance".tr,
//               fontFamily: FontFamily.poppins,
//               fontWeightType: FontWeightType.bold,
//               textColor: _primaryDark,
//               fontSize: 18,
//             ),
//             const SizedBox(height: 20),

//             CustomText(
//               textName: "date".tr,
//               fontFamily: FontFamily.poppins,
//               fontWeightType: FontWeightType.medium,
//               textColor: _textDark,
//               fontSize: 13,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _dateController,
//               readOnly: true,
//               onTap: _pickDate,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//                 suffixIcon: const Icon(
//                   Icons.calendar_today_outlined,
//                   size: 18,
//                   color: Colors.grey,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _borderColor),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _borderColor),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _primaryDark, width: 1.5),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             CustomText(
//               textName: "amount".tr,
//               fontFamily: FontFamily.poppins,
//               fontWeightType: FontWeightType.medium,
//               textColor: _textDark,
//               fontSize: 13,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _borderColor),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _borderColor),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _primaryDark, width: 1.5),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             CustomText(
//               textName: "purpose_optional".tr,
//               fontFamily: FontFamily.poppins,
//               fontWeightType: FontWeightType.medium,
//               textColor: _textDark,
//               fontSize: 13,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _purposeController,
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _borderColor),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _borderColor),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide(color: _primaryDark, width: 1.5),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             Row(
//               children: [
//                 Expanded(
//                   child: SizedBox(
//                     height: 44,
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: _textDark,
//                         side: BorderSide(color: _borderColor),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: CustomText(
//                         textName: "cancel".tr,
//                         fontFamily: FontFamily.poppins,
//                         fontWeightType: FontWeightType.semiBold,
//                         textColor: _textDark,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: SizedBox(
//                     height: 44,
//                     child: ElevatedButton(
//                       onPressed: _isSubmitting ? null : _submitRequest,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _primaryDark,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         disabledBackgroundColor: _primaryDark.withOpacity(0.5),
//                       ),
//                       child:
//                           _isSubmitting
//                               ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                               : CustomText(
//                                 textName: "send_request".tr,
//                                 fontFamily: FontFamily.poppins,
//                                 fontWeightType: FontWeightType.semiBold,
//                                 textColor: Colors.white,
//                                 fontSize: 14,
//                               ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class RequestAdvanceDialog extends StatefulWidget {
  const RequestAdvanceDialog({super.key});

  @override
  State<RequestAdvanceDialog> createState() => _RequestAdvanceDialogState();
}

class _RequestAdvanceDialogState extends State<RequestAdvanceDialog> {
  final Color _primaryDark = const Color(0xFF1E3A5F);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _textDark = const Color(0xFF1F2937);

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isSubmitting = false;

  late final ManagerModuleService _managermoduleService;
  final _advanceController = Get.find<StaffRequestAdvanceController>();

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<ManagerModuleService>()) {
      _managermoduleService = Get.find<ManagerModuleService>();
    } else {
      _managermoduleService = Get.put(ManagerModuleService());
    }

    final now = DateTime.now();
    _dateController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
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
    }
  }

  Future<void> _submitRequest() async {
    if (_amountController.text.isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_amount".tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _managermoduleService.usermanagerrequestadvance(
        date: _dateController.text,
        amount: _amountController.text,
        purpose: _purposeController.text,
      );

      // Refresh the data behind the popup
      _advanceController.fetchrequestadvancedata();

      // ✅ Close the popup and stay on the current screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"failed_to_send".tr}: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              textName: "request_advance".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.bold,
              textColor: _primaryDark,
              fontSize: 18,
            ),
            const SizedBox(height: 20),

            CustomText(
              textName: "date".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.medium,
              textColor: _textDark,
              fontSize: 13,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _primaryDark, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            CustomText(
              textName: "amount".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.medium,
              textColor: _textDark,
              fontSize: 13,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _primaryDark, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            CustomText(
              textName: "purpose_optional".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.medium,
              textColor: _textDark,
              fontSize: 13,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _purposeController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _primaryDark, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: BorderSide(color: _borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: CustomText(
                        textName: "cancel".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.semiBold,
                        textColor: _textDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: _primaryDark.withOpacity(0.5),
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
                                textName: "send_request".tr,
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.semiBold,
                                textColor: Colors.white,
                                fontSize: 14,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

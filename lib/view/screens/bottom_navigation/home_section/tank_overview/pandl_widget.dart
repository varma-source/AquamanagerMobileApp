import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/home_pandl_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/view_model/api_controllers/over_view/home_pandl_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/log_feeding_controller.dart';
// ✅ ADDED: Medicine Usage Controller & Model
import 'package:superapp/view_model/api_controllers/over_view/medicine_useage_controller.dart';
import 'package:superapp/model/over_view/medicine_useage_model.dart';

class PandLWidget extends StatefulWidget {
  final String farmId;
  final String tankId;
  const PandLWidget({super.key, required this.tankId, required this.farmId});

  @override
  State<PandLWidget> createState() => _PandLWidgetState();
}

class _PandLWidgetState extends State<PandLWidget> {
  final Color _primary = const Color(0xFF087FC1);
  final Color _green = const Color(0xFF1B9C4A);
  final Color _red = const Color(0xFFE53935);

  late final HomePandlController _controller;
  late final LogFeedingController _logFeedingController;

  // ✅ ADDED: Medicine Usage Controller
  late final MedicineUseageController _medicineUsageController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<HomePandlController>()) {
      _controller = Get.find<HomePandlController>();
    } else {
      _controller = Get.put(HomePandlController(OverviewService()));
    }
    _controller.fetchgetpandldata(tankId: widget.tankId, farmId: widget.farmId);

    if (Get.isRegistered<LogFeedingController>()) {
      _logFeedingController = Get.find<LogFeedingController>();
    } else {
      _logFeedingController = Get.put(LogFeedingController(OverviewService()));
    }
    _logFeedingController.fetchlogfeedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
      speciesId: "",
    );

    // ✅ Initialize and fetch Medicine Usage
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
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final resp = _controller.homepandlDataResponce.value;
      final logFeedingResp = _logFeedingController.logfeedDataResponce.value;
      final medUsageResp =
          _medicineUsageController.medicineuseDataResponce.value;

      if (resp.success == null) {
        return _buildShimmer();
      }

      // ═══════════════════════════════════════════════════
      // 1. INCOME (From Harvests)
      // ═══════════════════════════════════════════════════
      double income = 0;
      for (final h in resp.harvests ?? []) {
        income += double.tryParse(h.totalAmount ?? "0") ?? 0;
      }

      // ═══════════════════════════════════════════════════
      // 2. CALCULATE AVG COST PER KG FOR FEED
      // ═══════════════════════════════════════════════════
      double totalPurchasedKg = 0;
      double totalPurchasedAmount = 0;
      for (final p in resp.purchases ?? []) {
        totalPurchasedKg += double.tryParse(p.quantityPurchased ?? "0") ?? 0;
        totalPurchasedAmount += double.tryParse(p.totalAmount ?? "0") ?? 0;
      }
      final double avgFeedCostPerKg =
          totalPurchasedKg > 0
              ? (totalPurchasedAmount / totalPurchasedKg)
              : 0.0;

      // ═══════════════════════════════════════════════════
      // 3. CALCULATE AVG COST PER UNIT FOR MEDICINE
      // ═══════════════════════════════════════════════════
      double totalMedPurchasedQty = 0;
      double totalMedPurchasedAmount = 0;
      for (final m in resp.medicines ?? []) {
        totalMedPurchasedQty +=
            double.tryParse(m.quantityPurchased ?? "0") ?? 0;
        totalMedPurchasedAmount += double.tryParse(m.totalAmount ?? "0") ?? 0;
      }
      final double avgMedCostPerUnit =
          totalMedPurchasedQty > 0
              ? (totalMedPurchasedAmount / totalMedPurchasedQty)
              : 0.0;

      // ═══════════════════════════════════════════════════
      // 4. EXPENSE PIECES
      // ═══════════════════════════════════════════════════

      // ✅ Feed Consumed Amount
      double feedConsumedKg = 0;
      for (final log in logFeedingResp.data ?? []) {
        feedConsumedKg += double.tryParse(log.kg ?? "0") ?? 0;
      }
      double feedConsumedAmount = feedConsumedKg * avgFeedCostPerKg;

      // ✅ Medicine Used Amount (Based on Usage logs)
      double medicineUsedQty = 0;
      for (final log in medUsageResp.data ?? []) {
        medicineUsedQty += double.tryParse(log.quanTityUsed ?? "0") ?? 0;
      }
      double medicineUsedAmount = medicineUsedQty * avgMedCostPerUnit;

      double stocking = 0;
      for (final o in resp.overview ?? []) {
        for (final s in o.stocks ?? []) {
          stocking += double.tryParse(s.totalAmount ?? "0") ?? 0;
        }
      }

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

      // ✅ THIS IS THE EXACT TOTAL EXPENSES
      final double totalExpenses =
          feedConsumedAmount +
          medicineUsedAmount +
          stocking +
          labourSalaries +
          otherExpenses;

      // ✅ THIS IS THE EXACT NET P&L
      final double netPnl = income - totalExpenses;

      // ---- Income breakdown ----
      double partialHarvest = 0;
      double finalHarvest = 0;
      for (final h in resp.harvests ?? []) {
        final amt = double.tryParse(h.totalAmount ?? "0") ?? 0;
        if ((h.harvestType ?? "").toLowerCase() == "final") {
          finalHarvest += amt;
        } else {
          partialHarvest += amt;
        }
      }

      // ═══════════════════════════════════════════════════
      // 5. ROWS FOR DATE-WISE TABLE
      // ═══════════════════════════════════════════════════
      final List<Map<String, dynamic>> rows = [];

      // A. Harvests (Credit)
      for (final h in resp.harvests ?? []) {
        rows.add({
          "date": h.date,
          "particulars":
              "${_harvestTypeLabel(h.harvestType)} ${"harvest_suffix".tr} · ${h.quantityHarvested ?? 0} kg",
          "debit": 0.0,
          "credit": double.tryParse(h.totalAmount ?? "0") ?? 0,
        });
      }

      // B. Feed Consumed (Debit) - Using LogFeeding Data
      for (final log in logFeedingResp.data ?? []) {
        final kg = double.tryParse(log.kg ?? "0") ?? 0;
        rows.add({
          "date": log.date ?? log.logCreatedDate,
          "particulars":
              "${"feed_prefix".tr}: ${log.feedName ?? "feeding".tr} (${log.kg ?? 0} kg)",
          "debit": kg * avgFeedCostPerKg,
          "credit": 0.0,
        });
      }

      // C. Medicine Used (Debit) - Using Medicine Usage Data
      for (final log in medUsageResp.data ?? []) {
        final qty = double.tryParse(log.quanTityUsed ?? "0") ?? 0;
        rows.add({
          "date":
              log.date != null ? DateTime.tryParse(log.date!) : log.createdAt,
          "particulars":
              "${"medicine_prefix".tr}: ${log.medicineName ?? "usage".tr} (${log.quanTityUsed ?? 0} units)",
          "debit": qty * avgMedCostPerUnit,
          "credit": 0.0,
        });
      }

      // D. Stocking (Debit)
      for (final o in resp.overview ?? []) {
        for (final s in o.stocks ?? []) {
          rows.add({
            "date": s.date,
            "particulars":
                "${"stocking_prefix".tr}: ${s.speciesName ?? "stock".tr} (${s.quantityStocked ?? 0} nos)",
            "debit": double.tryParse(s.totalAmount ?? "0") ?? 0,
            "credit": 0.0,
          });
        }
      }

      // E. Other Expenses (Debit)
      for (final e in resp.expenses ?? []) {
        rows.add({
          "date": e.date ?? e.createdAt,
          "particulars": _expenseTitle(e),
          "debit": _expenseAmount(e),
          "credit": 0.0,
        });
      }

      // Sort by date
      rows.sort((a, b) {
        final da = (a["date"] as DateTime?) ?? DateTime(1970);
        final db = (b["date"] as DateTime?) ?? DateTime(1970);
        return da.compareTo(db);
      });

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(income, totalExpenses, netPnl),
            const SizedBox(height: 14),
            _buildOverallDataCard(resp),
            const SizedBox(height: 14),
            _buildDonutCard(
              feedConsumed: feedConsumedAmount,
              medicineUsed: medicineUsedAmount, // ✅ Passing correct Med amount
              stocking: stocking,
              labourSalaries: labourSalaries,
              other: otherExpenses,
            ),
            const SizedBox(height: 12),
            _buildStockCard(
              feedStock: feedConsumedAmount,
              medicineStock: medicineUsedAmount,
            ),
            const SizedBox(height: 12),
            _buildIncomeBreakdown(partialHarvest, finalHarvest),
            const SizedBox(height: 12),
            _buildDateWiseTable(rows),
            const SizedBox(height: 14),
          ],
        ),
      );
    });
  }

  // 🌐 Harvest type label — display only
  String _harvestTypeLabel(String? type) {
    final t = (type ?? "").toLowerCase().trim();
    if (t == "final") return "final_label".tr;
    if (t.isEmpty) return "harvest_suffix".tr;
    return type ?? "harvest_suffix".tr;
  }

  // ============================================================
  // ✅ EXPENSE AMOUNT — driven by category
  // ============================================================
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

  // ============================================================
  // ✅ EXPENSE TITLE — driven by category
  // ============================================================
  String _expenseTitle(Expense e) {
    final cat = (e.category ?? "").toLowerCase().trim();

    switch (cat) {
      case "labour":
        final n = e.labour?.noofpersonsWorked ?? "—";
        final c = e.labour?.chargesPerPerson ?? "—";
        return "${"labour_label".tr}: $n × ₹$c";
      case "salary":
        final count = e.salary?.persons?.length ?? 0;
        final notes = (e.salary?.notes ?? "").trim();
        return "${"salary_label".tr}: $count ${count == 1 ? "person_singular".tr : "person_plural".tr}${notes.isNotEmpty ? ' · $notes' : ''}";
      case "tiffins":
      case "tiffinsmeals":
      case "tiffins/meals":
        return (e.tiffinsMeals?.description ?? "").trim().isNotEmpty
            ? e.tiffinsMeals!.description!
            : "tiffins_meals_label".tr;
      case "petrol":
        return (e.petrol?.description ?? "").trim().isNotEmpty
            ? e.petrol!.description!
            : "petrol_label".tr;
      case "diesel":
        return (e.diesel?.description ?? "").trim().isNotEmpty
            ? e.diesel!.description!
            : "diesel_label".tr;
      case "transport":
        return (e.transport?.description ?? "").trim().isNotEmpty
            ? e.transport!.description!
            : "transport_label".tr;
      case "utilities":
        return (e.utilities?.description ?? "").trim().isNotEmpty
            ? e.utilities!.description!
            : "utilities_label".tr;
      case "other":
        return (e.other?.description ?? "").trim().isNotEmpty
            ? e.other!.description!
            : "other_label".tr;
      case "electrical":
        return "${e.electrical?.itemName ?? '—'}: ${e.electrical?.quantity ?? 0} ${e.electrical?.unit ?? ''}"
            .trim();
      case "plumbing":
        return "${e.plumbing?.itemName ?? '—'}: ${e.plumbing?.quantity ?? 0}";
    }

    return e.category ?? "expense".tr;
  }

  // ============================================================
  // ---------- Summary Card ----------
  // ============================================================
  Widget _buildSummaryCard(double income, double expenses, double netPnl) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 14, color: _green),
                        const SizedBox(width: 6),
                        CustomText(
                          textName: "income".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      textName: "₹${income.toStringAsFixed(0)}",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor: _green,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.trending_down, size: 14, color: _red),
                        const SizedBox(width: 6),
                        CustomText(
                          textName: "expenses".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      textName: "₹${expenses.toStringAsFixed(0)}",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor: _red,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 14),
          CustomText(
            textName: "net_pl".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade600,
            fontSize: 11,
          ),
          const SizedBox(height: 4),
          CustomText(
            textName: "₹${netPnl.toStringAsFixed(0)}",
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: netPnl >= 0 ? _green : _red,
            fontSize: 22,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ---------- ✅ Overall Data Used Card ----------
  // ============================================================
  Widget _buildOverallDataCard(HomePandLdata resp) {
    final int totalHarvests = resp.harvests?.length ?? 0;
    final int totalPurchases = resp.purchases?.length ?? 0;
    final int totalMedicines = resp.medicines?.length ?? 0;
    final int totalStockings =
        resp.overview?.fold<int>(
          0,
          (sum, o) => sum + (o.stocks?.length ?? 0),
        ) ??
        0;
    final int totalExpenses = resp.expenses?.length ?? 0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "overall_data_records".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: AppColors.blackColor,
            fontSize: 13,
          ),
          const SizedBox(height: 12),
          _stockRow("harvest_logs".tr, "$totalHarvests ${"records_suffix".tr}"),
          const SizedBox(height: 8),
          _stockRow(
            "feed_purchases".tr,
            "$totalPurchases ${"records_suffix".tr}",
          ),
          const SizedBox(height: 8),
          _stockRow(
            "medicine_purchases".tr,
            "$totalMedicines ${"records_suffix".tr}",
          ),
          const SizedBox(height: 8),
          _stockRow(
            "stocking_events".tr,
            "$totalStockings ${"records_suffix".tr}",
          ),
          const SizedBox(height: 8),
          _stockRow(
            "other_expenses".tr,
            "$totalExpenses ${"records_suffix".tr}",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ---------- Donut Card ----------
  // ============================================================
  Widget _buildDonutCard({
    required double feedConsumed,
    required double medicineUsed,
    required double stocking,
    required double labourSalaries,
    required double other,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "expense_breakdown".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: AppColors.blackColor,
            fontSize: 14,
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: _DonutPainter(
                  feedConsumed: feedConsumed,
                  medicineUsed: medicineUsed,
                  stocking: stocking,
                  labourSalaries: labourSalaries,
                  other: other,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _legendRow(
            color: const Color(0xFF83C5BE),
            label: "feed_consumed".tr,
            value: "₹${feedConsumed.toStringAsFixed(0)}",
          ),
          const SizedBox(height: 8),
          _legendRow(
            color: const Color(0xFFF9A825),
            label: "medicine_used".tr,
            value: "₹${medicineUsed.toStringAsFixed(0)}",
          ),
          const SizedBox(height: 8),
          _legendRow(
            color: const Color(0xFF1976D2),
            label: "stocking_label".tr,
            value: "₹${stocking.toStringAsFixed(0)}",
          ),
          const SizedBox(height: 8),
          _legendRow(
            color: const Color(0xFF7E57C2),
            label: "labour_salaries".tr,
            value: "₹${labourSalaries.toStringAsFixed(0)}",
          ),
          const SizedBox(height: 8),
          _legendRow(
            color: const Color(0xFF616161),
            label: "other_label".tr,
            value: "₹${other.toStringAsFixed(0)}",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ---------- Stock on hand ----------
  // ============================================================
  Widget _buildStockCard({
    required double feedStock,
    required double medicineStock,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "stock_on_hand".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: AppColors.blackColor,
            fontSize: 13,
          ),
          const SizedBox(height: 4),
          CustomText(
            textName: "stock_on_hand_helper".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade500,
            fontSize: 10,
          ),
          const SizedBox(height: 12),
          _stockRow("feed_stock".tr, "₹${feedStock.toStringAsFixed(0)}"),
          const SizedBox(height: 8),
          _stockRow(
            "medicine_stock".tr,
            "₹${medicineStock.toStringAsFixed(0)}",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ---------- Income breakdown ----------
  // ============================================================
  Widget _buildIncomeBreakdown(double partial, double finalAmount) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "income_breakdown".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: AppColors.blackColor,
            fontSize: 13,
          ),
          const SizedBox(height: 12),
          _stockRow("partial_harvest".tr, "₹${partial.toStringAsFixed(0)}"),
          const SizedBox(height: 8),
          _stockRow("final_harvest".tr, "₹${finalAmount.toStringAsFixed(0)}"),
        ],
      ),
    );
  }

  // ============================================================
  // ---------- Date-wise table ----------
  // ============================================================
  Widget _buildDateWiseTable(List<Map<String, dynamic>> rows) {
    double runningBalance = 0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: "date_wise_pl".tr,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: AppColors.blackColor,
            fontSize: 13,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomText(
                  textName: "particulars_col".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: Colors.grey.shade700,
                  fontSize: 10,
                ),
              ),
              Expanded(
                flex: 1,
                child: CustomText(
                  textName: "debit_col".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: Colors.grey.shade700,
                  fontSize: 10,
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 1,
                child: CustomText(
                  textName: "credit_col".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: Colors.grey.shade700,
                  fontSize: 10,
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 1,
                child: CustomText(
                  textName: "balance_col".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: Colors.grey.shade700,
                  fontSize: 10,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Divider(height: 14, color: Colors.grey.shade200),
          if (rows.isEmpty)
            CustomText(
              textName: "no_transactions_yet".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 11,
            )
          else
            Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  _dateRow(
                    rows[i],
                    ref: (v) => runningBalance = v,
                    prev: runningBalance,
                  ),
                  if (i != rows.length - 1)
                    Divider(height: 1, color: Colors.grey.shade100),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _dateRow(
    Map<String, dynamic> r, {
    required Function(double) ref,
    required double prev,
  }) {
    final debit = (r["debit"] as double?) ?? 0;
    final credit = (r["credit"] as double?) ?? 0;
    final balance = prev + credit - debit;
    ref(balance);

    final dateStr =
        r["date"] != null ? _formatDayMonth(r["date"] as DateTime) : "—";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textName: dateStr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade600,
                  fontSize: 9,
                ),
                CustomText(
                  textName: (r["particulars"] as String?) ?? "—",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.medium,
                  textColor: AppColors.blackColor,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: CustomText(
              textName: debit > 0 ? "₹${debit.toStringAsFixed(0)}" : "—",
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: debit > 0 ? _red : Colors.grey,
              fontSize: 10,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 1,
            child: CustomText(
              textName: credit > 0 ? "₹${credit.toStringAsFixed(0)}" : "—",
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: credit > 0 ? _green : Colors.grey,
              fontSize: 10,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 1,
            child: CustomText(
              textName: "₹${balance.toStringAsFixed(0)}",
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.semiBold,
              textColor: balance >= 0 ? AppColors.blackColor : _red,
              fontSize: 10,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ---------- Helpers ----------
  // ============================================================
  Widget _card({required Widget child}) {
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

  Widget _legendRow({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
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
          textColor: AppColors.blackColor,
          fontSize: 11,
        ),
      ],
    );
  }

  Widget _stockRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: CustomText(
            textName: label,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        CustomText(
          textName: value,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
          fontSize: 12,
        ),
      ],
    );
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

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        children: [
          _shimmerCard(120),
          const SizedBox(height: 14),
          _shimmerCard(220),
          const SizedBox(height: 12),
          _shimmerCard(100),
        ],
      ),
    );
  }

  Widget _shimmerCard(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ============================================================
// ---------- Donut Painter ----------
// ============================================================
class _DonutPainter extends CustomPainter {
  final double feedConsumed;
  final double medicineUsed;
  final double stocking;
  final double labourSalaries;
  final double other;

  _DonutPainter({
    required this.feedConsumed,
    required this.medicineUsed,
    required this.stocking,
    required this.labourSalaries,
    required this.other,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total =
        feedConsumed + medicineUsed + stocking + labourSalaries + other;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 22.0;

    if (total <= 0) {
      final paint =
          Paint()
            ..color = Colors.grey.shade300
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final segments = [
      {"value": feedConsumed / total, "color": const Color(0xFF83C5BE)},
      {"value": medicineUsed / total, "color": const Color(0xFFF9A825)},
      {"value": stocking / total, "color": const Color(0xFF1976D2)},
      {"value": labourSalaries / total, "color": const Color(0xFF7E57C2)},
      {"value": other / total, "color": const Color(0xFF616161)},
    ];

    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      final sweep = (seg["value"] as double) * 2 * math.pi;
      if (sweep <= 0) continue;

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
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.feedConsumed != feedConsumed ||
        oldDelegate.medicineUsed != medicineUsed ||
        oldDelegate.stocking != stocking ||
        oldDelegate.labourSalaries != labourSalaries ||
        oldDelegate.other != other;
  }
}
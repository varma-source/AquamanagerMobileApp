import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/party_advance_model.dart' as adv;
import 'package:superapp/model/over_view/party_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/view_model/api_controllers/over_view/expense_party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/feed_party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_advance_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_party_controller.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);
  final Color _green = const Color(0xFF1B9C4A);
  final Color _red = const Color(0xFFE53935);
  final Color _orange = const Color(0xFFF57C00);
  final Color _lightRed = const Color(0xFFFDECEA);
  final Color _lightGreen = const Color(0xFFE7F2EA);

  final _overviewservice = Get.find<OverviewService>();

  late final PartyController _partyController;
  late final MedicinePartyController _medicinePartyController;
  late final FeedPartyController _feedPartyController;
  late final ExpensePartyController _expensePartyController;

  final Map<String, PartyAdvanceController> _advanceControllers = {};

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<PartyController>()) {
      _partyController = Get.find<PartyController>();
    } else {
      _partyController = Get.put(PartyController(OverviewService()));
    }
    _partyController.fetchpartydata();

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

    ever(_partyController.partyDataResponce, (data) {
      final parties = data.data ?? [];
      for (final p in parties) {
        final pid = p.id ?? "";
        if (pid.isEmpty) continue;

        if (!_advanceControllers.containsKey(pid)) {
          final c = Get.put(
            PartyAdvanceController(OverviewService()),
            tag: pid,
          );
          _advanceControllers[pid] = c;
          c.fetchpartyadvance(partyId: pid);
        }
      }
    });
  }

  @override
  void dispose() {
    for (final entry in _advanceControllers.entries) {
      Get.delete<PartyAdvanceController>(tag: entry.key, force: true);
    }
    super.dispose();
  }

  Map<String, double> _advanceTotalsForParty(String partyId) {
    final c = _advanceControllers[partyId];
    double paid = 0;
    double advanceGiven = 0;

    if (c != null) {
      final list = c.partyadvDataResponce.value.data ?? [];
      for (final d in list) {
        final amt = double.tryParse(d.amount ?? "0") ?? 0;
        if (amt <= 0) continue;

        final type = (d.paymentType ?? "").toLowerCase().trim();

        if (type == "advance") {
          advanceGiven += amt;
        } else if (type == "payment") {
          paid += amt;
        } else {
          final note = (d.notes ?? "").toLowerCase();
          if (note.contains("advance")) {
            advanceGiven += amt;
          } else {
            paid += amt;
          }
        }
      }
    }

    return {
      "paid": paid,
      "advanceGiven": advanceGiven,
    };
  }

  double _feedTotalForParty(String partyId) {
    final list = _feedPartyController.feedpartyDataResponce.value.data ?? [];
    double total = 0;
    for (final item in list) {
      if (item.partyId == partyId) {
        total += double.tryParse(item.totalAmount ?? "0") ?? 0;
      }
    }
    return total;
  }

  double _medicineTotalForParty(String partyId) {
    final list =
        _medicinePartyController.medicinepartyDataResponce.value.data ?? [];
    double total = 0;
    for (final item in list) {
      if (item.partyId == partyId) {
        total += double.tryParse(item.amount ?? "0") ?? 0;
      }
    }
    return total;
  }

  double _expenseTotalForParty(String partyId) {
    final list = _expensePartyController.expenseDataResponce.value.data ?? [];
    double total = 0;
    for (final item in list) {
      if (item.partyId == partyId) {
        total += double.tryParse(item.amount ?? "0") ?? 0;
      }
    }
    return total;
  }

  void _showDeleteDialog({required String name, required String id}) {
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
            horizontal: 32,
            vertical: 24,
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red.withOpacity(0.1),
                  ),
                  child: Icon(Icons.delete_outline, color: _red, size: 30),
                ),
                const SizedBox(height: 16),
                CustomText(
                  textName: "delete_party_q".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 16,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                CustomText(
                  textName: "${"delete_confirm_msg".tr} \"$name\"? ${"cannot_undo".tr}",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade600,
                  fontSize: 12,
                  textAlign: TextAlign.center,
                ),
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: CustomText(
                            textName: "delete".tr,
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
        );
      },
    );
  }

  void _showPayPartySheet({required String partyName, required String id}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder:
          (context) => _PayPartySheet(
            partyName: partyName,
            partyId: id,
            onSaved: () {
              final c = _advanceControllers[id];
              if (c != null) c.fetchpartyadvance(partyId: id);
            },
          ),
    );
  }

  void _showAddPartySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder:
          (context) => _AddPartySheet(
            onSaved: (name, phone, notes) {
              _partyController.fetchpartydata();
            },
          ),
    );
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
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  CustomText(
                    textName: "parties".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 15,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showAddPartySheet,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.add, color: _primary, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // ---------- Body ----------
            Expanded(
              child: Obx(() {
                final resp = _partyController.partyDataResponce.value;
                final loading = resp.data == null;
                final parties = resp.data ?? [];

                if (loading) {
                  return _buildShimmerBody();
                }

                double totalPaid = 0;
                double totalAdvanceGiven = 0;
                for (final p in parties) {
                  final pid = p.id ?? "";
                  final totals = _advanceTotalsForParty(pid);
                  totalPaid += totals["paid"]!;
                  totalAdvanceGiven += totals["advanceGiven"]!;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- Summary Row ----------
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _lightRed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    textName: "total_paid".tr,
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.regular,
                                    textColor: Colors.grey.shade700,
                                    fontSize: 10,
                                  ),
                                  const SizedBox(height: 6),
                                  CustomText(
                                    textName:
                                        "₹${totalPaid.toStringAsFixed(0)}",
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.bold,
                                    textColor: _red,
                                    fontSize: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _lightGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    textName: "advance_given".tr,
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.regular,
                                    textColor: Colors.grey.shade700,
                                    fontSize: 10,
                                  ),
                                  const SizedBox(height: 6),
                                  CustomText(
                                    textName:
                                        "₹${totalAdvanceGiven.toStringAsFixed(0)}",
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.bold,
                                    textColor: _green,
                                    fontSize: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ---------- Party Cards List ----------
                      if (parties.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: parties.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildPartyCard(parties[index]);
                          },
                        ),

                      // ---------- Empty State ----------
                      if (parties.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                CustomText(
                                  textName: "no_parties_yet".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.medium,
                                  textColor: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  // ---------- Party Card ----------
  Widget _buildPartyCard(Datum party) {
    final name = party.name ?? "";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
    final phone = party.phone ?? "—";
    final partyId = party.id ?? "";

    return Obx(() {
      _feedPartyController.feedpartyDataResponce.value;
      _medicinePartyController.medicinepartyDataResponce.value;
      _expensePartyController.expenseDataResponce.value;

      final totals = _advanceTotalsForParty(partyId);
      final paid = totals["paid"]!;
      final advanceGiven = totals["advanceGiven"]!;

      final feedPurchases = _feedTotalForParty(partyId);
      final medicinePurchases = _medicineTotalForParty(partyId);
      final expensePurchases = _expenseTotalForParty(partyId);

      final totalPurchases =
          feedPurchases + medicinePurchases + expensePurchases;

      final totalSettled = paid + advanceGiven;

      final remainingAmount = totalPurchases - totalSettled;

      final isAdvanceWithParty = remainingAmount < 0;
      final remainingLabel =
          isAdvanceWithParty ? "advance_with_party".tr : "remaining_to_pay".tr;
      final remainingColor = isAdvanceWithParty ? _green : _red;
      final remainingBg = isAdvanceWithParty ? _lightGreen : _lightRed;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            // ---------- Header ----------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomText(
                      textName: initial,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor: _primary,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        textName: name,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: AppColors.blackColor,
                        fontSize: 15,
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        textName: phone,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 14),

            // ---------- Feed / Medicine / Expense row ----------
            Row(
              children: [
                Expanded(
                  child: _buildStatBlock(
                    label: "feed".tr,
                    value: "₹${feedPurchases.toStringAsFixed(0)}",
                    valueColor: _green,
                  ),
                ),
                Expanded(
                  child: _buildStatBlock(
                    label: "medicine".tr,
                    value: "₹${medicinePurchases.toStringAsFixed(0)}",
                    valueColor: _primary,
                  ),
                ),
                Expanded(
                  child: _buildStatBlock(
                    label: "expense".tr,
                    value: "₹${expensePurchases.toStringAsFixed(0)}",
                    valueColor: _orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---------- Paid / Given Advance row ----------
            Row(
              children: [
                Expanded(
                  child: _buildStatBlock(
                    label: "paid".tr,
                    value: "₹${paid.toStringAsFixed(0)}",
                    valueColor: AppColors.blackColor,
                  ),
                ),
                Expanded(
                  child: _buildStatBlock(
                    label: "given_advance".tr,
                    value: "₹${advanceGiven.toStringAsFixed(0)}",
                    valueColor:
                        advanceGiven > 0 ? _green : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---------- Totals + Remaining row ----------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: remainingBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: remainingColor.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          textName: remainingLabel,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.semiBold,
                          textColor: remainingColor,
                          fontSize: 11,
                        ),
                        const SizedBox(height: 2),
                        CustomText(
                          textName:
                              "${"total_label".tr} ₹${totalPurchases.toStringAsFixed(0)} • ${"settled_label".tr} ₹${totalSettled.toStringAsFixed(0)}",
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: Colors.grey.shade600,
                          fontSize: 9,
                        ),
                      ],
                    ),
                  ),
                  CustomText(
                    textName: "₹${remainingAmount.abs().toStringAsFixed(0)}",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: remainingColor,
                    fontSize: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---------- Record payment / advance button ----------
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed:
                    () => _showPayPartySheet(partyName: name, id: partyId),
                icon: Icon(
                  Icons.receipt_long_outlined,
                  size: 16,
                  color: _primary,
                ),
                label: CustomText(
                  textName: "record_payment_advance".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: _primary,
                  fontSize: 12,
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatBlock({
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
          fontSize: 10,
        ),
        const SizedBox(height: 4),
        CustomText(
          textName: value,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: valueColor,
          fontSize: 14,
          maxLines: 1,
          overFlow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildShimmerBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 72, radius: 12)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerBox(height: 72, radius: 12)),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 3; i++) ...[
            _shimmerBox(height: 200, radius: 14),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, double radius = 8}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ============================================================
// ---------- ADD PARTY BOTTOM SHEET ----------
// ============================================================
class _AddPartySheet extends StatefulWidget {
  final void Function(String name, String phone, String notes) onSaved;
  const _AddPartySheet({required this.onSaved});

  @override
  State<_AddPartySheet> createState() => _AddPartySheetState();
}

class _AddPartySheetState extends State<_AddPartySheet> {
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  final _overviewservice = Get.find<OverviewService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              CustomText(
                textName: "add_party".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: AppColors.blackColor,
                fontSize: 16,
              ),
              const SizedBox(height: 18),

              _buildLabel("party_name".tr),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: "",
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),

              _buildLabel("phone_optional".tr),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hint: "",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildLabel("notes_optional".tr),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _notesController,
                hint: "",
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.trim().isEmpty) {
                      Get.snackbar(
                        "required".tr,
                        "please_enter_party_name".tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: _primary,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    await _overviewservice.useraddparty(
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      notes: _notesController.text.trim(),
                    );
                    widget.onSaved(
                      _nameController.text.trim(),
                      _phoneController.text.trim(),
                      _notesController.text.trim(),
                    );
                    Get.back();
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
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.semiBold,
      textColor: AppColors.blackColor,
      fontSize: 12,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
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
}

// ============================================================
// ---------- PAY PARTY BOTTOM SHEET ----------
// ============================================================
class _PayPartySheet extends StatefulWidget {
  final String partyName;
  final String partyId;
  final VoidCallback? onSaved;

  const _PayPartySheet({
    required this.partyName,
    required this.partyId,
    this.onSaved,
  });

  @override
  State<_PayPartySheet> createState() => _PayPartySheetState();
}

class _PayPartySheetState extends State<_PayPartySheet> {
  final Color _primary = const Color(0xFF087FC1);

  String _selectedType = "payment";

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedPaymentMethod = "cash";
  final List<String> _paymentMethods = [
    "cash",
    "banktransfer",
    "upi",
    "cheque",
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = "select_date".tr;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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
    }
  }

  String _helperText() {
    if (_selectedType == "payment") {
      return "payment_helper".tr;
    } else {
      return "advance_helper".tr;
    }
  }

  // 🌐 Translate payment method for display
  String _methodLabel(String key) {
    switch (key) {
      case "cash":
        return "cash".tr;
      case "banktransfer":
        return "bank_transfer".tr;
      case "upi":
        return "upi".tr;
      case "cheque":
        return "cheque".tr;
      default:
        return key;
    }
  }

  // 🌐 Translate toggle item for display
  String _toggleLabel(String key) {
    switch (key) {
      case "payment":
        return "payment".tr;
      case "advance":
        return "advance".tr;
      default:
        return key;
    }
  }

  final _overviewservice = Get.find<OverviewService>();

  Future<void> _submit() async {
    if (_amountController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_amount".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _primary,
        colorText: Colors.white,
      );
      return;
    }

    if (_dateController.text == "select_date".tr ||
        _dateController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_select_date".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _primary,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _overviewservice.useraddpartypayment(
        partyId: widget.partyId,
        date: _dateController.text,
        amount: _amountController.text.trim(),
        notes: _notesController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
        paymentType: _selectedType,
      );

      if (result != null) {
        widget.onSaved?.call();
        if (mounted) {
          Get.back();
        }
      }
    } catch (e) {
      debugPrint("Pay party error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              CustomText(
                textName: "${"pay".tr} ${widget.partyName}",
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: AppColors.blackColor,
                fontSize: 16,
              ),
              const SizedBox(height: 16),

              // ---------- Payment / Advance Toggle ----------
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildToggleItem("payment"),
                    _buildToggleItem("advance"),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              CustomText(
                textName: _helperText(),
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade600,
                fontSize: 11,
              ),
              const SizedBox(height: 18),

              _buildLabel("date".tr),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _dateController,
                hint: "yyyy_mm_dd".tr,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 16),

              _buildLabel("amount".tr),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _amountController,
                hint: "",
                keyboardType: TextInputType.number,
                prefixText: "₹ ",
                suffixIcon: Icons.unfold_more,
              ),
              const SizedBox(height: 16),

              _buildLabel("payment_method".tr),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade700,
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    items:
                        _paymentMethods.map((m) {
                          return DropdownMenuItem<String>(
                            value: m,
                            child: CustomText(
                              textName: _methodLabel(m),
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: AppColors.blackColor,
                              fontSize: 13,
                            ),
                          );
                        }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedPaymentMethod = v);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel("notes_optional".tr),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _notesController,
                hint: "",
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // ---------- Save Button ----------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primary.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                            textName: "save".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: Colors.white,
                            fontSize: 14,
                          ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String key) {
    final isSelected = _selectedType == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = key),
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
              textName: _toggleLabel(key),
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

  Widget _buildLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.semiBold,
      textColor: AppColors.blackColor,
      fontSize: 12,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    String? prefixText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixText: prefixText,
        prefixStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        suffixIcon:
            suffixIcon != null
                ? Icon(suffixIcon, size: 16, color: Colors.grey.shade600)
                : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
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
}
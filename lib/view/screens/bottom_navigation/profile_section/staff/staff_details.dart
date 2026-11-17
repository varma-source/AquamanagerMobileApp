import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/staff/staff_model.dart';
import 'package:superapp/model/staff/worker_advance_model.dart' as advance;
import 'package:superapp/model/staff/worker_model.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/staff/add_staff_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/staff/add_worker_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/staff/edit_staff_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/staff/edit_worker_screen.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_advance_controller.dart';

class StaffDetails extends StatefulWidget {
  const StaffDetails({super.key});

  @override
  State<StaffDetails> createState() => _StaffDetailsState();
}

class _StaffDetailsState extends State<StaffDetails> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);
  final Color _green = const Color(0xFF1B9C4A);
  final Color _orange = const Color(0xFFF57C00);

  // Controllers
  late final StaffController _staffController;
  late final WorkerController _workerController;

  String? _expandedWorkerId;

  @override
  void initState() {
    super.initState();
    _staffController = Get.put(StaffController(TankService()));
    _workerController = Get.put(WorkerController(TankService()));
  }

  final _tankservice = Get.find<TankService>();

  // ---------- Delete Confirmation Dialog ----------
  void _showDeleteDialog({
    required String name,
    required String id,
    required bool isWorker,
  }) {
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
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(
                  textName:
                      isWorker ? "delete_worker_q".tr : "delete_staff_q".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 16,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                CustomText(
                  textName:
                      "${"delete_confirm_msg".tr} \"$name\"? ${"cannot_undo".tr}",
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
                            if (isWorker) {
                              _tankservice.userworkdelete(workerId: id);
                            } else {
                              _tankservice.userdeletestaff(staffId: id);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
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
                    textName: "staff_management".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 15,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.to(AddStaffScreen());
                    },
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
                final staffResponse = _staffController.staffDataResponce.value;
                final workerResponse =
                    _workerController.workerDataResponce.value;

                final staffLoading = staffResponse.staffs == null;
                final workerLoading = workerResponse.data == null;

                if (staffLoading || workerLoading) {
                  return _buildShimmerBody();
                }

                final allStaff = staffResponse.staffs ?? [];
                final staffList =
                    allStaff
                        .where((s) => (s.role ?? "").toLowerCase() != "worker")
                        .toList();

                final workerList = workerResponse.data ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- Staff Cards ----------
                      if (staffList.isEmpty)
                        _buildEmptyCard("no_staff_yet".tr)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: staffList.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildStaffCard(staffList[index]);
                          },
                        ),
                      const SizedBox(height: 20),

                      // ---------- Workers Section Header ----------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  textName: "workers".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.bold,
                                  textColor: AppColors.blackColor,
                                  fontSize: 14,
                                ),
                                const SizedBox(height: 4),
                                CustomText(
                                  textName: "workers_subtitle".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.regular,
                                  textColor: Colors.grey.shade600,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                barrierColor: Colors.black.withOpacity(0.45),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) => const AddWorkerScreen(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F6F7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: _primary, size: 14),
                                  const SizedBox(width: 4),
                                  CustomText(
                                    textName: "add_worker".tr,
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.semiBold,
                                    textColor: _primary,
                                    fontSize: 11,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ---------- Worker Cards ----------
                      if (workerList.isEmpty)
                        _buildEmptyCard("no_workers_yet".tr)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: workerList.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildWorkerCard(workerList[index]);
                          },
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

  // ---------- Empty Card ----------
  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Center(
        child: CustomText(
          textName: message,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }

  // ---------- Staff Card ----------
  Widget _buildStaffCard(Staff s) {
    final name = s.name ?? "";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
    final status = s.status ?? "";
    final role = s.role ?? "";
    final isActive = (status.toLowerCase() == "active");

    return Container(
      padding: const EdgeInsets.all(14),
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
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 90),
                            child: CustomText(
                              textName: name,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.bold,
                              textColor: AppColors.blackColor,
                              fontSize: 14,
                              maxLines: 2,
                              overFlow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (status.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _chip(status, _green),
                        ],
                        if (role.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _chip(role, Colors.grey.shade600),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      textName: s.email ?? "",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Get.to(() => EditStaffScreen(staff: s));
                      _staffController.fetchstaffdata();
                    },
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap:
                        () => _showDeleteDialog(
                          name: name,
                          id: s.id ?? "",
                          isWorker: false,
                        ),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
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
                                textName: s.phone ?? "",
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.regular,
                                textColor: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                              CustomText(
                                textName:
                                    "${"tank_name_label".tr}: ${(s.tankName ?? []).isEmpty ? "—" : s.tankName!.join(", ")}",
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.regular,
                                textColor: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isActive,
                  onChanged: (v) {},
                  activeColor: _primary,
                  activeTrackColor: _primary.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Worker Card (EXPANDABLE) ----------
  Widget _buildWorkerCard(Datum w) {
    final name = w.name ?? "";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
    final role = "worker".tr;
    final salary = w.monthlySalary ?? "";
    final phone = w.phone ?? "";
    final isActive = (w.status ?? "").toLowerCase() == "active";
    final workerId = w.id ?? "";
    final isExpanded = _expandedWorkerId == workerId;

    // Build meta string
    final parts = <String>[];
    if (w.joiningDate != null) {
      parts.add(
        "${"joined".tr} ${w.joiningDate!.day} ${_monthName(w.joiningDate!.month)}",
      );
    }
    if (salary.isNotEmpty) parts.add("₹$salary/${"month".tr}");
    if (phone.isNotEmpty) parts.add(phone);
    final meta = parts.join(" · ");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? _primary.withOpacity(0.4) : Colors.grey.shade200,
          width: isExpanded ? 1.4 : 1,
        ),
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
        children: [
          // ---------- Header (tap to expand) ----------
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedWorkerId = null;
                } else {
                  _expandedWorkerId = workerId;
                  if (Get.isRegistered<WorkerAdvanceController>()) {
                    Get.find<WorkerAdvanceController>().fetchworkeradvancedata(
                      workerId: workerId,
                    );
                  } else {
                    Get.put(
                      WorkerAdvanceController(TankService()),
                    ).fetchworkeradvancedata(workerId: workerId);
                  }
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomText(
                        textName: initial,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: _orange,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 90),
                                child: CustomText(
                                  textName: name,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.bold,
                                  textColor: AppColors.blackColor,
                                  fontSize: 14,
                                  maxLines: 2,
                                  overFlow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _chip(role, Colors.grey.shade600),
                          ],
                        ),
                        if (meta.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          CustomText(
                            textName: meta,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ],
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: isActive,
                          onChanged: (v) {},
                          activeColor: _primary,
                          activeTrackColor: _primary.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierColor: Colors.black.withOpacity(0.45),
                            builder:
                                (context) => GiveAdvanceDialog(
                                  workerId: workerId,
                                  staffName: name,
                                ),
                          );
                        },
                        child: Icon(
                          Icons.attach_money_outlined,
                          size: 16,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await Get.to(() => EditWorkerScreen(worker: w));
                          _workerController.fetchworkerdata();
                        },
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap:
                            () => _showDeleteDialog(
                              name: name,
                              id: workerId,
                              isWorker: true,
                            ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ---------- Expanded Advance List ----------
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: _buildAdvanceHistory(workerId),
            ),
          ],
        ],
      ),
    );
  }

  // ---------- Advance History Section ----------
  Widget _buildAdvanceHistory(String workerId) {
    if (!Get.isRegistered<WorkerAdvanceController>()) {
      Get.put(WorkerAdvanceController(TankService()));
    }
    final controller = Get.find<WorkerAdvanceController>();

    return Obx(() {
      final response = controller.workeradvanceDataResponce.value;

      if (response.data == null) {
        return _buildAdvanceShimmer();
      }

      final advances = response.data ?? [];

      if (advances.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: CustomText(
              textName: "no_advances_yet".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 14, color: _primary),
              const SizedBox(width: 6),
              CustomText(
                textName: "advance_history".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: AppColors.blackColor,
                fontSize: 12,
              ),
              const Spacer(),
              CustomText(
                textName:
                    "${advances.length} ${advances.length == 1 ? "entry".tr : "entries".tr}",
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade600,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: advances.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildAdvanceTile(advances[index]);
            },
          ),
        ],
      );
    });
  }

  // ---------- Advance Tile ----------
  Widget _buildAdvanceTile(advance.Datum adv) {
    final dateText =
        adv.date != null
            ? "${adv.date!.day.toString().padLeft(2, '0')}/"
                "${adv.date!.month.toString().padLeft(2, '0')}/"
                "${adv.date!.year}"
            : "—";
    final amount = adv.amount ?? "0";
    final purpose = adv.purpose ?? "";
    final paidBy = adv.paidBy ?? "";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.currency_rupee, size: 16, color: _primary),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      textName: "₹$amount",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      textColor: AppColors.blackColor,
                      fontSize: 13,
                    ),
                    const SizedBox(width: 8),
                    if (paidBy.isNotEmpty)
                      _chip(_paidByLabel(paidBy), _primary),
                  ],
                ),
                const SizedBox(height: 3),
                CustomText(
                  textName:
                      dateText + (purpose.isNotEmpty ? " · $purpose" : ""),
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌐 Translated paid-by label
  String _paidByLabel(String key) {
    final k = key.toLowerCase().trim();
    if (k == "cash") return "cash".tr;
    if (k == "banktransfer") return "bank_transfer".tr;
    if (k == "upi") return "upi".tr;
    if (k == "cheque") return "cheque".tr;
    return key;
  }

  // ---------- Advance Shimmer ----------
  Widget _buildAdvanceShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(2, (_) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
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
                        const SizedBox(height: 6),
                        Container(
                          width: 140,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------- Chip ----------
  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        textName: label,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.medium,
        textColor: color,
        fontSize: 9,
      ),
    );
  }

  // ---------- Month Name Helper ----------
  String _monthName(int month) {
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

  // ---------- Shimmer Loading Body ----------
  Widget _buildShimmerBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(2, (_) => _shimmerStaffCard()),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 220,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(2, (_) => _shimmerWorkerCard()),
        ],
      ),
    );
  }

  Widget _shimmerStaffCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 180,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
    );
  }

  Widget _shimmerWorkerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- GiveAdvanceDialog ----------
class GiveAdvanceDialog extends StatefulWidget {
  final String workerId;
  final String staffName;
  const GiveAdvanceDialog({
    super.key,
    required this.workerId,
    required this.staffName,
  });

  @override
  State<GiveAdvanceDialog> createState() => _GiveAdvanceDialogState();
}

class _GiveAdvanceDialogState extends State<GiveAdvanceDialog> {
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  String _selectedPaidBy = "cash";
  final List<String> _paidByOptions = ["cash", "banktransfer", "upi", "cheque"];

  @override
  void initState() {
    super.initState();
    _dateController.text = "select_date".tr;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  final _tankservice = Get.find<TankService>();

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
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // 🌐 Translate paid-by label for display
  String _paidByLabel(String key) {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              textName: "${"give_advance".tr} — ${widget.staffName}",
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.bold,
              textColor: AppColors.blackColor,
              fontSize: 15,
            ),
            const SizedBox(height: 8),
            CustomText(
              textName: "advance_note".tr,
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
              hint: "dd_mm_yyyy".tr,
              readOnly: true,
              onTap: _pickDate,
              suffixIcon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 14),
            _buildLabel("amount".tr),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _amountController,
              hint: "",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _buildLabel("purpose_optional".tr),
            const SizedBox(height: 6),
            _buildTextField(controller: _purposeController, hint: ""),
            const SizedBox(height: 14),
            _buildLabel("paid_by".tr),
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
                  value: _selectedPaidBy,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade700,
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  items:
                      _paidByOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: CustomText(
                            textName: _paidByLabel(option),
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: AppColors.blackColor,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedPaidBy = v);
                    }
                  },
                ),
              ),
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
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
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
                      // onPressed: () {
                      //   _tankservice.useraddadvance(
                      //     workerId: widget.workerId,
                      //     date: _dateController.text,
                      //     amount: _amountController.text,
                      //     purpose: _purposeController.text,
                      //     paidBy: _selectedPaidBy,
                      //   );
                      // },
                      onPressed: () async {
                        // Basic validation
                        if (_amountController.text.trim().isEmpty) {
                          Get.snackbar(
                            "required".tr,
                            "please_enter_amount".tr,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // ✅ Close the dialog FIRST so it disappears cleanly
                        Navigator.pop(context);

                        try {
                          await _tankservice.useraddadvance(
                            workerId: widget.workerId,
                            date:
                                _dateController.text == "select_date".tr
                                    ? ""
                                    : _dateController.text,
                            amount: _amountController.text.trim(),
                            purpose: _purposeController.text.trim(),
                            paidBy: _selectedPaidBy,
                          );

                          // ✅ Refresh the advance history in place (no navigation)
                          if (Get.isRegistered<WorkerAdvanceController>()) {
                            Get.find<WorkerAdvanceController>()
                                .fetchworkeradvancedata(
                                  workerId: widget.workerId,
                                );
                          }
                        } catch (e) {
                          Get.snackbar(
                            "error".tr,
                            "${"failed_save_advance".tr}: $e",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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

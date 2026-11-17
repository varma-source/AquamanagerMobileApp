import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/staff/staff_model.dart';
import 'package:superapp/model/staff/staff_tank_model.dart';
import 'package:superapp/services/profileService.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_tank_controller.dart';

class EditStaffScreen extends StatefulWidget {
  final Staff staff;

  const EditStaffScreen({super.key, required this.staff});

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final Color _primary = const Color(0xFF087FC1);
  final Color _red = const Color(0xFFE53935);
  final Color _green = const Color(0xFF10B981);

  final _tankService = Get.find<TankService>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _monthlySalaryController =
      TextEditingController();
  final TextEditingController _adharController = TextEditingController();
  final TextEditingController _advanceSalaryController =
      TextEditingController();
  final TextEditingController _advanceAlreadyGivenController =
      TextEditingController();

  String _selectedRole = "staff";
  final List<Datum> _selectedPonds = [];
  List<String> _pendingTankIds = [];

  late final StaffTankController _staffTankController;
  late final ProfileController _profileController;

  bool _isSaving = false;
  bool _isTogglingStatus = false;
  String _currentStatus = "active";

  List<String> get _roles {
    final currentRole =
        _profileController.profileDataResponce.value.data?.role?.toLowerCase() ??
            "";
    if (currentRole == "coowner") {
      return ["staff", "manager"];
    }
    return ["staff", "manager", "coowner"];
  }

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<ProfileController>()) {
      _profileController = Get.find<ProfileController>();
    } else {
      _profileController = Get.put(ProfileController(ProfileService()));
    }
    if (_profileController.profileDataResponce.value.data == null) {
      _profileController.fetchgetprofiledata();
    }

    if (Get.isRegistered<StaffTankController>()) {
      _staffTankController = Get.find<StaffTankController>();
    } else {
      _staffTankController = Get.put(StaffTankController(TankService()));
    }

    if (_staffTankController.stafftankDataResponce.value.data == null) {
      _staffTankController.fetchstafftankdata();
    }

    _prefill();
  }

  void _prefill() {
    final s = widget.staff;
    _nameController.text = s.name ?? "";
    _emailController.text = s.email ?? "";
    _phoneController.text = s.phone ?? "";
    _monthlySalaryController.text = s.monthlySalary ?? "";
    _adharController.text = s.adharNumber ?? "";
    _advanceSalaryController.text = s.advanceSalary ?? "";
    _advanceAlreadyGivenController.text = s.advanceSalary ?? "";

    if (s.joiningDate != null) {
      _joiningDateController.text =
          "${s.joiningDate!.year.toString().padLeft(4, '0')}-"
          "${s.joiningDate!.month.toString().padLeft(2, '0')}-"
          "${s.joiningDate!.day.toString().padLeft(2, '0')}";
    }

    final roleLower = (s.role ?? "").toLowerCase().trim();
    if (_roles.contains(roleLower)) {
      _selectedRole = roleLower;
    }

    _currentStatus = (s.status ?? "active").toLowerCase().trim();
    _pendingTankIds = (s.tankId ?? []).where((id) => id.isNotEmpty).toList();
    _resolvePendingPonds();
  }

  void _resolvePendingPonds() {
    if (_pendingTankIds.isEmpty) return;
    if (_selectedPonds.isNotEmpty) return;

    final ponds = _staffTankController.stafftankDataResponce.value.data;
    if (ponds == null || ponds.isEmpty) return;

    for (final p in ponds) {
      if (_pendingTankIds.contains(p.id)) {
        _selectedPonds.add(p);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _joiningDateController.dispose();
    _monthlySalaryController.dispose();
    _adharController.dispose();
    _advanceSalaryController.dispose();
    _advanceAlreadyGivenController.dispose();
    super.dispose();
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.staff.joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
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
        _joiningDateController.text =
            "${picked.year.toString().padLeft(4, '0')}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    if (_selectedRole == "staff" && _selectedPonds.isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_assign_pond".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _primary,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSaving = true);

    final List<String>? tankIdValue =
        (_selectedRole == "staff" && _selectedPonds.isNotEmpty)
            ? _selectedPonds
                .map((p) => p.id ?? "")
                .where((id) => id.isNotEmpty)
                .toList()
            : null;

    debugPrint("Selected tankIds: $tankIdValue");

    try {
      await _tankService.userEditStaff(
        staffId: widget.staff.id ?? "",
        name: _nameController.text.trim(),
        joiningDate: _joiningDateController.text.trim(),
        monthlySalary: _monthlySalaryController.text.trim(),
        adharNumber: _adharController.text.trim(),
        advanceSalary: _advanceSalaryController.text.trim(),
        role: _selectedRole,
        advanceAlreadyGiven: _advanceAlreadyGivenController.text.trim(),
        tankId: tankIdValue,
      );
    } catch (e) {
      debugPrint("Edit staff error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleStatus() async {
    if (_isTogglingStatus) return;

    final isCurrentlyActive = _currentStatus == "active";
    final newStatus = isCurrentlyActive ? "inactive" : "active";
    final actionText = isCurrentlyActive ? "deactivate".tr : "activate".tr;
    final actionColor = isCurrentlyActive ? _red : _green;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrentlyActive
                        ? Icons.person_off_outlined
                        : Icons.person_outline,
                    color: actionColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(
                  textName: "${actionText} ${"staff".tr}?",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 16,
                ),
                const SizedBox(height: 8),
                CustomText(
                  textName: isCurrentlyActive
                      ? "${"deactivate_staff_msg".tr} ${widget.staff.name ?? "this_staff".tr}? ${"lose_access".tr}"
                      : "${"activate_staff_msg".tr} ${widget.staff.name ?? "this_staff".tr}? ${"regain_access".tr}",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade700,
                  fontSize: 12,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
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
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: CustomText(
                            textName: actionText,
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

    if (confirmed != true) return;

    setState(() => _isTogglingStatus = true);

    try {
      await _tankService.useractivestaff(
        staffId: widget.staff.id ?? "",
        status: newStatus,
      );

      if (!mounted) return;

      setState(() {
        _currentStatus = newStatus;
      });

      Get.snackbar(
        "success".tr,
        "${widget.staff.name ?? "staff".tr} ${"has_been".tr} $newStatus.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: actionColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
      );
    } catch (e) {
      debugPrint("Toggle staff status error: $e");
      if (!mounted) return;
      Get.snackbar(
        "failed".tr,
        "could_not_update_status".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _primary,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isTogglingStatus = false);
    }
  }

  // 🌐 Translate role for display (keeps internal value in English)
  String _roleLabel(String role) {
    switch (role) {
      case "staff":
        return "staff".tr;
      case "manager":
        return "manager".tr;
      case "coowner":
        return "coowner".tr;
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _currentStatus == "active";
    final statusActionColor = isActive ? _red : _green;

    if (!_roles.contains(_selectedRole)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_roles.contains(_selectedRole)) {
          setState(() => _selectedRole = _roles.first);
        }
      });
    }

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
                    textName: "edit_staff".tr,
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

            // ---------- Form ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("full_name".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _nameController,
                        hint: "enter_full_name".tr,
                        icon: Icons.person_outline,
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "please_enter_name".tr
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("email".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        readOnly: true,
                        controller: _emailController,
                        hint: "enter_email".tr,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "please_enter_email".tr
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("phone".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _phoneController,
                        hint: "enter_phone".tr,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "please_enter_phone".tr;
                          }
                          if (v.trim().length != 10) {
                            return "phone_10_digits".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("joining_date".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _joiningDateController,
                        hint: "yyyy_mm_dd".tr,
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: _pickJoiningDate,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("monthly_salary".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _monthlySalaryController,
                        hint: "enter_monthly_salary".tr,
                        icon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("aadhaar_number".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _adharController,
                        hint: "enter_aadhaar".tr,
                        icon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(12),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("advance_salary".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _advanceSalaryController,
                        hint: "enter_advance_salary".tr,
                        icon: Icons.account_balance_wallet_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("advance_already_given".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _advanceAlreadyGivenController,
                        hint: "enter_advance_given".tr,
                        icon: Icons.money_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Role toggle
                      _buildLabel("role".tr),
                      const SizedBox(height: 10),
                      _buildRoleToggle(),
                      const SizedBox(height: 8),
                      CustomText(
                        textName: _getRoleDescription(),
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                      const SizedBox(height: 16),

                      if (_selectedRole == "staff") ...[
                        _buildLabel("assign_ponds".tr),
                        const SizedBox(height: 6),
                        _buildPondMultiSelect(),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 26),

                      // Save
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _primary.withOpacity(0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : CustomText(
                                    textName: "save_changes".tr,
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.semiBold,
                                    textColor: Colors.white,
                                    fontSize: 14,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: CustomText(
                            textName: "cancel".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: AppColors.blackColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Toggle status button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _isTogglingStatus ? null : _toggleStatus,
                          icon:
                              _isTogglingStatus
                                  ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: statusActionColor,
                                    ),
                                  )
                                  : Icon(
                                    isActive
                                        ? Icons.person_off_outlined
                                        : Icons.person_outline,
                                    size: 18,
                                    color: statusActionColor,
                                  ),
                          label: CustomText(
                            textName:
                                isActive
                                    ? "deactivate_staff".tr
                                    : "activate_staff".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: statusActionColor,
                            fontSize: 14,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: statusActionColor,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPondMultiSelect() {
    return Obx(() {
      final response = _staffTankController.stafftankDataResponce.value;

      if (response.data == null) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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

      final pondList = response.data!;

      if (pondList.isEmpty) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: CustomText(
              textName: "no_ponds_available".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        );
      }

      if (_selectedPonds.isEmpty && _pendingTankIds.isNotEmpty) {
        final matches =
            pondList.where((p) => _pendingTankIds.contains(p.id)).toList();
        if (matches.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedPonds.isEmpty) {
              setState(() {
                _selectedPonds.addAll(matches);
              });
            }
          });
        }
      }

      _selectedPonds.removeWhere((sel) => !pondList.any((p) => p.id == sel.id));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openPondPicker(pondList),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child:
                        _selectedPonds.isEmpty
                            ? CustomText(
                              textName: "select_ponds".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: Colors.grey.shade400,
                              fontSize: 13,
                            )
                            : CustomText(
                              textName:
                                  "${_selectedPonds.length} ${"ponds_selected".tr}",
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: AppColors.blackColor,
                              fontSize: 13,
                            ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
                ],
              ),
            ),
          ),

          if (_selectedPonds.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _selectedPonds.map((pond) {
                    return Chip(
                      label: CustomText(
                        textName: pond.name ?? "Unnamed Pond",
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: AppColors.blackColor,
                        fontSize: 12,
                      ),
                      backgroundColor: const Color(0xFFE6F2F9),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedPonds.removeWhere((p) => p.id == pond.id);
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: _primary.withOpacity(0.3)),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      );
    });
  }

  void _openPondPicker(List<Datum> pondList) {
    final Set<String> tempSelected =
        _selectedPonds
            .map((p) => p.id ?? "")
            .where((id) => id.isNotEmpty)
            .toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomText(
                          textName: "select_ponds".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.bold,
                          textColor: AppColors.blackColor,
                          fontSize: 15,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              if (tempSelected.length == pondList.length) {
                                tempSelected.clear();
                              } else {
                                tempSelected
                                  ..clear()
                                  ..addAll(
                                    pondList
                                        .map((p) => p.id ?? "")
                                        .where((id) => id.isNotEmpty),
                                  );
                              }
                            });
                          },
                          child: CustomText(
                            textName:
                                tempSelected.length == pondList.length
                                    ? "clear_all".tr
                                    : "select_all".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: _primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Divider(color: Colors.grey.shade200),

                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: pondList.length,
                        itemBuilder: (_, i) {
                          final pond = pondList[i];
                          final id = pond.id ?? "";
                          final isChecked = tempSelected.contains(id);

                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: _primary,
                            contentPadding: EdgeInsets.zero,
                            title: CustomText(
                              textName: pond.name ?? "Unnamed Pond",
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: AppColors.blackColor,
                              fontSize: 13,
                            ),
                            onChanged: (v) {
                              setSheetState(() {
                                if (v == true) {
                                  tempSelected.add(id);
                                } else {
                                  tempSelected.remove(id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedPonds
                              ..clear()
                              ..addAll(
                                pondList.where(
                                  (p) => tempSelected.contains(p.id ?? ""),
                                ),
                              );
                          });
                          Navigator.of(ctx).pop();
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
                          textName:
                              "${"done".tr} (${tempSelected.length} ${"selected".tr})",
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.semiBold,
                          textColor: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children:
            _roles.map((role) {
              final isSelected = _selectedRole == role;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = role;
                      if (role != "staff") {
                        _selectedPonds.clear();
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? _primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomText(
                        textName: _roleLabel(role),
                        fontFamily: FontFamily.poppins,
                        fontWeightType:
                            isSelected
                                ? FontWeightType.semiBold
                                : FontWeightType.regular,
                        textColor:
                            isSelected ? Colors.white : Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  String _getRoleDescription() {
    switch (_selectedRole) {
      case "staff":
        return "role_desc_staff".tr;
      case "manager":
        return "role_desc_manager".tr;
      case "coowner":
        return "role_desc_coowner".tr;
      default:
        return "";
    }
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
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
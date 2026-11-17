import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/staff/staff_tank_model.dart';
import 'package:superapp/services/profileService.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_tank_controller.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _joinDateController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = "staff";

  final List<Datum> _selectedPonds = [];

  DateTime? _pickedJoinDate;

  final _tankservice = Get.find<TankService>();
  final _staffController = Get.find<StaffController>();

  late final StaffTankController _staffTankController;
  late final ProfileController _profileController;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _joinDateController.dispose();
    _salaryController.dispose();
    _aadhaarController.dispose();
    _advanceController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedJoinDate ?? DateTime.now(),
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
        _pickedJoinDate = picked;
        _joinDateController.text = "${picked.year}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  String _formatDateForApi(DateTime? dt) {
    if (dt == null) return "";
    return "${dt.year.toString().padLeft(4, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_full_name".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_email".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_selectedRole == "staff" && _selectedPonds.isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_assign_pond".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final List<String>? tankIdValue =
        (_selectedRole == "staff" && _selectedPonds.isNotEmpty)
            ? _selectedPonds
                .map((p) => p.id ?? "")
                .where((id) => id.isNotEmpty)
                .toList()
            : null;

    debugPrint("Selected tankIds: $tankIdValue");

    await _tankservice.userAddstaff(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      joiningDate: _formatDateForApi(_pickedJoinDate),
      monthlySalary: _salaryController.text.trim(),
      adharNumber: _aadhaarController.text.trim(),
      advanceSalary: _advanceController.text.trim(),
      role: _selectedRole,
      tankId: tankIdValue,
      password: _passwordController.text.trim(),
    );
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
                    textName: "add_staff".tr,
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

            // ---------- Scrollable Form ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("full_name".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: "",
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("email".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hint: "",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      textName: "email_invite_note".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("password".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hint: "",
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("phone_number".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      hint: "",
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("joining_date_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _joinDateController,
                      hint: "dd_mm_yyyy".tr,
                      readOnly: true,
                      onTap: _pickJoinDate,
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("monthly_salary_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _salaryController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      prefixText: "₹ ",
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("aadhaar_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _aadhaarController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(12),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("advance_given_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _advanceController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      prefixText: "₹ ",
                    ),
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 20),

                    // ✅ Assign Ponds — ONLY for staff role
                    if (_selectedRole == "staff") ...[
                      _buildLabel("assign_ponds".tr),
                      const SizedBox(height: 8),
                      _buildPondMultiSelect(),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: CustomText(
                          textName: "send_invite".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.semiBold,
                          textColor: Colors.white,
                          fontSize: 14,
                        ),
                      ),
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

  Widget _buildPondMultiSelect() {
    return Obx(() {
      final response = _staffTankController.stafftankDataResponce.value;
      final pondList = response.data ?? [];

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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
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
          horizontal: 16,
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
      ),
    );
  }
}
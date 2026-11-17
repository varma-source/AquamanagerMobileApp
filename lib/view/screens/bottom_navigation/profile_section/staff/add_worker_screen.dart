import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_controller.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _joinDateController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();

  final _tankservice = Get.find<TankService>();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _joinDateController.dispose();
    _salaryController.dispose();
    _aadhaarController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  // 🔄 Clear all fields
  void _clearAllFields() {
    _nameController.clear();
    _phoneController.clear();
    _joinDateController.clear();
    _salaryController.clear();
    _aadhaarController.clear();
    _advanceController.clear();
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        _joinDateController.text =
            "${picked.year}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveWorker() async {
    if (_isSaving) return;

    // Basic validation
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_full_name".tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // ✅ Await the API — loader closes inside the API
      await _tankservice.useraddworker(
        name: _nameController.text.trim(),
        joiningDate: _joinDateController.text,
        monthlySalary: _salaryController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
        advanceAlreadyGiven: _advanceController.text.trim(),
      );

      // ✅ Clear fields BEFORE popping so reopening shows a fresh form
      _clearAllFields();

      // ✅ Close the bottom sheet AFTER API completes
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      // ✅ Refresh worker list in place on StaffDetails
      if (Get.isRegistered<WorkerController>()) {
        Get.find<WorkerController>().fetchworkerdata();
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"failed_to_add_worker".tr}: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Drag Handle ----------
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

                // ---------- Title ----------
                CustomText(
                  textName: "add_worker".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 16,
                ),
                const SizedBox(height: 20),

                // ---------- Full Name ----------
                _buildLabel("full_name".tr),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _nameController,
                  hint: "",
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                // ---------- Phone Number ----------
                _buildLabel("phone_optional".tr),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _phoneController,
                  hint: "",
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- Joining Date ----------
                _buildLabel("joining_date_optional".tr),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _joinDateController,
                  hint: "dd_mm_yyyy".tr,
                  readOnly: true,
                  onTap: _pickJoinDate,
                  suffixIcon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),

                // ---------- Monthly Salary ----------
                _buildLabel("monthly_salary_optional".tr),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _salaryController,
                  hint: "",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // ---------- Aadhaar Number ----------
                _buildLabel("aadhaar_optional".tr),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _aadhaarController,
                  hint: "",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(12),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- Advance Already Given ----------
                _buildLabel("advance_given_optional".tr),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _advanceController,
                  hint: "",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 26),

                // ---------- Save Button ----------
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveWorker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _primary.withOpacity(0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
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
        suffixIcon: suffixIcon != null
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
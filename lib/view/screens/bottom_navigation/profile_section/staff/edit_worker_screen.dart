import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/staff/worker_model.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_controller.dart';

class EditWorkerScreen extends StatefulWidget {
  final Datum worker;

  const EditWorkerScreen({super.key, required this.worker});

  @override
  State<EditWorkerScreen> createState() => _EditWorkerScreenState();
}

class _EditWorkerScreenState extends State<EditWorkerScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);

  final _tankService = Get.find<TankService>();
  final _formKey = GlobalKey<FormState>();

  // ---------- Controllers ----------
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _monthlySalaryController =
      TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _advanceAlreadyGivenController =
      TextEditingController();

  DateTime? _pickedJoiningDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final w = widget.worker;

    debugPrint("🐛 Prefill worker — joiningDate: ${w.joiningDate}");

    _nameController.text = w.name ?? "";
    _phoneController.text = w.phone ?? "";
    _monthlySalaryController.text = w.monthlySalary ?? "";
    _aadhaarController.text = w.aadhaarNumber ?? "";
    _advanceAlreadyGivenController.text = w.advanceAlreadyGiven ?? "";

    if (w.joiningDate != null) {
      _pickedJoiningDate = w.joiningDate;
      _joiningDateController.text = _formatDateForDisplay(w.joiningDate!);
      debugPrint("✅ Joined date prefilled: ${_joiningDateController.text}");
    } else {
      debugPrint("⚠️ Worker has no joiningDate — field left empty");
    }
  }

  String _formatDateForDisplay(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _joiningDateController.dispose();
    _monthlySalaryController.dispose();
    _aadhaarController.dispose();
    _advanceAlreadyGivenController.dispose();
    super.dispose();
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _pickedJoiningDate ?? widget.worker.joiningDate ?? DateTime.now(),
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
        _pickedJoiningDate = picked;
        _joiningDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  // Future<void> _save() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (_isSaving) return;

  //   setState(() => _isSaving = true);

  //   try {
  //     await _tankService.usereditworker(
  //       workerId: widget.worker.id ?? "",
  //       name: _nameController.text.trim(),
  //       phone: _phoneController.text.trim(),
  //       joiningDate: _joiningDateController.text.trim(),
  //       monthlySalary: _monthlySalaryController.text.trim(),
  //       aadhaarNumber: _aadhaarController.text.trim(),
  //       advanceAlreadyGiven: _advanceAlreadyGivenController.text.trim(),
  //     );
  //   } catch (e) {
  //     debugPrint("Edit worker error: $e");
  //   } finally {
  //     if (mounted) setState(() => _isSaving = false);
  //   }
  // }
  Future<void> _saveWorker() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
       _tankService.usereditworker(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        joiningDate: _joiningDateController.text,
        monthlySalary: _monthlySalaryController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
        advanceAlreadyGiven: _advanceAlreadyGivenController.text.trim(),
        workerId: widget.worker.id ?? "",
      );

      // ✅ Refresh the worker list in place
      if (Get.isRegistered<WorkerController>()) {
        Get.find<WorkerController>().fetchworkerdata();
      }

      // ✅ Pop the edit screen/sheet — stay on StaffDetails
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      } else {
        Get.back(); // if it's a normal screen pushed via Get.to
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"failed_to_update_worker".tr}: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                    textName: "edit_worker".tr,
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
                      // Full Name
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

                      // Phone
                      _buildLabel("phone".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        readOnly: true,
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

                      // Joining Date
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

                      // Monthly Salary
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

                      // Aadhaar Number
                      _buildLabel("aadhaar_number".tr),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _aadhaarController,
                        hint: "enter_aadhaar".tr,
                        icon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(12),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Advance Already Given
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
                      const SizedBox(height: 26),

                      // Save
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveWorker,
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

                      // Cancel
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/services/overview_Service.dart';

class AddStockingScreen extends StatefulWidget {
  final String farmId;
  final String tankId;
  const AddStockingScreen({
    super.key,
    required this.tankId,
    required this.farmId,
  });

  @override
  State<AddStockingScreen> createState() => _AddStockingScreenState();
}

class _AddStockingScreenState extends State<AddStockingScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _avgWeightController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  double _totalCost = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = "select_date".tr;

    _quantityController.addListener(_calculateTotal);
    _costController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final cost = double.tryParse(_costController.text) ?? 0;
    setState(() => _totalCost = qty * cost);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _speciesController.dispose();
    _cropController.dispose();
    _quantityController.dispose();
    _avgWeightController.dispose();
    _costController.dispose();
    _supplierController.dispose();
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

  final _overviewservice = Get.find<OverviewService>();

  // 🔄 Reset form to its initial state (used after successful save)
  void _resetForm() {
    _dateController.text = "select_date".tr;
    _speciesController.clear();
    _cropController.clear();
    _quantityController.clear();
    _avgWeightController.clear();
    _costController.clear();
    _supplierController.clear();
    _notesController.clear();
    setState(() => _totalCost = 0);
  }

  Future<void> _saveStocking() async {
    if (_isSaving) return;

    // Basic validation
    if (_speciesController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_species_name".tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (_quantityController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_quantity".tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _overviewservice.useraddstock(
        tankId: widget.tankId,
        date: _dateController.text == "select_date".tr
            ? ""
            : _dateController.text,
        speciesName: _speciesController.text.trim(),
        cropName: _cropController.text.trim(),
        quantityStocked: _quantityController.text.trim(),
        averageWeightAtStocking: _avgWeightController.text.trim(),
        stockingCostPerUnit: _costController.text.trim(),
        supplier: _supplierController.text.trim(),
        notes: _notesController.text.trim(),
        totalAmount: _totalCost.toString(),
        farmId: widget.farmId,
      );

      // ✅ Reset form and stay on the same screen
      _resetForm();
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"failed_save_stocking".tr}: $e",
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
                    textName: "add_stocking_details".tr,
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
                    // ---------- Stocking Date ----------
                    _buildLabel("stocking_date".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _dateController,
                      hint: "select_date".tr,
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Species Name ----------
                    _buildLabel("species_name".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _speciesController,
                      hint: "species_name_hint".tr,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Crop Name ----------
                    _buildLabel("crop_name_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _cropController, hint: ""),
                    const SizedBox(height: 6),
                    CustomText(
                      textName: "crop_name_helper".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Quantity Stocked ----------
                    _buildLabel("quantity_stocked".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _quantityController,
                      hint: "",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      textName: "pieces_count".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Average Weight ----------
                    _buildLabel("avg_weight_at_stocking".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _avgWeightController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      suffixText: "grams".tr,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Stocking Cost per Unit ----------
                    _buildLabel("stocking_cost_per_unit".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _costController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      prefixText: "₹ ",
                    ),
                    const SizedBox(height: 20),

                    // ---------- Total Stocking Cost ----------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            textName: "total_stocking_cost".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            textName: "₹${_totalCost.toStringAsFixed(0)}",
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.bold,
                            textColor: _primary,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---------- Source / Supplier ----------
                    _buildLabel("source_supplier_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _supplierController, hint: ""),
                    const SizedBox(height: 20),

                    // ---------- Notes ----------
                    _buildLabel("notes_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _notesController,
                      hint: "",
                      maxLines: 4,
                    ),
                    const SizedBox(height: 30),

                    // ---------- Save Stocking ----------
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveStocking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _primary.withOpacity(0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                                textName: "save_stocking".tr,
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

  // ---------- Label ----------
  Widget _buildLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.semiBold,
      textColor: AppColors.blackColor,
      fontSize: 12,
    );
  }

  // ---------- Text Field ----------
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    String? suffixText,
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
        suffixText: suffixText,
        suffixStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        prefixText: prefixText,
        prefixStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        suffixIcon: suffixIcon != null
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
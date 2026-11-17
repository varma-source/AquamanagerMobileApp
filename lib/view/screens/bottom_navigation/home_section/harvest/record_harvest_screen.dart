import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/services/overview_Service.dart';

class RecordHarvestScreen extends StatefulWidget {
  final String farmId;
  final String tankId;
  const RecordHarvestScreen({
    super.key,
    required this.tankId,
    required this.farmId,
  });

  @override
  State<RecordHarvestScreen> createState() => _RecordHarvestScreenState();
}

class _RecordHarvestScreenState extends State<RecordHarvestScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _avgSizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _buyerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedType = "final"; // Partial or Final
  double _totalAmount = 0;
  bool _isSaving = false;

  // 🌐 Harvest type label — display only
  String _typeLabel(String internal) {
    switch (internal) {
      case "partial":
        return "partial".tr;
      case "final":
        return "final_label".tr;
      default:
        return internal;
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = "select_date".tr;

    // Auto-calculate total
    _qtyController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    setState(() => _totalAmount = qty * price);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _qtyController.dispose();
    _avgSizeController.dispose();
    _priceController.dispose();
    _buyerController.dispose();
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
    _qtyController.clear();
    _avgSizeController.clear();
    _priceController.clear();
    _buyerController.clear();
    _notesController.clear();
    setState(() {
      _selectedType = "final";
      _totalAmount = 0;
    });
  }

  Future<void> _saveHarvest() async {
    if (_isSaving) return;

    // Basic validation
    if (_qtyController.text.trim().isEmpty) {
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
      await _overviewservice.useraddharvest(
        tankId: widget.tankId,
        date: _dateController.text == "select_date".tr
            ? ""
            : _dateController.text,
        harvestType: _selectedType,
        quantityHarvested: _qtyController.text,
        averageSizeAtHarvest: _avgSizeController.text,
        totalAmount: _totalAmount.toString(),
        marketName: _buyerController.text,
        notes: _notesController.text,
        farmId: widget.farmId,
      );

      // ✅ Reset form, stay on same screen
      _resetForm();
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"failed_save_harvest".tr}: $e",
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
                    textName: "record_harvest".tr,
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
                    // ---------- Harvest Date ----------
                    _buildLabel("harvest_date".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _dateController,
                      hint: "select_date".tr,
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Harvest Type Toggle ----------
                    _buildLabel("harvest_type".tr),
                    const SizedBox(height: 10),
                    _buildTypeToggle(),

                    // Helper text below toggle
                    if (_selectedType == "final") ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F6F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomText(
                          textName: "final_harvest_hint".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: Colors.grey.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ---------- Quantity Harvested ----------
                    _buildLabel("quantity_harvested".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _qtyController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      suffixText: "kg",
                    ),
                    const SizedBox(height: 20),

                    // ---------- Average Size at Harvest ----------
                    _buildLabel("avg_size_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _avgSizeController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      suffixText: "grams".tr,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Selling Price per Kg ----------
                    _buildLabel("selling_price_per_kg".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _priceController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      prefixText: "₹ ",
                    ),
                    const SizedBox(height: 20),

                    // ---------- Total Sale Amount ----------
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
                            textName: "total_sale_amount".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            textName: "₹${_totalAmount.toStringAsFixed(0)}",
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.bold,
                            textColor: _primary,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---------- Buyer / Market Name ----------
                    _buildLabel("buyer_market_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _buyerController, hint: ""),
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

                    // ---------- Save Harvest ----------
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveHarvest,
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
                                textName: "save_harvest".tr,
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

  // ---------- Type Toggle ----------
  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [_buildToggleItem("partial"), _buildToggleItem("final")],
      ),
    );
  }

  Widget _buildToggleItem(String label) {
    final isSelected = _selectedType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: CustomText(
              textName: _typeLabel(label),
              fontFamily: FontFamily.poppins,
              fontWeightType: isSelected
                  ? FontWeightType.semiBold
                  : FontWeightType.regular,
              textColor:
                  isSelected ? AppColors.blackColor : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
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
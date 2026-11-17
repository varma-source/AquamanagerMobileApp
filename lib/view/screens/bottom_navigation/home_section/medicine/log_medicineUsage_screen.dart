import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/medicine_data_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_useage_controller.dart';

class LogMedicineUsageScreen extends StatefulWidget {
  final String farmId;
  final String tankId;
  const LogMedicineUsageScreen({
    super.key,
    required this.tankId,
    required this.farmId,
  });

  @override
  State<LogMedicineUsageScreen> createState() =>
      _LogMedicineUsageScreenState();
}

class _LogMedicineUsageScreenState extends State<LogMedicineUsageScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _usedController = TextEditingController();

  // ✅ Selected medicine (Datum from API)
  Datum? _selectedMedicine;

  bool _isSaving = false;

  // Controllers
  late final MedicineController _medicineController;
  late final MedicineUseageController _medicineUsageController;

  @override
  void initState() {
    super.initState();
    _dateController.text = "select_date".tr;

    if (Get.isRegistered<MedicineController>()) {
      _medicineController = Get.find<MedicineController>();
    } else {
      _medicineController = Get.put(MedicineController(OverviewService()));
    }
    _medicineController.fetchmedicinedata(
      tankId: widget.tankId,
      farmId: widget.farmId,
    );

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
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    _usedController.dispose();
    super.dispose();
  }

  // ---------- Helpers ----------
  double _toDouble(String? v) => double.tryParse((v ?? "").trim()) ?? 0.0;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  bool _isDateSelected() {
    final t = _dateController.text.trim();
    return t.isNotEmpty && DateTime.tryParse(t) != null;
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _primary,
      colorText: Colors.white,
    );
  }

  /// Available = total purchased (same medicine name) − total already used.
  double _availableFor(Datum? med) {
    if (med == null) return 0.0;
    final name = (med.medicineName ?? "").trim().toLowerCase();

    double purchased = 0;
    final purchases = _medicineController.medicineDataResponce.value.data ?? [];
    for (final m in purchases) {
      if ((m.medicineName ?? "").trim().toLowerCase() == name) {
        purchased += _toDouble(m.quantityPurchased);
      }
    }

    double used = 0;
    final usages =
        _medicineUsageController.medicineuseDataResponce.value.data ?? [];
    for (final u in usages) {
      if ((u.medicineName ?? "").trim().toLowerCase() == name) {
        used += _toDouble(u.quanTityUsed);
      }
    }

    final left = purchased - used;
    return left < 0 ? 0.0 : left;
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
        _dateController.text = "${picked.year}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  final _overviewservice = Get.find<OverviewService>();

  // ---------- Save usage ----------
  Future<void> _saveUsage() async {
    if (_isSaving) return;

    if (_selectedMedicine == null) {
      _snack("required".tr, "please_select_medicine".tr);
      return;
    }
    if (!_isDateSelected()) {
      _snack("required".tr, "please_select_date".tr);
      return;
    }

    final used = double.tryParse(_usedController.text.trim());
    if (used == null || used <= 0) {
      _snack("required".tr, "please_enter_valid_qty".tr);
      return;
    }

    // ✅ Stock check — API is NOT hit when used qty is above available
    final available = _availableFor(_selectedMedicine);
    if (used > available) {
      _snack(
        "not_enough_stock".tr,
        "${"only_available_prefix".tr} ${_fmt(available)} ${"units".tr} ${"available_suffix".tr} "
            "${_selectedMedicine?.medicineName ?? "this_medicine".tr}. "
            "${"enter_less_prefix".tr} ${_fmt(available)} ${"or_less".tr}.",
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _overviewservice.usermedicineusage(
        medicineId: _selectedMedicine?.id ?? "",
        tankId: widget.tankId,
        date: _dateController.text == "select_date".tr
            ? ""
            : _dateController.text,
        quanTityUsed: _usedController.text.trim(),
        notes: _notesController.text,
        farmId: widget.farmId,
      );

      // 🔄 Refresh usage + purchases so available quantity updates in place
      _medicineUsageController.fetchmedicineuseagedata(
        tankId: widget.tankId,
        farmId: widget.farmId,
      );
      _medicineController.fetchmedicinedata(
        tankId: widget.tankId,
        farmId: widget.farmId,
      );

      // ✅ Reset form and STAY on the same screen
      _dateController.text = "select_date".tr;
      _usedController.clear();
      _notesController.clear();
      setState(() {
        _selectedMedicine = null;
      });
    } catch (e) {
      _snack("failed".tr, "could_not_save_usage".tr);
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
                    textName: "log_medicine_usage".tr,
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
                    // ---------- Date ----------
                    _buildLabel("date".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _dateController,
                      hint: "select_date".tr,
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Medicine Dropdown (API) ----------
                    _buildLabel("medicine".tr),
                    const SizedBox(height: 8),
                    _buildMedicineDropdown(),
                    const SizedBox(height: 20),

                    // ---------- Quantity Available (auto-filled) ----------
                    _buildLabel("quantity_available".tr),
                    const SizedBox(height: 8),
                    _buildQuantityField(),
                    const SizedBox(height: 6),
                    CustomText(
                      textName: "auto_filled_note".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                    const SizedBox(height: 20),

                    // ---------- Quantity Used (user enters) ----------
                    _buildLabel("quantity_used".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _usedController,
                      hint: "enter_quantity_used".tr,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 6),
                    _buildAvailableHint(),
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

                    // ---------- Save Usage ----------
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveUsage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _primary.withOpacity(0.5),
                          disabledForegroundColor: Colors.white,
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
                                textName: "save_usage".tr,
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

  // ---------- Available stock hint ----------
  Widget _buildAvailableHint() {
    return Obx(() {
      _medicineController.medicineDataResponce.value;
      _medicineUsageController.medicineuseDataResponce.value;

      if (_selectedMedicine == null) {
        return CustomText(
          textName: "select_medicine_to_see_stock".tr,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.grey.shade500,
          fontSize: 10,
        );
      }

      final available = _availableFor(_selectedMedicine);
      final rawText = _usedController.text.trim();
      final double? entered =
          rawText.isEmpty ? null : double.tryParse(rawText);

      // No user input yet — neutral message
      if (entered == null || entered <= 0) {
        return CustomText(
          textName: "${"available_stock_prefix".tr} ${_fmt(available)} ${"units".tr}",
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: Colors.grey.shade600,
          fontSize: 10,
        );
      }

      // Red warning only when typed quantity exceeds stock
      final exceeded = entered > available;

      return CustomText(
        textName: exceeded
            ? "${"only_available_prefix".tr} ${_fmt(available)} ${"units".tr} ${"available_suffix".tr} — ${"enter_less_prefix".tr} ${_fmt(available)} ${"or_less".tr}"
            : "${"available_stock_prefix".tr} ${_fmt(available)} ${"units".tr}",
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.regular,
        textColor: exceeded ? Colors.red : Colors.grey.shade600,
        fontSize: 10,
      );
    });
  }

  // ---------- Medicine dropdown ----------
  Widget _buildMedicineDropdown() {
    return Obx(() {
      final response = _medicineController.medicineDataResponce.value;

      if (response.data == null) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 10),
              CustomText(
                textName: "loading_medicines".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade500,
                fontSize: 13,
              ),
            ],
          ),
        );
      }

      final medicines = response.data ?? [];

      if (medicines.isEmpty) {
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
              textName: "no_medicines_available".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        );
      }

      Datum? safeValue;
      if (_selectedMedicine != null) {
        for (final m in medicines) {
          if (m.id == _selectedMedicine!.id) {
            safeValue = m;
            break;
          }
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Datum>(
            value: safeValue,
            isExpanded: true,
            hint: CustomText(
              textName: "select_medicine".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 13,
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            items: medicines.map((med) {
              return DropdownMenuItem<Datum>(
                value: med,
                child: CustomText(
                  textName: med.medicineName ?? "",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: AppColors.blackColor,
                  fontSize: 13,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMedicine = value;
                _usedController.clear();
              });
            },
          ),
        ),
      );
    });
  }

  // ---------- Quantity Available (auto-filled, read-only) ----------
  Widget _buildQuantityField() {
    return Obx(() {
      _medicineController.medicineDataResponce.value;
      _medicineUsageController.medicineuseDataResponce.value;

      final available =
          _selectedMedicine == null
              ? null
              : _availableFor(_selectedMedicine);

      final text =
          available == null ? "—" : "${_fmt(available)} ${"units".tr}";

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F6F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: CustomText(
          textName: text,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor:
              available == null
                  ? Colors.grey.shade500
                  : AppColors.blackColor,
          fontSize: 14,
        ),
      );
    });
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
    ValueChanged<String>? onChanged,
    IconData? suffixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      maxLines: maxLines,
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
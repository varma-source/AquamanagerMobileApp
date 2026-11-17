import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/staff_module/staff_medicine_drop_model.dart';
import 'package:superapp/services/manager_module_service.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/view_model/api_controllers/over_view/medicine_useage_controller.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_medicine_drop_controller.dart';

class ManagerLogMedicineUse extends StatefulWidget {
  final String tankId;
  final String farmId;
  const ManagerLogMedicineUse({
    super.key,
    required this.farmId,
    required this.tankId,
  });

  @override
  State<ManagerLogMedicineUse> createState() => _ManagerLogMedicineUseState();
}

class _ManagerLogMedicineUseState extends State<ManagerLogMedicineUse> {
  // ✅ Safely-initialized services
  late final StaffMedicineDropController _staffmedicinedrController;
  late final ManagerModuleService _managermoduleService;

  // ✅ Usage controller to know how much has already been used
  late final MedicineUseageController _medicineUsageController;

  // 🎨 Colors
  final Color _bgColor = const Color(0xFFF3F4F6);
  final Color _textDark = const Color(0xFF1F2937);
  final Color _textGrey = const Color(0xFF6B7280);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _buttonColor = const Color(0xFF7B9CB3);
  final Color _errorColor = const Color(0xFFEF4444);

  // Controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State
  Datum? _selectedMedicineObj;
  String? _qtyError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // ✅ SAFE REGISTRATION for staff medicines dropdown
    if (Get.isRegistered<StaffMedicineDropController>()) {
      _staffmedicinedrController = Get.find<StaffMedicineDropController>();
    } else {
      _staffmedicinedrController = Get.put(
        StaffMedicineDropController(Get.find()),
      );
    }

    // ✅ SAFE REGISTRATION for manager module service
    if (Get.isRegistered<ManagerModuleService>()) {
      _managermoduleService = Get.find<ManagerModuleService>();
    } else {
      _managermoduleService = Get.put(ManagerModuleService());
    }

    // ✅ Register / reuse MedicineUseageController
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

    // ✅ Set default date to today in yyyy-MM-dd format
    final now = DateTime.now();
    _dateController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // ✅ Fetch medicines
    _staffmedicinedrController.fetchstaffmedicinedropdata(
      farmId: widget.farmId,
      tankId: widget.tankId,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _toDouble(String? v) => double.tryParse((v ?? "").trim()) ?? 0.0;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  double _usedQtyFor(Datum med) {
    final usages =
        _medicineUsageController.medicineuseDataResponce.value.data ?? [];
    final targetId = med.id ?? "";
    final targetName = (med.medicineName ?? "").trim().toLowerCase();

    double used = 0;
    for (final u in usages) {
      if ((u.tankId ?? "") != widget.tankId) continue;

      final sameId = targetId.isNotEmpty && u.medicineId == targetId;
      final sameName =
          (u.medicineName ?? "").trim().toLowerCase() == targetName;

      if (sameId || sameName) {
        used += _toDouble(u.quanTityUsed);
      }
    }
    return used;
  }

  double _availableFor(Datum med) {
    final purchased = _toDouble(med.quantityPurchased);
    final used = _usedQtyFor(med);
    final left = purchased - used;
    return left < 0 ? 0.0 : left;
  }

  // Future<void> _validateAndSubmit() async {
  //   setState(() {
  //     _qtyError = null;
  //     _isSubmitting = true;
  //   });

  //   if (_selectedMedicineObj == null) {
  //     Get.snackbar(
  //       "required".tr,
  //       "please_select_medicine".tr,
  //       backgroundColor: Colors.orange,
  //       colorText: Colors.white,
  //     );
  //     setState(() => _isSubmitting = false);
  //     return;
  //   }

  //   if (_qtyController.text.isEmpty) {
  //     setState(() {
  //       _qtyError = "please_enter_quantity".tr;
  //       _isSubmitting = false;
  //     });
  //     return;
  //   }

  //   final double enteredQty = double.tryParse(_qtyController.text) ?? 0;
  //   final double availableQty = _availableFor(_selectedMedicineObj!);

  //   if (enteredQty > availableQty) {
  //     setState(() {
  //       _qtyError =
  //           "${"cannot_exceed_available".tr} (${_fmt(availableQty)})";
  //       _isSubmitting = false;
  //     });
  //     return;
  //   }

  //   if (enteredQty <= 0) {
  //     setState(() {
  //       _qtyError = "quantity_greater".tr;
  //       _isSubmitting = false;
  //     });
  //     return;
  //   }

  //   try {
  //     await _managermoduleService.usermanagerlogmedicineadd(
  //       date: _dateController.text,
  //       medicineId: _selectedMedicineObj!.id ?? "",
  //       tankId: widget.tankId,
  //       farmId: widget.farmId,
  //       quanTityUsed: _qtyController.text,
  //       notes: _notesController.text,
  //     );

  //     _medicineUsageController.fetchmedicineuseagedata(
  //       tankId: widget.tankId,
  //       farmId: widget.farmId,
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       "error".tr,
  //       "${"failed_save_medicine".tr}: $e",
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isSubmitting = false);
  //   }
  // }
  Future<void> _validateAndSubmit() async {
    setState(() {
      _qtyError = null;
      _isSubmitting = true;
    });

    if (_selectedMedicineObj == null) {
      Get.snackbar(
        "required".tr,
        "please_select_medicine".tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      setState(() => _isSubmitting = false);
      return;
    }

    if (_qtyController.text.isEmpty) {
      setState(() {
        _qtyError = "please_enter_quantity".tr;
        _isSubmitting = false;
      });
      return;
    }

    final double enteredQty = double.tryParse(_qtyController.text) ?? 0;
    final double availableQty = _availableFor(_selectedMedicineObj!);

    if (enteredQty > availableQty) {
      setState(() {
        _qtyError = "${"cannot_exceed_available".tr} (${_fmt(availableQty)})";
        _isSubmitting = false;
      });
      return;
    }

    if (enteredQty <= 0) {
      setState(() {
        _qtyError = "quantity_greater".tr;
        _isSubmitting = false;
      });
      return;
    }

    try {
      // ✅ Await the API — loader closed inside the API
      await _managermoduleService.usermanagerlogmedicineadd(
        date: _dateController.text,
        medicineId: _selectedMedicineObj!.id ?? "",
        tankId: widget.tankId,
        farmId: widget.farmId,
        quanTityUsed: _qtyController.text,
        notes: _notesController.text,
      );

      // ✅ Clear the form and stay on the same screen
      _qtyController.clear();
      _notesController.clear();
      setState(() {
        _selectedMedicineObj = null;
        _qtyError = null;
      });

      // 🔄 Refresh available quantities so dropdown updates
      _medicineUsageController.fetchmedicineuseagedata(
        tankId: widget.tankId,
        farmId: widget.farmId,
      );
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"failed_save_medicine".tr}: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: CustomText(
          textName: "log_medicine_usage".tr,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: const Color(0xFF1E3A5F),
          fontSize: 16,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- DATE ----------
            _buildLabel("date".tr),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Colors.black87,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _buttonColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------- MEDICINE DROPDOWN ----------
            _buildLabel("medicine".tr),
            const SizedBox(height: 8),
            Obx(() {
              _medicineUsageController.medicineuseDataResponce.value;

              final response =
                  _staffmedicinedrController.staffmedicinedrDataResponce.value;
              final medicines = response.data ?? [];

              if (medicines.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor),
                  ),
                  child: CustomText(
                    textName: "no_medicines".tr,
                    fontFamily: FontFamily.poppins,
                    textColor: _textGrey,
                    fontSize: 14,
                  ),
                );
              }

              if (_selectedMedicineObj != null &&
                  !medicines.any((m) => m.id == _selectedMedicineObj!.id)) {
                _selectedMedicineObj = null;
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Datum>(
                    value: _selectedMedicineObj,
                    isExpanded: true,
                    hint: CustomText(
                      textName: "select_medicine".tr,
                      fontFamily: FontFamily.poppins,
                      textColor: _textGrey,
                      fontSize: 14,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black87,
                    ),
                    items:
                        medicines.map((med) {
                          final available = _availableFor(med);
                          return DropdownMenuItem<Datum>(
                            value: med,
                            child: CustomText(
                              textName:
                                  "${med.medicineName ?? 'Unknown'} (${_fmt(available)} ${"available".tr})",
                              fontFamily: FontFamily.poppins,
                              textColor: _textDark,
                              fontSize: 14,
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedMedicineObj = val;
                        _qtyError = null;
                      });
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // ---------- QUANTITY USED ----------
            _buildLabel("quantity_used_units".tr),
            const SizedBox(height: 8),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14),
              onChanged: (val) {
                if (_qtyError != null) {
                  setState(() => _qtyError = null);
                } else {
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _qtyError != null ? _errorColor : _borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _qtyError != null ? _errorColor : _borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _qtyError != null ? _errorColor : _buttonColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Obx(() {
              _medicineUsageController.medicineuseDataResponce.value;

              if (_qtyError != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: CustomText(
                    textName: _qtyError!,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: _errorColor,
                    fontSize: 12,
                  ),
                );
              }
              if (_selectedMedicineObj == null) return const SizedBox.shrink();

              final available = _availableFor(_selectedMedicineObj!);
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: CustomText(
                  textName:
                      "${"available_colon".tr} ${_fmt(available)} ${"units".tr}",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: _textGrey,
                  fontSize: 12,
                ),
              );
            }),
            const SizedBox(height: 20),

            // ---------- NOTES ----------
            _buildLabel("notes_optional".tr),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 5,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _buttonColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ---------- SAVE BUTTON ----------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF087FC1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: const Color(
                    0xFF087FC1,
                  ).withOpacity(0.5),
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
                          textName: "save_usage".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.semiBold,
                          textColor: Colors.white,
                          fontSize: 15,
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
      textColor: const Color(0xFF374151),
      fontSize: 13,
    );
  }
}

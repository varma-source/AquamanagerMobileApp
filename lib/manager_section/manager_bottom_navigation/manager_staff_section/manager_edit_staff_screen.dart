import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/staff_module/staff_home_model.dart' as home_model;
import 'package:superapp/model/staff_module/staff_manager_staff_model.dart';
import 'package:superapp/services/manager_module_service.dart';
import 'package:superapp/services/staff_module_service.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_home_controller.dart';

class ManagerEditStaffScreen extends StatefulWidget {
  final Datum staff;

  const ManagerEditStaffScreen({super.key, required this.staff});

  @override
  State<ManagerEditStaffScreen> createState() => _ManagerEditStaffScreenState();
}

class _ManagerEditStaffScreenState extends State<ManagerEditStaffScreen> {
  // 🎨 Colors matching add screen
  final Color _bgColor = const Color(0xFFF3F4F6);
  final Color _primaryDark = const Color(0xFF1E3A5F);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _textDark = const Color(0xFF1F2937);
  final Color _textGrey = const Color(0xFF6B7280);
  final Color _disabledBg = const Color(0xFFE5E7EB);

  // ✅ Controllers
  late final StaffHomeController _homeController;
  late final ManagerModuleService _managermoduleService;

  bool _isSubmitting = false;

  // Controllers (no password — edit API doesn't accept it)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // ✅ Multi-select state for tanks
  final List<home_model.Datum> _selectedTanks = [];
  bool _hasPreSelectedTanks = false;

  @override
  void initState() {
    super.initState();

    // Register Home Controller safely
    if (Get.isRegistered<StaffHomeController>()) {
      _homeController = Get.find<StaffHomeController>();
    } else {
      _homeController = Get.put(StaffHomeController(StaffModuleService()));
    }

    // Register Manager Service safely
    if (Get.isRegistered<ManagerModuleService>()) {
      _managermoduleService = Get.find<ManagerModuleService>();
    } else {
      _managermoduleService = Get.put(ManagerModuleService());
    }

    // ✅ Pre-fill data
    _nameController.text = widget.staff.name ?? "";
    _emailController.text = widget.staff.email ?? "";
    _phoneController.text = widget.staff.phone ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitStaff() async {
    // Basic Validation
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_full_name".tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Extract tank IDs from the selected tanks
      final List<String> tankIds = _selectedTanks
          .map((t) => t.id ?? "")
          .where((id) => id.isNotEmpty)
          .toList();

      // ✅ Same pattern as add screen — await, no navigation here.
      // Loader is closed inside the API with plain Get.back().
      await _managermoduleService.usermanagerEditStaff(
        staffId: widget.staff.id ?? "",
        name: _nameController.text.trim(),
        role: widget.staff.role ?? "staff",
        tankId: tankIds,
      );

      // ✅ Stay on the same screen (success toast shown inside API)
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"failed_to_update_staff".tr}: $e",
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
          textName: "edit_staff".tr,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: _primaryDark,
          fontSize: 16,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- FULL NAME ----------
            _buildLabel("full_name".tr),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 14),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),

            // ---------- EMAIL (read only) ----------
            _buildLabel("email".tr),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              style: TextStyle(fontSize: 14, color: _textGrey),
              decoration: _inputDecoration().copyWith(fillColor: _disabledBg),
            ),
            const SizedBox(height: 16),

            // ---------- PHONE (read only) ----------
            _buildLabel("phone_optional".tr),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              readOnly: true,
              style: TextStyle(fontSize: 14, color: _textGrey),
              decoration: _inputDecoration().copyWith(fillColor: _disabledBg),
            ),
            const SizedBox(height: 16),

            // ---------- ROLE (disabled) ----------
            _buildLabel("role".tr),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              controller: TextEditingController(text: "staff".tr),
              style: TextStyle(fontSize: 14, color: _textGrey),
              decoration: _inputDecoration().copyWith(
                fillColor: _disabledBg,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            const SizedBox(height: 6),
            CustomText(
              textName: "role_desc".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: _textGrey,
              fontSize: 11,
            ),
            const SizedBox(height: 16),

            // ---------- ASSIGN PONDS (MULTI-SELECT) ----------
            _buildLabel("assign_ponds".tr),
            const SizedBox(height: 8),
            _buildPondMultiSelect(),

            const SizedBox(height: 30),

            // ---------- UPDATE STAFF BUTTON ----------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitStaff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: _primaryDark.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : CustomText(
                        textName: "update_staff".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.semiBold,
                        textColor: Colors.white,
                        fontSize: 15,
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ MULTI-SELECT PONDS WIDGET
  // ═══════════════════════════════════════════════════════════
  Widget _buildPondMultiSelect() {
    return Obx(() {
      final response = _homeController.staffprofileDataResponce.value;
      final tanks = response.data ?? [];

      // Loading state
      if (tanks.isEmpty) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
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

      // ✅ Pre-select the staff's currently assigned tanks (only once)
      if (!_hasPreSelectedTanks) {
        final staffTankIds = (widget.staff.tankId ?? [])
            .map((e) => e.toString())
            .toSet();
        _selectedTanks
          ..clear()
          ..addAll(tanks.where((t) => staffTankIds.contains(t.id)));
        _hasPreSelectedTanks = true;
      }

      // Clean up selected tanks if they no longer exist
      _selectedTanks.removeWhere((sel) => !tanks.any((t) => t.id == sel.id));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Tappable field ----
          InkWell(
            onTap: () => _openTankPicker(tanks),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _selectedTanks.isEmpty
                        ? CustomText(
                            textName: "select_ponds".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: _textGrey,
                            fontSize: 14,
                          )
                        : CustomText(
                            textName:
                                "${_selectedTanks.length} ${"ponds_selected".tr}",
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: _textDark,
                            fontSize: 14,
                          ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),

          // ---- Chips of selected tanks ----
          if (_selectedTanks.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTanks.map((tank) {
                return Chip(
                  label: CustomText(
                    textName: tank.tankName ?? "Unnamed",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: _textDark,
                    fontSize: 12,
                  ),
                  backgroundColor: const Color(0xFFE6F2F9),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _selectedTanks.removeWhere((t) => t.id == tank.id);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: _primaryDark.withOpacity(0.3)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ BOTTOM SHEET FOR SELECTION
  // ═══════════════════════════════════════════════════════════
  void _openTankPicker(List<home_model.Datum> tanks) {
    final Set<String> tempSelected = _selectedTanks
        .map((t) => t.id ?? "")
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
                    // Header
                    Row(
                      children: [
                        CustomText(
                          textName: "select_ponds".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.bold,
                          textColor: _primaryDark,
                          fontSize: 15,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              if (tempSelected.length == tanks.length) {
                                tempSelected.clear();
                              } else {
                                tempSelected
                                  ..clear()
                                  ..addAll(
                                    tanks
                                        .map((t) => t.id ?? "")
                                        .where((id) => id.isNotEmpty),
                                  );
                              }
                            });
                          },
                          child: CustomText(
                            textName: tempSelected.length == tanks.length
                                ? "clear_all".tr
                                : "select_all".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: _primaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Divider(color: _borderColor),

                    // List
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tanks.length,
                        itemBuilder: (_, i) {
                          final tank = tanks[i];
                          final id = tank.id ?? "";
                          final isChecked = tempSelected.contains(id);

                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: _primaryDark,
                            contentPadding: EdgeInsets.zero,
                            title: CustomText(
                              textName: tank.tankName ?? "Unnamed Pond",
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: _textDark,
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

                    // Done button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedTanks
                              ..clear()
                              ..addAll(
                                tanks.where(
                                  (t) => tempSelected.contains(t.id ?? ""),
                                ),
                              );
                          });
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
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

  // ---------- Helpers ----------
  Widget _buildLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.medium,
      textColor: _textDark,
      fontSize: 13,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryDark, width: 1.5),
      ),
    );
  }
}
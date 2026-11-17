import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_images.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/tank/all_tank_model.dart';
import 'package:superapp/model/tank/tank_staff_model.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view_model/api_controllers/tank/tank_staff_controller.dart';

class EditTankScreen extends StatefulWidget {
  final Tank tank;

  const EditTankScreen({super.key, required this.tank});

  @override
  State<EditTankScreen> createState() => _EditTankScreenState();
}

class _EditTankScreenState extends State<EditTankScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);
  final Color _primaryDark = const Color(0xFF005A9C);

  final _tankService = Get.find<TankService>();

  // ✅ Tank staff controller — registered safely
  late final TankStaffController _staffController;

  // ---------- Controllers ----------
  final TextEditingController _tankNameController = TextEditingController();
  final TextEditingController _pondSizeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedType = "fish";

  // ✅ Status Toggle State
  String _selectedStatus = "active";
  final List<String> _statusOptions = ["active", "inactive", "harvest"];

  // ✅ Multi-select Staff State (uses TankStaff model's Staff)
  final List<Staff> _selectedStaffList = [];
  bool _hasPreSelectedStaff = false;

  // ---------- Location ----------
  double? _latitude;
  double? _longitude;
  bool _isFetchingLocation = false;
  bool _isSaving = false;

  // ✅ Prefill pending staff ids
  List<String> _pendingStaffIds = [];

  // 🌐 Type label — display only
  String _typeLabel(String internal) {
    switch (internal) {
      case "fish":
        return "fish".tr;
      case "prawn":
        return "prawn".tr;
      default:
        return internal;
    }
  }

  // 🌐 Status label — display only
  String _statusLabel(String internal) {
    switch (internal) {
      case "active":
        return "active".tr;
      case "inactive":
        return "inactive".tr;
      case "harvest":
        return "harvest".tr;
      default:
        return internal;
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ Register or reuse TankStaffController
    if (Get.isRegistered<TankStaffController>()) {
      _staffController = Get.find<TankStaffController>();
    } else {
      _staffController = Get.put(TankStaffController(TankService()));
    }

    // Ensure tank staff data is loaded
    if (_staffController.tankstaffDataResponce.value.staffs == null) {
      _staffController.fetchtankstaffdata();
    }

    _prefill();
  }

  void _prefill() {
    final t = widget.tank;

    _tankNameController.text = t.name ?? "";
    _pondSizeController.text = t.pondSize ?? "";
    _addressController.text = t.address ?? "";

    final typeLower = (t.tankType ?? "").toLowerCase().trim();
    if (typeLower == "fish" || typeLower == "prawn") {
      _selectedType = typeLower;
    }

    final statusLower = (t.status ?? "active").toLowerCase().trim();
    if (_statusOptions.contains(statusLower)) {
      _selectedStatus = statusLower;
    }

    _pendingStaffIds = t.staffId ?? [];

    if (t.location?.coordinates != null &&
        t.location!.coordinates!.isNotEmpty) {
      final polygon = t.location!.coordinates!.first;
      if (polygon.isNotEmpty) {
        double latSum = 0;
        double lngSum = 0;
        for (final point in polygon) {
          if (point.length >= 2) {
            lngSum += point[0];
            latSum += point[1];
          }
        }
        _longitude = lngSum / polygon.length;
        _latitude = latSum / polygon.length;
      }
    }
  }

  @override
  void dispose() {
    _tankNameController.dispose();
    _pondSizeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ---------- Fetch current location ----------
  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack(
          "location_disabled".tr,
          "enable_location_services".tr,
        );
        setState(() => _isFetchingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack(
          "permission_denied".tr,
          "location_permission_for_tank".tr,
        );
        setState(() => _isFetchingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isFetchingLocation = false;
      });
    } catch (e) {
      setState(() => _isFetchingLocation = false);
      _showSnack("error".tr, "${"could_not_fetch_location".tr}: $e");
    }
  }

  void _showSnack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _primary,
      colorText: Colors.white,
    );
  }

  // ---------- Build polygon JSON from lat/lng ----------
  String _buildLocationJson() {
    final lat = _latitude ?? 17.4483;
    final lng = _longitude ?? 78.4010;
    final d = 0.01;

    return json.encode({
      "type": "Polygon",
      "coordinates": [
        [
          [lng - d, lat + d],
          [lng + d, lat + d],
          [lng + d, lat - d],
          [lng - d, lat - d],
          [lng - d, lat + d],
        ],
      ],
    });
  }

  // ---------- Save ----------
  Future<void> _saveTank() async {
    if (_tankNameController.text.trim().isEmpty) {
      _showSnack("required".tr, "please_enter_tank_name".tr);
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final List<String> staffIds =
          _selectedStaffList
              .map((s) => s.id ?? "")
              .where((id) => id.isNotEmpty)
              .toList();

      debugPrint(
        "🛠️ Editing tank — staffIds: $staffIds, status: $_selectedStatus",
      );

      await _tankService.userEditTank(
        tankId: widget.tank.id ?? "",
        name: _tankNameController.text.trim(),
        tankType: _selectedType,
        pondSize: _pondSizeController.text.trim(),
        address: _addressController.text.trim(),
        locationJson: _buildLocationJson(),
        staffIds: staffIds,
        status: _selectedStatus,
      );

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Get.back();
    } catch (e) {
      debugPrint("Edit tank error: $e");
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    textName: "edit_tank".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: AppColors.blackColor,
                    fontSize: 16,
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
                    // Tank Name
                    _buildLabel("tank_name".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _tankNameController,
                      hint: "tank_name_hint".tr,
                    ),
                    const SizedBox(height: 22),

                    // Tank Type Toggle
                    _buildLabel("tank_type".tr),
                    const SizedBox(height: 10),
                    _buildTypeToggle(),
                    const SizedBox(height: 18),

                    // Preview Card
                    _buildPreviewCard(),
                    const SizedBox(height: 22),

                    // Pond Size
                    _buildLabel("pond_size".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _pondSizeController,
                      hint: "pond_size_hint".tr,
                    ),
                    const SizedBox(height: 22),

                    // Address
                    _buildLabel("address".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _addressController,
                      hint: "address_hint".tr,
                    ),
                    const SizedBox(height: 22),

                    // Current Location (auto-fetched)
                    _buildLabel("current_location".tr),
                    const SizedBox(height: 8),
                    _buildLocationCard(),
                    const SizedBox(height: 22),

                    // ✅ Assign Staff (MULTI-SELECT)
                    _buildLabel("assign_staff".tr),
                    const SizedBox(height: 8),
                    _buildStaffMultiSelect(),
                    const SizedBox(height: 22),

                    // ✅ Status Toggle
                    _buildLabel("status".tr),
                    const SizedBox(height: 10),
                    _buildStatusToggle(),

                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveTank,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _primaryDark.withOpacity(
                            0.5,
                          ),
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
                                  textName: "save_tank".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.semiBold,
                                  textColor: Colors.white,
                                  fontSize: 15,
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // Add your delete tank logic here
                      },
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF56C6C),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            CustomText(
                              textName: "delete_tank".tr,
                              fontFamily: FontFamily.poppins,
                              fontSize: 14,
                              textColor: AppColors.whiteColor,
                              fontWeightType: FontWeightType.semiBold,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ✅ MULTI-SELECT STAFF WIDGET (uses TankStaffData)
  // ═══════════════════════════════════════════════════
  Widget _buildStaffMultiSelect() {
    return Obx(() {
      final response = _staffController.tankstaffDataResponce.value;
      final staffList = response.staffs ?? [];

      final assignableStaff =
          staffList
              .where((s) => (s.role ?? "").toLowerCase() != "worker")
              .toList();

      if (assignableStaff.isEmpty) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: CustomText(
              textName: "no_staff_available".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.regular,
              textColor: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        );
      }

      if (!_hasPreSelectedStaff) {
        _selectedStaffList.addAll(
          assignableStaff.where((s) => _pendingStaffIds.contains(s.id)),
        );
        _hasPreSelectedStaff = true;
      }

      final validIds = assignableStaff.map((s) => s.id ?? "").toSet();
      final cleaned = _selectedStaffList
          .where((s) => validIds.contains(s.id ?? ""))
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openStaffPicker(assignableStaff),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        cleaned.isEmpty
                            ? CustomText(
                              textName: "select_staff".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: Colors.grey.shade400,
                              fontSize: 13,
                            )
                            : CustomText(
                              textName:
                                  "${cleaned.length} ${"staff_selected".tr}",
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: AppColors.blackColor,
                              fontSize: 14,
                            ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),

          if (cleaned.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  cleaned.map((staff) {
                    return Chip(
                      label: CustomText(
                        textName: staff.name ?? "unknown".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: AppColors.blackColor,
                        fontSize: 12,
                      ),
                      backgroundColor: const Color(0xFFE6F2F9),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedStaffList.removeWhere(
                            (s) => s.id == staff.id,
                          );
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

  // ═══════════════════════════════════════════════════
  // ✅ BOTTOM SHEET FOR STAFF SELECTION
  // ═══════════════════════════════════════════════════
  void _openStaffPicker(List<Staff> staffList) {
    final Set<String> tempSelected =
        _selectedStaffList
            .map((s) => s.id ?? "")
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
                          textName: "select_staff".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.bold,
                          textColor: _primaryDark,
                          fontSize: 15,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              if (tempSelected.length == staffList.length) {
                                tempSelected.clear();
                              } else {
                                tempSelected
                                  ..clear()
                                  ..addAll(
                                    staffList
                                        .map((s) => s.id ?? "")
                                        .where((id) => id.isNotEmpty),
                                  );
                              }
                            });
                          },
                          child: CustomText(
                            textName:
                                tempSelected.length == staffList.length
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
                    Divider(color: Colors.grey.shade200),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: staffList.length,
                        itemBuilder: (_, i) {
                          final staff = staffList[i];
                          final id = staff.id ?? "";
                          final isChecked = tempSelected.contains(id);

                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: _primaryDark,
                            contentPadding: EdgeInsets.zero,
                            title: CustomText(
                              textName: staff.name ?? "unknown".tr,
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
                            _selectedStaffList
                              ..clear()
                              ..addAll(
                                staffList.where(
                                  (s) => tempSelected.contains(s.id ?? ""),
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

  // ---------- STATUS TOGGLE ----------
  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children:
            _statusOptions.map((status) {
              final isSelected = _selectedStatus == status;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStatus = status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: CustomText(
                        textName: _statusLabel(status),
                        fontFamily: FontFamily.poppins,
                        fontWeightType:
                            isSelected
                                ? FontWeightType.semiBold
                                : FontWeightType.regular,
                        textColor:
                            isSelected ? _primaryDark : Colors.grey.shade600,
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

  // ---------- Location Card ----------
  Widget _buildLocationCard() {
    return GestureDetector(
      onTap: _isFetchingLocation ? null : _fetchLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.my_location, size: 18, color: _primary),
            const SizedBox(width: 10),
            Expanded(
              child:
                  _isFetchingLocation
                      ? CustomText(
                        textName: "fetching_location".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade600,
                        fontSize: 12,
                      )
                      : CustomText(
                        textName:
                            (_latitude != null && _longitude != null)
                                ? "Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}"
                                : "tap_to_fetch_location".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor:
                            (_latitude != null)
                                ? AppColors.blackColor
                                : Colors.grey.shade500,
                        fontSize: 12,
                      ),
            ),
            if (_isFetchingLocation)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.refresh, color: Colors.grey.shade400, size: 18),
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
      fontSize: 13,
    );
  }

  // ---------- Text Field ----------
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary, width: 1.6),
        ),
      ),
    );
  }

  // ---------- Type Toggle ----------
  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [_buildToggleItem("fish"), _buildToggleItem("prawn")],
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
            borderRadius: BorderRadius.circular(10),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
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
              fontWeightType:
                  isSelected ? FontWeightType.semiBold : FontWeightType.regular,
              textColor:
                  isSelected ? AppColors.blackColor : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Preview Card ----------
  Widget _buildPreviewCard() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2196F3), _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.25),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              _selectedType == "fish"
                  ? Image.asset(
                    AppImages.fishimage,
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.set_meal,
                          color: Colors.white,
                          size: 60,
                        ),
                  )
                  : Image.asset(
                    AppImages.prawnimage,
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.set_meal,
                          color: Colors.white,
                          size: 60,
                        ),
                  ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/party_model.dart';
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/view/screens/bottom_navigation/intentory/parties_screen.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_controller.dart';

class AddMedicinePurchaseScreen extends StatefulWidget {
  final String farmId;
  final String tankId;
  const AddMedicinePurchaseScreen({
    super.key,
    required this.tankId,
    required this.farmId,
  });

  @override
  State<AddMedicinePurchaseScreen> createState() =>
      _AddMedicinePurchaseScreenState();
}

class _AddMedicinePurchaseScreenState extends State<AddMedicinePurchaseScreen> {
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _invoiceController = TextEditingController();

  Datum? _selectedParty;

  String _selectedPayment = "cash";
  String _selectedMedicineType = "litres";
  final List<String> _medicineTypes = ["litres", "units", "kgs"];

  double _totalAmount = 0;
  bool _isSaving = false;

  final List<String> _paymentMethods = [
    "cash",
    "banktransfer",
    "upi",
    "credit",
  ];

  late final PartyController _partyController;

  // 🌐 Medicine type label — display only
  String _medicineTypeLabel(String internal) {
    switch (internal) {
      case "litres":
        return "litres".tr;
      case "kgs":
        return "kg".tr;
      case "units":
        return "units".tr;
      default:
        return internal;
    }
  }

  // 🌐 Payment method label — display only
  String _paymentMethodLabel(String internal) {
    switch (internal) {
      case "cash":
        return "cash".tr;
      case "banktransfer":
        return "bank_transfer".tr;
      case "upi":
        return "upi".tr;
      case "credit":
        return "credit".tr;
      default:
        return internal;
    }
  }

  String get _priceLabelText {
    switch (_selectedMedicineType) {
      case "litres":
        return "price_per_litre".tr;
      case "kgs":
        return "price_per_kg".tr;
      case "units":
      default:
        return "price_per_unit".tr;
    }
  }

  String get _quantitySuffixText {
    switch (_selectedMedicineType) {
      case "litres":
        return "litres".tr;
      case "kgs":
        return "kg".tr;
      case "units":
      default:
        return "units".tr;
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = "select_date".tr;
    _qtyController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);

    if (Get.isRegistered<PartyController>()) {
      _partyController = Get.find<PartyController>();
    } else {
      _partyController = Get.put(PartyController(OverviewService()));
    }
  }

  void _calculateTotal() {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    setState(() => _totalAmount = qty * price);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _medicineController.dispose();
    _brandController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _invoiceController.dispose();
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
    _medicineController.clear();
    _brandController.clear();
    _qtyController.clear();
    _priceController.clear();
    _supplierController.clear();
    _invoiceController.clear();
    setState(() {
      _selectedParty = null;
      _selectedPayment = "cash";
      _selectedMedicineType = "litres";
      _totalAmount = 0;
    });
  }

  Future<void> _savePurchase() async {
    if (_isSaving) return;

    // Basic validation
    if (_medicineController.text.trim().isEmpty) {
      Get.snackbar(
        "required".tr,
        "please_enter_medicine_name".tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
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
      final String? partyIdValue =
          (_selectedParty != null && (_selectedParty!.id ?? "").isNotEmpty)
              ? _selectedParty!.id
              : null;

      await _overviewservice.useraddmedicine(
        partyId: partyIdValue,
        tankId: widget.tankId,
        purchaseDate: _dateController.text == "select_date".tr
            ? ""
            : _dateController.text,
        medicineName: _medicineController.text.trim(),
        brand: _brandController.text.trim(),
        quantityPurchased: _qtyController.text.trim(),
        pricePerUnits: _priceController.text.trim(),
        totalAmount: _totalAmount.toString(),
        invoiceReference: _invoiceController.text.trim(),
        paidBy: _selectedPayment,
        medicineType: _selectedMedicineType,
        farmId: widget.farmId,
      );

      // ✅ Reset form and stay on same screen
      _resetForm();
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"failed_save_medicine".tr}: $e",
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
                    textName: "add_medicine_purchase".tr,
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("purchase_date".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _dateController,
                      hint: "select_date".tr,
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("medicine_chemical_name".tr),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _medicineController, hint: ""),
                    const SizedBox(height: 20),

                    _buildLabel("brand_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _brandController, hint: ""),
                    const SizedBox(height: 20),

                    _buildLabel("quantity_purchased".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _qtyController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      suffixText: _quantitySuffixText,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("medicine_type".tr),
                    const SizedBox(height: 8),
                    _buildMedicineTypeDropdown(),
                    const SizedBox(height: 20),

                    _buildLabel(_priceLabelText),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _priceController,
                      hint: "",
                      keyboardType: TextInputType.number,
                      prefixText: "₹ ",
                    ),
                    const SizedBox(height: 20),

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
                            textName: "total_amount".tr,
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

                    _buildLabel("party_optional".tr),
                    const SizedBox(height: 8),
                    _buildPartyDropdown(),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CustomText(
                          textName: "party_link_hint".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: Colors.grey.shade500,
                          fontSize: 7,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(PartiesScreen());
                          },
                          child: CustomText(
                            textName: "manage_parties".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: _primary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (_selectedParty == null) ...[
                      _buildLabel("supplier_name_optional".tr),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _supplierController,
                        hint: "",
                      ),
                      const SizedBox(height: 20),
                    ],

                    _buildLabel("invoice_reference_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _invoiceController, hint: ""),
                    const SizedBox(height: 20),

                    _buildLabel("payment_method".tr),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPayment,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade700,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          items: _paymentMethods.map((method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: CustomText(
                                textName: _paymentMethodLabel(method),
                                fontFamily: FontFamily.poppins,
                                fontWeightType: FontWeightType.regular,
                                textColor: AppColors.blackColor,
                                fontSize: 13,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPayment = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      textName: "medicine_stock_note".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _savePurchase,
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
                                textName: "save_purchase".tr,
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

  Widget _buildMedicineTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMedicineType,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          items: _medicineTypes.map((t) {
            return DropdownMenuItem<String>(
              value: t,
              child: CustomText(
                textName: _medicineTypeLabel(t),
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: AppColors.blackColor,
                fontSize: 13,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedMedicineType = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPartyDropdown() {
    return Obx(() {
      final response = _partyController.partyDataResponce.value;

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
                textName: "loading_parties".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey.shade500,
                fontSize: 13,
              ),
            ],
          ),
        );
      }

      final parties = response.data ?? [];

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Datum?>(
            value: _selectedParty,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            items: [
              DropdownMenuItem<Datum?>(
                value: null,
                child: CustomText(
                  textName: "no_party".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: AppColors.blackColor,
                  fontSize: 13,
                ),
              ),
              ...parties.map((party) {
                return DropdownMenuItem<Datum?>(
                  value: party,
                  child: CustomText(
                    textName: party.name ?? "",
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: AppColors.blackColor,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedParty = value;
                if (value != null) {
                  _supplierController.clear();
                }
              });
            },
          ),
        ),
      );
    });
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
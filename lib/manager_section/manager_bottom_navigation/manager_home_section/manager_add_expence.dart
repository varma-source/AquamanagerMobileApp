import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/services/manager_module_service.dart';

class ManagerAddExpence extends StatefulWidget {
  final String tankId;
  final String farmId;
  const ManagerAddExpence({
    super.key,
    required this.farmId,
    required this.tankId,
  });

  @override
  State<ManagerAddExpence> createState() => _ManagerAddExpenceState();
}

class _ManagerAddExpenceState extends State<ManagerAddExpence> {
  final _expenseService = ManagerModuleService();

  final Color _primary = const Color(0xFF087FC1);
  final Color _bgColor = const Color(0xFFF3F5F7);
  final Color _textDark = const Color(0xFF334155);
  final Color _textGrey = const Color(0xFF64748B);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();
  final TextEditingController _chargesController = TextEditingController();
  final TextEditingController _extrasController = TextEditingController();

  final List<Map<String, TextEditingController>> _salaryPeople = [
    {
      "person": TextEditingController(),
      "joiningDate": TextEditingController(),
      "salary": TextEditingController(),
    },
  ];

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _pricePerQtyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedUnit = "Kgs";
  final List<String> _units = ["Pieces", "Meters", "Kgs"];

  String _selectedCategory = "Labour";
  File? _receiptImage; // ✅ OPTIONAL
  bool _isSubmitting = false;
  double _totalCost = 0;

  final List<String> _categories = [
    "Labour",
    "Salary",
    "Tiffins/Meals",
    "Petrol",
    "Diesel",
    "Electrical",
    "Plumbing",
    "Transport",
    "Utilities",
    "Other",
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _dateController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    _personsController.addListener(_calculateTotal);
    _chargesController.addListener(_calculateTotal);
    _extrasController.addListener(_calculateTotal);
    _qtyController.addListener(_calculateTotal);
    _pricePerQtyController.addListener(_calculateTotal);
    _amountController.addListener(_calculateTotal);

    for (final p in _salaryPeople) {
      p["salary"]?.addListener(_calculateTotal);
    }
  }

  void _calculateTotal() {
    double total = 0;
    switch (_selectedCategory) {
      case "Labour":
        final persons = double.tryParse(_personsController.text) ?? 0;
        final charges = double.tryParse(_chargesController.text) ?? 0;
        final extras = double.tryParse(_extrasController.text) ?? 0;
        total = (persons * charges) + extras;
        break;
      case "Salary":
        for (final p in _salaryPeople) {
          total += double.tryParse(p["salary"]?.text ?? "0") ?? 0;
        }
        break;
      case "Electrical":
      case "Plumbing":
        final qty = double.tryParse(_qtyController.text) ?? 0;
        final price = double.tryParse(_pricePerQtyController.text) ?? 0;
        total = qty * price;
        break;
      case "Tiffins/Meals":
      case "Petrol":
      case "Diesel":
      case "Transport":
      case "Utilities":
      case "Other":
        total = double.tryParse(_amountController.text) ?? 0;
        break;
    }
    if (mounted) setState(() => _totalCost = total);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    _personsController.dispose();
    _chargesController.dispose();
    _extrasController.dispose();
    _itemNameController.dispose();
    _qtyController.dispose();
    _pricePerQtyController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    for (final p in _salaryPeople) {
      p["person"]?.dispose();
      p["joiningDate"]?.dispose();
      p["salary"]?.dispose();
    }
    super.dispose();
  }

  // 🔄 Clear all fields — stay on the same screen
  void _clearAllFields() {
    final now = DateTime.now();
    _dateController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _notesController.clear();
    _personsController.clear();
    _chargesController.clear();
    _extrasController.clear();
    _itemNameController.clear();
    _qtyController.clear();
    _pricePerQtyController.clear();
    _amountController.clear();
    _descriptionController.clear();

    for (final p in _salaryPeople) {
      p["person"]?.clear();
      p["joiningDate"]?.clear();
      p["salary"]?.clear();
    }
    while (_salaryPeople.length > 1) {
      final last = _salaryPeople.removeLast();
      last["person"]?.dispose();
      last["joiningDate"]?.dispose();
      last["salary"]?.dispose();
    }

    setState(() {
      _receiptImage = null;
      _totalCost = 0;
      _selectedUnit = "Kgs";
    });
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
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickReceiptImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (picked != null) {
        setState(() => _receiptImage = File(picked.path));
      }
    } catch (e) {
      Get.snackbar("error".tr, "${"could_not_pick_image".tr}: $e");
    }
  }

  void _onCategoryChanged(String value) {
    setState(() {
      _selectedCategory = value;
      _totalCost = 0;
      _calculateTotal();
    });
  }

  void _addSalaryPerson() {
    setState(() {
      _salaryPeople.add({
        "person": TextEditingController(),
        "joiningDate": TextEditingController(),
        "salary": TextEditingController(),
      });
      _salaryPeople.last["salary"]?.addListener(_calculateTotal);
    });
  }

  void _removeSalaryPerson(int index) {
    if (_salaryPeople.length <= 1) return;
    setState(() {
      _salaryPeople[index]["person"]?.dispose();
      _salaryPeople[index]["joiningDate"]?.dispose();
      _salaryPeople[index]["salary"]?.dispose();
      _salaryPeople.removeAt(index);
      _calculateTotal();
    });
  }

  Future<void> _submitExpense() async {
    if (_totalCost == 0) {
      Get.snackbar(
        "required".tr,
        "please_enter_valid_amount".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // ✅ Image optional — "" when not selected
    final String imagePath = _receiptImage?.path ?? "";

    try {
      switch (_selectedCategory) {
        case "Labour":
          await _expenseService.addmanagerLabour(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            noofpersonsWorked: _personsController.text,
            chargesPerPerson: _chargesController.text,
            Extras: _extrasController.text,
            TotalLabourCost: _totalCost.toStringAsFixed(0),
            Notes: _notesController.text,
            receiptImage: imagePath,
          );
          break;
        case "Salary":
          final List<Map<String, String>> personsArray =
              _salaryPeople.map((p) {
                return {
                  "staffId": "manual_entry_id",
                  "joiningDate": p["joiningDate"]!.text,
                  "salaryAmount": p["salary"]!.text,
                };
              }).toList();

          await _expenseService.addmanagerSalary(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            personsJsonString: json.encode(personsArray),
            TotalSalaries: _totalCost.toStringAsFixed(0),
            notes: _notesController.text,
            receiptImage: imagePath,
          );
          break;
        case "Tiffins/Meals":
          await _expenseService.addmanagerTiffin(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            description: _descriptionController.text,
            amount: _amountController.text,
            receiptImage: imagePath,
          );
          break;
        case "Petrol":
          await _expenseService.addmanagerPetrol(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            category: "Petrol",
            description: _descriptionController.text,
            amount: _amountController.text,
            receiptImage: imagePath,
          );
          break;
        case "Diesel":
          await _expenseService.addmanagerDiesel(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            description: _descriptionController.text,
            amount: _amountController.text,
            receiptImage: imagePath,
          );
          break;
        case "Electrical":
          await _expenseService.addmanagerElectrical(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            itemName: _itemNameController.text,
            unit: _selectedUnit,
            Quantity: _qtyController.text,
            pricePerUnit: _pricePerQtyController.text,
            Total: _totalCost.toStringAsFixed(0),
            Notes: _notesController.text,
            receiptImage: imagePath,
          );
          break;
        case "Plumbing":
          await _expenseService.addmanagerPlumbing(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            itemName: _itemNameController.text,
            quantity: _qtyController.text,
            pricePerQuantity: _pricePerQtyController.text,
            total: _totalCost.toStringAsFixed(0),
            notes: _notesController.text,
            receiptImage: imagePath,
          );
          break;
        case "Transport":
          await _expenseService.addmanagerTransport(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            description: _descriptionController.text,
            Amount: _amountController.text,
            receiptImage: imagePath,
          );
          break;
        case "Utilities":
          await _expenseService.addmanagerUtilities(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            description: _descriptionController.text,
            Amount: _amountController.text,
            receiptImage: imagePath,
          );
          break;
        case "Other":
          await _expenseService.addmanagerOther(
            tankId: widget.tankId,
            farmId: widget.farmId,
            date: _dateController.text,
            description: _descriptionController.text,
            Amount: _amountController.text,
            receiptImage: imagePath,
          );
          break;
      }

      // ✅ Stay on screen — clear everything
      _clearAllFields();
    } catch (e) {
      debugPrint("API Error: $e");
      // success/failure toast already shown by service
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // 🌐 Translated category label
  String _categoryLabel(String cat) {
    switch (cat) {
      case "Labour":
        return "labour".tr;
      case "Salary":
        return "salary".tr;
      case "Tiffins/Meals":
        return "tiffins_meals".tr;
      case "Petrol":
        return "petrol".tr;
      case "Diesel":
        return "diesel".tr;
      case "Electrical":
        return "electrical".tr;
      case "Plumbing":
        return "plumbing".tr;
      case "Transport":
        return "transport".tr;
      case "Utilities":
        return "utilities".tr;
      case "Other":
        return "other".tr;
      default:
        return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
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
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  CustomText(
                    textName: "add_expense".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: _textDark,
                    fontSize: 16,
                  ),
                  const Spacer(),
                  const SizedBox(width: 18),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade300),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("date".tr),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _dateController,
                      hint: "select_date".tr,
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("expense_category".tr),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                          ),
                          items:
                              _categories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: CustomText(
                                    textName: _categoryLabel(cat),
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.regular,
                                    textColor: _textDark,
                                    fontSize: 14,
                                  ),
                                );
                              }).toList(),
                          onChanged: (v) {
                            if (v != null) _onCategoryChanged(v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ..._buildCategoryBody(),
                    const SizedBox(height: 16),

                    _buildLabel("notes_optional".tr),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _notesController,
                      hint: "what_was_this_for".tr,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // ✅ Receipt Photo — Optional
                    _buildLabel("receipt_photo_optional".tr),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickReceiptImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_receiptImage == null)
                              Icon(
                                Icons.photo_camera_outlined,
                                color: Colors.grey.shade500,
                                size: 22,
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _receiptImage!,
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 8),
                            CustomText(
                              textName:
                                  _receiptImage == null
                                      ? "tap_to_add_photo".tr
                                      : "tap_to_change_photo".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF055A8C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                  textName: "submit_expense".tr,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.semiBold,
                                  textColor: Colors.white,
                                  fontSize: 15,
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

  List<Widget> _buildCategoryBody() {
    switch (_selectedCategory) {
      case "Labour":
        return [
          _buildLabel("no_of_persons".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _personsController,
            hint: "",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildLabel("charges_per_person".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _chargesController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 16),
          _buildLabel("extras_optional".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _extrasController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 16),
          _buildTotalBox("total_labour_cost".tr),
          const SizedBox(height: 16),
        ];

      case "Salary":
        return [
          for (int i = 0; i < _salaryPeople.length; i++)
            _buildSalaryPersonCard(i),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _addSalaryPerson,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
              ),
              child: CustomText(
                textName: "add_another_person".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.medium,
                textColor: _textDark,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTotalBox("total_salaries".tr),
          const SizedBox(height: 16),
        ];

      case "Tiffins/Meals":
      case "Petrol":
      case "Diesel":
      case "Transport":
      case "Utilities":
      case "Other":
        return [
          _buildLabel("description".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _descriptionController,
            hint: "what_was_this_for".tr,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildLabel("amount".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _amountController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 16),
        ];

      case "Electrical":
        return [
          _buildLabel("item_name".tr),
          const SizedBox(height: 6),
          _buildTextField(controller: _itemNameController, hint: ""),
          const SizedBox(height: 16),
          _buildLabel("unit".tr),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedUnit,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
                items:
                    _units.map((u) {
                      return DropdownMenuItem<String>(
                        value: u,
                        child: CustomText(
                          textName: u,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: _textDark,
                          fontSize: 14,
                        ),
                      );
                    }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedUnit = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLabel("${"quantity".tr} (${_selectedUnit.toLowerCase()})"),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _qtyController,
            hint: "",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildLabel(
            "${"price_per".tr} ${_selectedUnit.toLowerCase().replaceAll('s', '')}",
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _pricePerQtyController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 16),
          _buildTotalBox("total".tr),
          const SizedBox(height: 16),
        ];

      case "Plumbing":
        return [
          _buildLabel("item_name".tr),
          const SizedBox(height: 6),
          _buildTextField(controller: _itemNameController, hint: ""),
          const SizedBox(height: 16),
          _buildLabel("quantity".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _qtyController,
            hint: "",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildLabel("price_per_quantity".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _pricePerQtyController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 16),
          _buildTotalBox("total".tr),
          const SizedBox(height: 16),
        ];

      default:
        return [];
    }
  }

  Widget _buildSalaryPersonCard(int index) {
    final p = _salaryPeople[index];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  textName: "${"person".tr} ${index + 1}",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.medium,
                  textColor: _textGrey,
                  fontSize: 13,
                ),
              ),
              if (_salaryPeople.length > 1)
                GestureDetector(
                  onTap: () => _removeSalaryPerson(index),
                  child: CustomText(
                    textName: "remove".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: Colors.red.shade400,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel("staff_manager_name".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: p["person"]!,
            hint: "enter_name".tr,
            readOnly: false,
          ),
          const SizedBox(height: 12),
          _buildLabel("joining_date_optional".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: p["joiningDate"]!,
            hint: "yyyy-mm-dd",
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  p["joiningDate"]!.text =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                });
              }
            },
            suffixIcon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 12),
          _buildLabel("salary_amount".tr),
          const SizedBox(height: 6),
          _buildTextField(
            controller: p["salary"]!,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBox(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: title,
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.regular,
            textColor: _textGrey,
            fontSize: 11,
          ),
          const SizedBox(height: 4),
          CustomText(
            textName: "₹${_totalCost.toStringAsFixed(0)}",
            fontFamily: FontFamily.poppins,
            fontWeightType: FontWeightType.bold,
            textColor: const Color(0xFF055A8C),
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.medium,
      textColor: _textDark,
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
        suffixStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixText: prefixText,
        prefixStyle: TextStyle(color: Colors.grey.shade800, fontSize: 14),
        suffixIcon:
            suffixIcon != null
                ? Icon(suffixIcon, size: 18, color: Colors.grey.shade600)
                : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primary, width: 1.6),
        ),
      ),
    );
  }
}

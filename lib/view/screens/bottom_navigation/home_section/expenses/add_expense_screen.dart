import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/model/over_view/party_model.dart';
import 'package:superapp/model/staff/staff_model.dart' as staff;
import 'package:superapp/model/staff/worker_model.dart' as worker;
import 'package:superapp/services/overview_Service.dart';
import 'package:superapp/services/tankService.dart';
import 'package:superapp/view/screens/bottom_navigation/intentory/parties_screen.dart';
import 'package:superapp/view_model/api_controllers/over_view/party_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_controller.dart';

class AddExpenseScreen extends StatefulWidget {
  final String farmId;
  final String tankId;
  const AddExpenseScreen({
    super.key,
    required this.tankId,
    required this.farmId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final Color _primary = const Color(0xFF087FC1);

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final TextEditingController _personsController = TextEditingController();
  final TextEditingController _chargesController = TextEditingController();
  final TextEditingController _extrasController = TextEditingController();

  final List<Map<String, TextEditingController>> _salaryPeople = [
    {
      "person": TextEditingController(),
      "personId": TextEditingController(),
      "joiningDate": TextEditingController(),
      "salary": TextEditingController(),
    },
  ];

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _pricePerQtyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedUnit = "Pieces";
  final List<String> _units = ["Pieces", "Meters", "Kgs"];

  String _selectedCategory = "Labour";
  Datum? _selectedParty;

  File? _receiptImage;

  double _totalCost = 0;

  final List<String> _categories = [
    "Labour",
    "Salary",
    "Tiffins",
    "Petrol",
    "Diesel",
    "Electrical",
    "Plumbing",
    "Transport",
    "Utilities",
    "Other",
  ];

  late final PartyController _partyController;
  late final StaffController _staffController;
  late final WorkerController _workerController;

  // 🌐 Category label — display only
  String _categoryLabel(String internal) {
    switch (internal) {
      case "Labour":
        return "labour_label".tr;
      case "Salary":
        return "salary_label".tr;
      case "Tiffins":
        return "tiffins_label".tr;
      case "Petrol":
        return "petrol_label".tr;
      case "Diesel":
        return "diesel_label".tr;
      case "Electrical":
        return "electrical_label".tr;
      case "Plumbing":
        return "plumbing_label".tr;
      case "Transport":
        return "transport_label".tr;
      case "Utilities":
        return "utilities_label".tr;
      case "Other":
        return "other_label".tr;
      default:
        return internal;
    }
  }

  // 🌐 Person type label — display only
  String _personTypeLabel(String internal) {
    return internal == "Worker" ? "worker".tr : "staff".tr;
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = "select_date".tr;

    _personsController.addListener(_calculateTotal);
    _chargesController.addListener(_calculateTotal);
    _extrasController.addListener(_calculateTotal);
    _qtyController.addListener(_calculateTotal);
    _pricePerQtyController.addListener(_calculateTotal);
    _amountController.addListener(_calculateTotal);

    for (final p in _salaryPeople) {
      p["salary"]?.addListener(_calculateTotal);
    }

    if (Get.isRegistered<PartyController>()) {
      _partyController = Get.find<PartyController>();
    } else {
      _partyController = Get.put(PartyController(OverviewService()));
    }
    _partyController.fetchpartydata();

    if (Get.isRegistered<StaffController>()) {
      _staffController = Get.find<StaffController>();
    } else {
      _staffController = Get.put(StaffController(TankService()));
    }
    _staffController.fetchstaffdata();

    if (Get.isRegistered<WorkerController>()) {
      _workerController = Get.find<WorkerController>();
    } else {
      _workerController = Get.put(WorkerController(TankService()));
    }
    _workerController.fetchworkerdata();
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
      case "Tiffins":
      case "Petrol":
      case "Diesel":
      case "Transport":
      case "Utilities":
      case "Other":
        total = double.tryParse(_amountController.text) ?? 0;
        break;
    }
    setState(() => _totalCost = total);
  }

  final _overviewservice = Get.find<OverviewService>();

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
      p["personId"]?.dispose();
      p["joiningDate"]?.dispose();
      p["salary"]?.dispose();
    }
    super.dispose();
  }

  // 🔄 Clear all fields after success — stays on same screen
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
      p["personId"]?.clear();
      p["joiningDate"]?.clear();
      p["salary"]?.clear();
    }
    while (_salaryPeople.length > 1) {
      final last = _salaryPeople.removeLast();
      last["person"]?.dispose();
      last["personId"]?.dispose();
      last["joiningDate"]?.dispose();
      last["salary"]?.dispose();
    }

    setState(() {
      _receiptImage = null;
      _totalCost = 0;
      _selectedUnit = "Pieces";
      _selectedParty = null;
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
            "${picked.year}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.day.toString().padLeft(2, '0')}";
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
      Get.snackbar(
        "error".tr,
        "${"could_not_pick_image".tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _primary,
        colorText: Colors.white,
      );
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
        "personId": TextEditingController(),
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
      _salaryPeople[index]["personId"]?.dispose();
      _salaryPeople[index]["joiningDate"]?.dispose();
      _salaryPeople[index]["salary"]?.dispose();
      _salaryPeople.removeAt(index);
      _calculateTotal();
    });
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
                    textName: "add_expense".tr,
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

                    _buildLabel("expense_category".tr),
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
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade700,
                          ),
                          items:
                              _categories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: CustomText(
                                    textName: _categoryLabel(cat),
                                    fontFamily: FontFamily.poppins,
                                    fontWeightType: FontWeightType.regular,
                                    textColor: AppColors.blackColor,
                                    fontSize: 13,
                                  ),
                                );
                              }).toList(),
                          onChanged: (v) {
                            if (v != null) _onCategoryChanged(v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ..._buildCategoryBody(),
                    const SizedBox(height: 20),

                    _buildLabel("notes_optional".tr),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _notesController,
                      hint: "what_was_this_for".tr,
                      maxLines: 4,
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

                    GestureDetector(
                      onTap: _pickReceiptImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_receiptImage == null)
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.grey.shade600,
                                size: 20,
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
                                      ? "add_receipt_photo".tr
                                      : "tap_to_change_photo".tr,
                              fontFamily: FontFamily.poppins,
                              fontWeightType: FontWeightType.regular,
                              textColor: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _submitExpense(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: CustomText(
                          textName: "submit_expense".tr,
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

  Future<void> _submitExpense(BuildContext context) async {
    final apiDate = _formatDateForApi(_dateController.text);
    final partyId = _selectedParty?.id ?? "";
    final receiptPath = _receiptImage?.path ?? "";

    try {
      switch (_selectedCategory) {
        case "Labour":
          await _overviewservice.useraddlabourexpense(
            tankId: widget.tankId,
            date: apiDate,
            noofpersonsWorked: _personsController.text.trim(),
            chargesPerPerson: _chargesController.text.trim(),
            Extras: _extrasController.text.trim(),
            TotalLabourCost: _totalCost.toStringAsFixed(0),
            Notes: _notesController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;

        case "Salary":
          final List<Map<String, String>> persons =
              _salaryPeople.map((p) {
                return {
                  "staffId": p["personId"]?.text.trim() ?? "",
                  "joiningDate": _formatDateForApi(
                    p["joiningDate"]?.text ?? "",
                  ),
                  "salaryAmount": p["salary"]?.text.trim() ?? "",
                };
              }).toList();

          await _overviewservice.useraddsalaryexpense(
            tankId: widget.tankId,
            date: apiDate,
            totalLabourCost: _totalCost.toStringAsFixed(0),
            notes: _notesController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            persons: persons,
            farmId: widget.farmId,
          );
          break;

        case "Tiffins":
          await _overviewservice.useraddtiffens(
            tankId: widget.tankId,
            date: apiDate,
            description: _descriptionController.text.trim(),
            amount: _amountController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;

        case "Petrol":
          await _overviewservice.useraddpetrol(
            tankId: widget.tankId,
            date: apiDate,
            category: "Petrol",
            description: _descriptionController.text.trim(),
            amount: _amountController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;

        case "Diesel":
          await _overviewservice.useradddiesel(
            tankId: widget.tankId,
            date: apiDate,
            description: _descriptionController.text.trim(),
            amount: _amountController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;

        case "Electrical":
          await _overviewservice.useraddelectrial(
            tankId: widget.tankId,
            date: apiDate,
            itemName: _itemNameController.text.trim(),
            unit: _selectedUnit,
            Quantity: _qtyController.text.trim(),
            pricePerUnit: _pricePerQtyController.text.trim(),
            Total: _totalCost.toStringAsFixed(0),
            Notes: _notesController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;

        case "Plumbing":
          await _overviewservice.useraddplumbing(
            tankId: widget.tankId,
            date: apiDate,
            itemName: _itemNameController.text.trim(),
            quantity: _qtyController.text.trim(),
            pricePerQuantity: _pricePerQtyController.text.trim(),
            total: _totalCost.toStringAsFixed(0),
            notes: _notesController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;

        case "Transport":
          await _overviewservice.useraddtransport(
            tankId: widget.tankId,
            date: apiDate,
            description: _descriptionController.text.trim(),
            Amount: _amountController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;

        case "Utilities":
          await _overviewservice.useraddutilities(
            tankId: widget.tankId,
            date: apiDate,
            description: _descriptionController.text.trim(),
            Amount: _amountController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;

        case "Other":
          await _overviewservice.useraddother(
            tankId: widget.tankId,
            date: apiDate,
            description: _descriptionController.text.trim(),
            Amount: _amountController.text.trim(),
            partyId: partyId,
            receiptImage: receiptPath,
            farmId: widget.farmId,
          );
          break;
      }

      // ✅ Stay on screen — clear fields
      _clearAllFields();
    } catch (e) {
      debugPrint("Add expense error: $e");
      // success/failure toast already shown by service
    }
  }

  String _formatDateForApi(String yyyymmddSlash) {
    if (yyyymmddSlash.trim().isEmpty ||
        yyyymmddSlash.toLowerCase() == "select date" ||
        yyyymmddSlash.toLowerCase() == "select_date".tr.toLowerCase()) {
      return "";
    }
    return yyyymmddSlash.replaceAll("/", "-");
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
              setState(() => _selectedParty = value);
            },
          ),
        ),
      );
    });
  }

  List<Widget> _buildCategoryBody() {
    switch (_selectedCategory) {
      case "Labour":
        return [
          _buildLabel("no_of_persons".tr),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _personsController,
            hint: "",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildLabel("charges_per_person".tr),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _chargesController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 20),
          _buildLabel("extras_optional".tr),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _extrasController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 20),
          _buildTotalBox("total_labour_cost".tr),
        ];

      case "Salary":
        return [
          for (int i = 0; i < _salaryPeople.length; i++)
            _buildSalaryPersonCard(i),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _addSalaryPerson,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
              ),
              child: CustomText(
                textName: "add_another_person".tr,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.semiBold,
                textColor: AppColors.blackColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTotalBox("total_salaries".tr),
        ];

      case "Tiffins":
      case "Petrol":
      case "Diesel":
      case "Transport":
      case "Utilities":
      case "Other":
        return [
          _buildLabel("description".tr),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _descriptionController,
            hint: "what_was_this_for".tr,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          _buildLabel("amount".tr),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _amountController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
        ];

      case "Electrical":
        return [
          _buildLabel("item_name".tr),
          const SizedBox(height: 8),
          _buildTextField(controller: _itemNameController, hint: ""),
          const SizedBox(height: 20),
          _buildLabel("unit".tr),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedUnit,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade700,
                ),
                items:
                    _units.map((u) {
                      return DropdownMenuItem<String>(
                        value: u,
                        child: CustomText(
                          textName: u,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.regular,
                          textColor: AppColors.blackColor,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedUnit = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel("${"quantity".tr} (${_selectedUnit.toLowerCase()})"),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _qtyController,
            hint: "",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildLabel(
            "${"price_per".tr} ${_selectedUnit.toLowerCase()}",
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _pricePerQtyController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 20),
          _buildTotalBox("total".tr),
        ];

      case "Plumbing":
        return [
          _buildLabel("item_name".tr),
          const SizedBox(height: 8),
          _buildTextField(controller: _itemNameController, hint: ""),
          const SizedBox(height: 20),
          _buildLabel("quantity".tr),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _qtyController,
            hint: "",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildLabel("price_per_quantity".tr),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _pricePerQtyController,
            hint: "",
            keyboardType: TextInputType.number,
            prefixText: "₹ ",
          ),
          const SizedBox(height: 20),
          _buildTotalBox("total".tr),
        ];

      default:
        return [];
    }
  }

  Widget _buildSalaryPersonCard(int index) {
    final p = _salaryPeople[index];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
                  fontWeightType: FontWeightType.semiBold,
                  textColor: AppColors.blackColor,
                  fontSize: 12,
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
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel("staff_manager_worker".tr),
          const SizedBox(height: 8),
          Obx(() {
            final staffResp = _staffController.staffDataResponce.value;
            final workerResp = _workerController.workerDataResponce.value;

            final staffList = staffResp.staffs;
            final workerList = workerResp.data;

            final isLoading = staffList == null && workerList == null;

            if (isLoading) {
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
                      textName: "loading_staff_workers".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ],
                ),
              );
            }

            final List<_PersonOption> options = [
              ...?staffList?.map(
                (s) => _PersonOption(
                  id: s.id ?? "",
                  name: s.name ?? "",
                  type: "Staff",
                ),
              ),
              ...?workerList?.map(
                (w) => _PersonOption(
                  id: w.id ?? "",
                  name: w.name ?? "",
                  type: "Worker",
                ),
              ),
            ];

            if (options.isEmpty) {
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
                    textName: "no_staff_workers_available".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              );
            }

            _PersonOption? selected;
            final storedId = p["personId"]?.text ?? "";
            if (storedId.isNotEmpty) {
              for (final o in options) {
                if (o.id == storedId) {
                  selected = o;
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
                child: DropdownButton<_PersonOption>(
                  value: selected,
                  hint: CustomText(
                    textName: "select_person".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade700,
                  ),
                  items:
                      options.map((o) {
                        return DropdownMenuItem<_PersonOption>(
                          value: o,
                          child: Row(
                            children: [
                              Flexible(
                                child: CustomText(
                                  textName: o.name,
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.regular,
                                  textColor: AppColors.blackColor,
                                  fontSize: 13,
                                  maxLines: 1,
                                  overFlow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      o.type == "Worker"
                                          ? const Color(0xFFF57C00).withOpacity(
                                            0.12,
                                          )
                                          : _primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CustomText(
                                  textName: _personTypeLabel(o.type),
                                  fontFamily: FontFamily.poppins,
                                  fontWeightType: FontWeightType.semiBold,
                                  textColor:
                                      o.type == "Worker"
                                          ? const Color(0xFFF57C00)
                                          : _primary,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        p["person"]?.text = v.name;
                        p["personId"]?.text = v.id;
                      });
                    }
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildLabel("joining_date_optional".tr),
          const SizedBox(height: 8),
          _buildTextField(
            controller: p["joiningDate"]!,
            hint: "dd_mm_yyyy".tr,
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
                      "${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}";
                });
              }
            },
            suffixIcon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 12),
          _buildLabel("salary_amount".tr),
          const SizedBox(height: 8),
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
        color: const Color(0xFFF2F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textName: title,
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
        suffixIcon:
            suffixIcon != null
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

class _PersonOption {
  final String id;
  final String name;
  final String type; // "Staff" or "Worker"
  const _PersonOption({
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PersonOption && other.id == id && other.type == type;

  @override
  int get hashCode => Object.hash(id, type);
}
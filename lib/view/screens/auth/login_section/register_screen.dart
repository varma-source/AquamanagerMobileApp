import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:superapp/services/authService.dart';

// ═══════════════════════════════════════════════════════════════
// SHARED FORM CONTROLLER — holds state across the 2 screens
// ═══════════════════════════════════════════════════════════════
class RegisterFormController extends GetxController {
  // ---- Personal details ----
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// ✅ Optional — null means "no photo picked"
  File? pickedImage;

  // ---- Farm details ----
  final farmNameController = TextEditingController();
  final farmLocationController = TextEditingController();
  double? latitude;
  double? longitude;
  String currency = "₹";

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    farmNameController.dispose();
    farmLocationController.dispose();
    super.onClose();
  }
}

// ═══════════════════════════════════════════════════════════════
// SCREEN 1 — Personal details
// ═══════════════════════════════════════════════════════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final RegisterFormController _form;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _form = Get.isRegistered<RegisterFormController>()
        ? Get.find<RegisterFormController>()
        : Get.put(RegisterFormController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (picked != null) {
        setState(() => _form.pickedImage = File(picked.path));
      }
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "${"could_not_pick_image".tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    }
  }

  // ✅ Continue → validate → next screen (photo optional)
  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    Get.to(() => const FarmSetupScreen());
  }

  void _exitFlow() {
    Get.delete<RegisterFormController>(force: true);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // ---------- Back + Title ----------
                Row(
                  children: [
                    GestureDetector(
                      onTap: _exitFlow,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.blackColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CustomText(
                      textName: "create_account".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      fontSize: 20,
                      textColor: AppColors.blackColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- Step bar ----------
                _buildStepBar(currentStep: 1),
                const SizedBox(height: 20),

                // ---------- Optional Profile Photo ----------
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _form.pickedImage != null
                            ? Image.file(
                                _form.pickedImage!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primaryColor
                                    .withOpacity(0.6),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CustomText(
                  textName: "upload_photo_optional".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.medium,
                  fontSize: 13,
                  textColor: AppColors.greyColor11,
                ),
                const SizedBox(height: 24),

                // ---------- PERSONAL DETAILS CARD ----------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(Icons.person_outline, "full_name".tr),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _form.nameController,
                        hint: "enter_full_name".tr,
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? "please_enter_name".tr
                                : null,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel(Icons.email_outlined, "email_address".tr),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _form.emailController,
                        hint: "enter_email".tr,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "please_enter_email".tr;
                          }
                          if (!GetUtils.isEmail(v.trim())) {
                            return "enter_valid_email".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildLabel(Icons.phone_outlined, "phone_number".tr),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _form.phoneController,
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
                      const SizedBox(height: 20),

                      _buildLabel(Icons.location_on_outlined, "address".tr),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _form.addressController,
                        hint: "enter_address".tr,
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 2,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? "please_enter_address".tr
                                : null,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel(Icons.lock_outline, "password".tr),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        controller: _form.passwordController,
                        hint: "enter_password".tr,
                        isVisible: _isPasswordVisible,
                        onToggleVisibility: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "please_enter_password".tr;
                          }
                          if (v.length < 6) {
                            return "password_min_6".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildLabel(Icons.lock_reset, "confirm_password".tr),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        controller: _form.confirmPasswordController,
                        hint: "reenter_password".tr,
                        isVisible: _isConfirmPasswordVisible,
                        onToggleVisibility: () => setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "please_confirm_password".tr;
                          }
                          if (v != _form.passwordController.text) {
                            return "passwords_do_not_match".tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------- Continue ----------
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          textName: "continue_btn".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.semiBold,
                          textColor: AppColors.whiteColor,
                          fontSize: 14,
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Login redirect ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      textName: "already_have_account".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    GestureDetector(
                      onTap: _exitFlow,
                      child: CustomText(
                        textName: "login".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: AppColors.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Step bar ----------
  Widget _buildStepBar({required int currentStep}) {
    return Row(
      children: [
        _stepDot(number: 1, label: "personal_step".tr, isActive: currentStep >= 1),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color:
                currentStep >= 2
                    ? AppColors.primaryColor
                    : Colors.grey.shade300,
          ),
        ),
        _stepDot(number: 2, label: "farm_step".tr, isActive: currentStep >= 2),
      ],
    );
  }

  Widget _stepDot({
    required int number,
    required String label,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryColor : Colors.grey.shade300,
          ),
          child: Center(
            child: CustomText(
              textName: "$number",
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.bold,
              textColor: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        CustomText(
          textName: label,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: isActive ? AppColors.primaryColor : Colors.grey.shade500,
          fontSize: 10,
        ),
      ],
    );
  }

  Widget _buildLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        CustomText(
          textName: text,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.semiBold,
          textColor: AppColors.blackColor,
          fontSize: 13,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      style: TextStyle(fontSize: 16, color: Colors.grey.shade900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.grey.shade500,
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade500,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}


class FarmSetupScreen extends StatefulWidget {
  const FarmSetupScreen({super.key});

  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final RegisterFormController _form;

  bool _termsAccepted = false;
  bool _isFetchingLocation = false;

  String _selectedCurrency = "₹";
  final List<String> _currencies = ["₹", "\$", "€"];

  final _authservice = Get.find<Authservice>();

  @override
  void initState() {
    super.initState();
    _form = Get.isRegistered<RegisterFormController>()
        ? Get.find<RegisterFormController>()
        : Get.put(RegisterFormController());
    _selectedCurrency = _form.currency;
  }

  // ---------- Fetch location ----------
  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          "location_disabled".tr,
          "enable_location_services".tr,
          snackPosition: SnackPosition.BOTTOM,
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
        Get.snackbar(
          "permission_denied".tr,
          "location_permission_for_farm".tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _isFetchingLocation = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _form.latitude = position.latitude;
        _form.longitude = position.longitude;
        _isFetchingLocation = false;
      });

      Get.snackbar(
        "location_fetched".tr,
        "Lat: ${_form.latitude!.toStringAsFixed(4)}, "
        "Lng: ${_form.longitude!.toStringAsFixed(4)}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => _isFetchingLocation = false);
      Get.snackbar(
        "error".tr,
        "${"could_not_fetch_location".tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------- Polygon JSON ----------
  String _buildLocationJson() {
    final lat = _form.latitude ?? 17.4483;
    final lng = _form.longitude ?? 78.4010;
    final d = 0.01;
    return '{"type":"Polygon","coordinates":[[[${lng - d},${lat + d}],'
        '[${lng + d},${lat + d}],[${lng + d},${lat - d}],'
        '[${lng - d},${lat - d}],[${lng - d},${lat + d}]]]}';
  }

  // ---------- Submit ----------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      Get.snackbar(
        "terms_required".tr,
        "accept_terms_msg".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_form.latitude == null || _form.longitude == null) {
      Get.snackbar(
        "location_required".tr,
        "fetch_location_msg".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // ✅ Persist currency choice
    _form.currency = _selectedCurrency;

    await _authservice.userRegisterApi(
      name: _form.nameController.text.trim(),
      email: _form.emailController.text.trim(),
      phone: _form.phoneController.text.trim(),
      address: _form.addressController.text.trim(),
      password: _form.passwordController.text,
      confirmPassword: _form.confirmPasswordController.text,
      farmName: _form.farmNameController.text.trim(),
      farmLocation: _form.farmLocationController.text.trim(),
      // ✅ Optional — null when no photo picked
      image: _form.pickedImage?.path,
      currency: _form.currency,
      location: _buildLocationJson(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // ---------- Back + Title ----------
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(), // ← back to Screen 1
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.blackColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CustomText(
                      textName: "farm_setup".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.bold,
                      fontSize: 20,
                      textColor: AppColors.blackColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- Step bar ----------
                _buildStepBar(currentStep: 2),
                const SizedBox(height: 24),

                // ============================================================
                // ---------- FARM SETUP CARD ----------
                // ============================================================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        textName: "setup_your_farm".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.bold,
                        textColor: AppColors.blackColor,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        textName: "change_later_settings".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      const SizedBox(height: 20),

                      _buildPlainLabel("farm_name".tr),
                      const SizedBox(height: 8),
                      _buildFarmTextField(
                        controller: _form.farmNameController,
                        hint: "farm_name_hint".tr,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? "please_enter_farm_name".tr
                                : null,
                      ),
                      const SizedBox(height: 16),

                      _buildPlainLabel("farm_location_optional".tr),
                      const SizedBox(height: 8),
                      _buildFarmTextField(
                        controller: _form.farmLocationController,
                        hint: "farm_location_hint".tr,
                      ),
                      const SizedBox(height: 16),

                      // ---------- Fetch Location ----------
                      _buildPlainLabel("current_location".tr),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _isFetchingLocation ? null : _fetchLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                size: 18,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child:
                                    _isFetchingLocation
                                        ? CustomText(
                                          textName: "fetching_location".tr,
                                          fontFamily: FontFamily.poppins,
                                          fontWeightType:
                                              FontWeightType.regular,
                                          textColor: Colors.grey.shade600,
                                          fontSize: 12,
                                        )
                                        : CustomText(
                                          textName:
                                              (_form.latitude != null &&
                                                      _form.longitude != null)
                                                  ? "Lat: ${_form.latitude!.toStringAsFixed(4)}, "
                                                      "Lng: ${_form.longitude!.toStringAsFixed(4)}"
                                                  : "tap_to_fetch_location".tr,
                                          fontFamily: FontFamily.poppins,
                                          fontWeightType:
                                              FontWeightType.regular,
                                          textColor:
                                              (_form.latitude != null)
                                                  ? AppColors.blackColor
                                                  : Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                              ),
                              if (_isFetchingLocation)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ---------- Currency ----------
                      _buildPlainLabel("currency".tr),
                      const SizedBox(height: 8),
                      _buildCurrencyToggle(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------- Terms ----------
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _termsAccepted,
                        onChanged: (v) =>
                            setState(() => _termsAccepted = v ?? false),
                        activeColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          children: [
                            TextSpan(
                              text: "by_continuing_agree".tr,
                            ),
                            TextSpan(
                              text: "terms_of_service".tr,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: "privacy_policy".tr,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ---------- Save & Continue ----------
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          textName: "save_and_continue".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.semiBold,
                          textColor: AppColors.whiteColor,
                          fontSize: 14,
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 22,
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
      ),
    );
  }

  // ---------- Step bar ----------
  Widget _buildStepBar({required int currentStep}) {
    return Row(
      children: [
        _stepDot(number: 1, label: "personal_step".tr, isActive: currentStep >= 1),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color:
                currentStep >= 2
                    ? AppColors.primaryColor
                    : Colors.grey.shade300,
          ),
        ),
        _stepDot(number: 2, label: "farm_step".tr, isActive: currentStep >= 2),
      ],
    );
  }

  Widget _stepDot({
    required int number,
    required String label,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryColor : Colors.grey.shade300,
          ),
          child: Center(
            child: CustomText(
              textName: "$number",
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.bold,
              textColor: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        CustomText(
          textName: label,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.regular,
          textColor: isActive ? AppColors.primaryColor : Colors.grey.shade500,
          fontSize: 10,
        ),
      ],
    );
  }

  // ---------- Currency toggle ----------
  Widget _buildCurrencyToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children:
            _currencies.map((currency) {
              final isSelected = _selectedCurrency == currency;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCurrency = currency),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: CustomText(
                        textName: currency,
                        fontFamily: FontFamily.poppins,
                        fontWeightType:
                            isSelected
                                ? FontWeightType.bold
                                : FontWeightType.regular,
                        textColor:
                            isSelected
                                ? AppColors.blackColor
                                : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPlainLabel(String text) {
    return CustomText(
      textName: text,
      fontFamily: FontFamily.poppins,
      fontWeightType: FontWeightType.semiBold,
      textColor: AppColors.blackColor,
      fontSize: 12,
    );
  }

  Widget _buildFarmTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade900),
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
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
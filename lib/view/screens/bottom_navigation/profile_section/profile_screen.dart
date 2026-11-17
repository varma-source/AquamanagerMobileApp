import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/constants/app_toast_msgs.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/main.dart'; // for LocaleController
import 'package:superapp/services/controllerUtils.dart';
import 'package:superapp/services/dependency_injection.dart';
import 'package:superapp/view/screens/auth/login_section/login_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/about_us_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/edit_profile_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/help_support.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/privacy_policy.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/staff/staff_details.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 🎨 Ocean Palette
  final Color _primary = const Color(0xFF087FC1);
  final Color _primaryDark = const Color(0xFF005A9C);
  final Color _bg = const Color(0xFFF7F9FB);

  final _profileController = Get.find<ProfileController>();

  // Toggles
  bool _notificationsEnabled = true;
  bool _darkThemeEnabled = false;

  // 🌐 Language toggle (false = English, true = Telugu)
  bool _isTelugu = false;

  @override
  void initState() {
    super.initState();

    // Sync toggle state with the language saved for THIS role
    SharedPreferences.getInstance().then((prefs) {
      final role = (prefs.getString("role") ?? "").toLowerCase().trim();
      final key = role.isEmpty ? 'lang' : 'lang_$role';
      final saved = prefs.getString(key) ?? 'en';
      if (mounted) {
        setState(() {
          _isTelugu = (saved == 'te');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ---------- HEADER WITH PROFILE ----------
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          const Spacer(),
                          CustomText(
                            textName: "profile".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.bold,
                            textColor: Colors.white,
                            fontSize: 16,
                          ),
                          const Spacer(),
                          _profileController
                                      .profileDataResponce
                                      .value
                                      .data
                                      ?.role ==
                                  "owner"
                              ? _circleBtn(
                                  Icons.edit_outlined,
                                  onTap: () => Get.to(EditProfileScreen()),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---------- Profile Image / Name / Phone ----------
                    Obx(() {
                      final user =
                          _profileController.profileDataResponce.value.data;

                      if (user == null) {
                        return _buildHeaderShimmer();
                      }

                      final String name = user.name ?? "User";
                      final String phone = user.phone ?? "";
                      final String imageUrl = _buildImageUrl(user.image);

                      return Column(
                        children: [
                          // Avatar
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child:
                                imageUrl.isNotEmpty
                                    ? Image.network(
                                      imageUrl,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (_, __, ___) =>
                                              const SizedBox.shrink(),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          CustomText(
                            textName: name,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.bold,
                            textColor: Colors.white,
                            fontSize: 18,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            textName: phone.isNotEmpty ? "+91 $phone" : "",
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.regular,
                            textColor: Colors.white70,
                            fontSize: 12,
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ---------- BODY ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Preferences ----------
                    _sectionTitle("preferences".tr),
                    const SizedBox(height: 10),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildLinkRow(
                            icon: Icons.person_add_alt_1_outlined,
                            iconBg: const Color(0xFFE3F2FD),
                            iconColor: const Color(0xFF1E88E5),
                            title: "add_staff".tr,
                            subtitle: "invite_manage_workers".tr,
                            onTap: () => Get.to(() => StaffDetails()),
                          ),
                          _divider(),
                          _buildToggleRow(
                            icon: Icons.notifications_none,
                            iconBg: const Color(0xFFFFF3E0),
                            iconColor: const Color(0xFFF57C00),
                            title: "notifications".tr,
                            subtitle: "alerts_about_farm".tr,
                            value: _notificationsEnabled,
                            onChanged:
                                (v) =>
                                    setState(() => _notificationsEnabled = v),
                          ),
                          // _divider(),
                          // _buildToggleRow(
                          //   icon: Icons.dark_mode_outlined,
                          //   iconBg: const Color(0xFFE8EAF6),
                          //   iconColor: const Color(0xFF3F51B5),
                          //   title: "dark_theme".tr,
                          //   subtitle: "switch_to_dark_mode".tr,
                          //   value: _darkThemeEnabled,
                          //   onChanged:
                          //       (v) => setState(() => _darkThemeEnabled = v),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---------- Language (toggle, not picker) ----------
                    _sectionTitle("language".tr),
                    const SizedBox(height: 10),
                    _buildCard(
                      child: _buildLanguageToggle(),
                    ),
                    const SizedBox(height: 20),

                    // ---------- More ----------
                    _sectionTitle("more".tr),
                    const SizedBox(height: 10),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildLinkRow(
                            icon: Icons.info_outline,
                            iconBg: const Color(0xFFE3F2FD),
                            iconColor: const Color(0xFF1E88E5),
                            title: "about_us".tr,
                            subtitle: "learn_about_app".tr,
                            onTap: () => Get.to(() => PolicysScreen()),
                          ),
                          _divider(),
                          _buildLinkRow(
                            icon: Icons.headset_mic_outlined,
                            iconBg: const Color(0xFFEDE7F6),
                            iconColor: const Color(0xFF7B1FA2),
                            title: "help_support".tr,
                            subtitle: "get_in_touch".tr,
                            onTap: () => Get.to(() => HelpSupportScreen()),
                          ),
                          _divider(),
                          _buildLinkRow(
                            icon: Icons.privacy_tip_outlined,
                            iconBg: const Color(0xFFE0F7FA),
                            iconColor: const Color(0xFF00897B),
                            title: "privacy_policy".tr,
                            subtitle: "read_our_terms".tr,
                            onTap: () => Get.to(() => PrivacyPolicyScreen()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---------- Logout ----------
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => showLogoutDialog(context),
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFFE53935),
                          size: 16,
                        ),
                        label: CustomText(
                          textName: "logout".tr,
                          fontFamily: FontFamily.poppins,
                          fontWeightType: FontWeightType.semiBold,
                          textColor: const Color(0xFFE53935),
                          fontSize: 13,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFE53935),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Center(
                      child: CustomText(
                        textName: "app_version".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: Colors.grey.shade500,
                        fontSize: 11,
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

  // ============================================================
  // 🌐 LANGUAGE TOGGLE ROW
  // ============================================================
  Widget _buildLanguageToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _iconBadge(
            Icons.language,
            const Color(0xFFE0F2F1),
            _primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textName: "app_language".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: AppColors.blackColor,
                  fontSize: 13,
                ),
                const SizedBox(height: 2),
                CustomText(
                  textName: _isTelugu
                      ? "తెలుగు (Telugu)"
                      : "English",
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          // Toggle
          Row(
            children: [
              CustomText(
                textName: "EN",
                fontFamily: FontFamily.poppins,
                fontWeightType:
                    _isTelugu ? FontWeightType.regular : FontWeightType.bold,
                textColor: _isTelugu ? Colors.grey.shade500 : _primary,
                fontSize: 11,
              ),
              const SizedBox(width: 4),
              Switch(
                value: _isTelugu,
                activeColor: Colors.white,
                activeTrackColor: _primaryDark,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: _primary,
                onChanged: (value) async {
                  setState(() => _isTelugu = value);

                  // Apply via shared LocaleController (per-role persistence)
                  if (Get.isRegistered<LocaleController>()) {
                    await Get.find<LocaleController>()
                        .changeLanguage(value ? 'te' : 'en');
                  } else {
                    Get.updateLocale(
                      value
                          ? const Locale('te', 'IN')
                          : const Locale('en', 'US'),
                    );
                  }
                },
              ),
              const SizedBox(width: 4),
              CustomText(
                textName: "తె",
                fontFamily: FontFamily.poppins,
                fontWeightType:
                    _isTelugu ? FontWeightType.bold : FontWeightType.regular,
                textColor: _isTelugu ? _primary : Colors.grey.shade500,
                fontSize: 11,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ---------- HEADER SHIMMER ----------
  // ============================================================
  Widget _buildHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.25),
      highlightColor: Colors.white.withOpacity(0.55),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 140,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    if (imagePath.startsWith("http")) return imagePath;
    final clean =
        imagePath.startsWith("/") ? imagePath.substring(1) : imagePath;
    return "${AppBaseUrls.ImagebaseUrl}$clean";
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: CustomText(
        textName: text,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.semiBold,
        textColor: Colors.grey.shade700,
        fontSize: 12,
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _iconBadge(icon, iconBg, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textName: title,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.semiBold,
                  textColor: AppColors.blackColor,
                  fontSize: 13,
                ),
                const SizedBox(height: 2),
                CustomText(
                  textName: subtitle,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _primary,
            activeTrackColor: _primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _iconBadge(icon, iconBg, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    textName: title,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: AppColors.blackColor,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    textName: subtitle,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.regular,
                    textColor: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.grey.shade500,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade200, indent: 56);
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _circleBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.18),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // ---------- Logout dialog (preserves per-role language keys) ----------
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(
                  textName: "logout_q".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: AppColors.blackColor,
                  fontSize: 16,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                CustomText(
                  textName: "logout_msg".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: Colors.grey.shade600,
                  fontSize: 12,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: CustomText(
                            textName: "cancel".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: AppColors.blackColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await AppTokens().setAccessToken("");

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final Map<String, String> preserved = {};
                              for (final role in [
                                "staff",
                                "manager",
                                "owner",
                                "coowner",
                              ]) {
                                final key = "lang_$role";
                                final v = prefs.getString(key);
                                if (v != null) preserved[key] = v;
                              }
                              final generic = prefs.getString("lang");
                              if (generic != null) preserved["lang"] = generic;

                              await prefs.clear();

                              for (final entry in preserved.entries) {
                                await prefs.setString(entry.key, entry.value);
                              }

                              ControllerUtils.resetAllControllers();
                              DependencyInjection.resetControllers();

                              if (mounted) {
                                AppToastMsgs.logoutToast(
                                  'Logout',
                                  'You have been logged out successfully',
                                );
                              }

                              Get.offAll(() => const LoginScreen());
                            } catch (e) {
                              debugPrint("Logout error: $e");
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Logout failed'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: CustomText(
                            textName: "logout".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
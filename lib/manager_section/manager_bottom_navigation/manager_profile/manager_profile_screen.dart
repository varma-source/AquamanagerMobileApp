import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/constants/app_toast_msgs.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/main.dart'; // for LocaleController
import 'package:superapp/model/staff_module/staff_profile_model.dart';
import 'package:superapp/services/controllerUtils.dart';
import 'package:superapp/services/dependency_injection.dart';
import 'package:superapp/services/staff_module_service.dart';
import 'package:superapp/view/screens/auth/login_section/login_screen.dart';
import 'package:superapp/view_model/api_controllers/staff_module/staff_profile_controller.dart';

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  // 🎨 Colors
  final Color _bgColor = const Color(0xFFF3F4F6);
  final Color _primaryDark = const Color(0xFF1E3A5F);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _textDark = const Color(0xFF1F2937);
  final Color _textGrey = const Color(0xFF6B7280);
  final Color _signOutRed = const Color(0xFFEF4444);

  // 🌐 Language toggle (false = English, true = Telugu)
  bool _isTelugu = false;

  // ✅ Profile controller
  late final StaffProfileController _profileController;

  // @override
  // void initState() {
  //   super.initState();

  //   // Sync toggle with saved language
  //   SharedPreferences.getInstance().then((prefs) {
  //     final lang = prefs.getString('lang') ?? 'en';
  //     if (mounted) {
  //       setState(() {
  //         _isTelugu = (lang == 'te');
  //       });
  //     }
  //   });

  //   // Register or reuse StaffProfileController
  //   if (Get.isRegistered<StaffProfileController>()) {
  //     _profileController = Get.find<StaffProfileController>();
  //   } else {
  //     _profileController = Get.put(
  //       StaffProfileController(StaffModuleService()),
  //     );
  //   }
  // }
  @override
  void initState() {
    super.initState();

    // 🌐 Sync toggle with the language saved for THIS role
    SharedPreferences.getInstance().then((prefs) {
      final role = (prefs.getString("role") ?? "").toLowerCase().trim();
      final langKey = role.isEmpty ? 'lang' : 'lang_$role';
      final lang = prefs.getString(langKey) ?? 'en';
      if (mounted) {
        setState(() {
          _isTelugu = (lang == 'te');
        });
      }
    });

    // Register or reuse StaffProfileController
    if (Get.isRegistered<StaffProfileController>()) {
      _profileController = Get.find<StaffProfileController>();
    } else {
      _profileController = Get.put(
        StaffProfileController(StaffModuleService()),
      );
    }
  }

  // ═══════════════════════════════════════════════════
  // ✅ LOGOUT POPUP METHOD
  // ═══════════════════════════════════════════════════
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _signOutRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout, color: _signOutRed, size: 32),
                ),
                const SizedBox(height: 20),

                // Title
                CustomText(
                  textName: "sign_out_q".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.bold,
                  textColor: _primaryDark,
                  fontSize: 18,
                ),
                const SizedBox(height: 8),

                // Subtitle
                CustomText(
                  textName: "sign_out_msg".tr,
                  fontFamily: FontFamily.poppins,
                  fontWeightType: FontWeightType.regular,
                  textColor: _textGrey,
                  fontSize: 13,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textDark,
                            side: BorderSide(color: _borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: CustomText(
                            textName: "cancel".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: _textDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          // onPressed: () async {
                          //   try {
                          //     await AppTokens().setAccessToken("");

                          //     final prefs =
                          //         await SharedPreferences.getInstance();
                          //     await prefs.clear();

                          //     ControllerUtils.resetAllControllers();
                          //     DependencyInjection.resetControllers();

                          //     if (mounted) {
                          //       AppToastMsgs.logoutToast(
                          //         'Logout',
                          //         'You have been logged out successfully',
                          //       );
                          //     }

                          //     Get.offAll(() => const LoginScreen());
                          //   } catch (e) {
                          //     debugPrint("Logout error: $e");
                          //     if (mounted) {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         const SnackBar(
                          //           content: Text('Logout failed'),
                          //           backgroundColor: Colors.red,
                          //         ),
                          //       );
                          //     }
                          //   }
                          // },
                          onPressed: () async {
                            try {
                              // 1️⃣ Clear in-memory token
                              await AppTokens().setAccessToken("");

                              // 2️⃣ Preserve per-role language keys before clearing prefs
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final Map<String, String> preservedLanguages = {};

                              for (final role in [
                                "staff",
                                "manager",
                                "owner",
                                "coowner",
                              ]) {
                                final key = "lang_$role";
                                final v = prefs.getString(key);
                                if (v != null) preservedLanguages[key] = v;
                              }
                              final genericLang = prefs.getString("lang");
                              if (genericLang != null)
                                preservedLanguages["lang"] = genericLang;

                              // 3️⃣ Clear everything (token, role, etc.)
                              await prefs.clear();

                              // 4️⃣ Restore the language keys so each role remembers its choice
                              for (final entry in preservedLanguages.entries) {
                                await prefs.setString(entry.key, entry.value);
                              }

                              // 5️⃣ Tear down controllers
                              ControllerUtils.resetAllControllers();
                              DependencyInjection.resetControllers();

                              // 6️⃣ Show toast
                              if (mounted) {
                                AppToastMsgs.logoutToast(
                                  'Logout',
                                  'You have been logged out successfully',
                                );
                              }

                              // 7️⃣ Navigate to login
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
                            backgroundColor: _signOutRed,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: CustomText(
                            textName: "sign_out".tr,
                            fontFamily: FontFamily.poppins,
                            fontWeightType: FontWeightType.semiBold,
                            textColor: Colors.white,
                            fontSize: 14,
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

  // Helper: initials from full name
  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  // ═══════════════════════════════════════════════════
  // ✅ SHIMMER LOADING BODY
  // ═══════════════════════════════════════════════════
  Widget _buildShimmerBody() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 160,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 60,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(3, (_) {
                      return Container(
                        width: 90,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ✅ LANGUAGE TOGGLE SWITCH WIDGET
  // ═══════════════════════════════════════════════════
  Widget _buildLanguageToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.language, size: 20, color: Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              textName: "language".tr,
              fontFamily: FontFamily.poppins,
              fontWeightType: FontWeightType.medium,
              textColor: _textDark,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              CustomText(
                textName: "EN",
                fontFamily: FontFamily.poppins,
                fontWeightType:
                    _isTelugu ? FontWeightType.regular : FontWeightType.bold,
                textColor: _isTelugu ? _textGrey : const Color(0xFF0369A1),
                fontSize: 12,
              ),
              const SizedBox(width: 6),
              Switch(
                value: _isTelugu,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF1E3A5F),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF0369A1),
                onChanged: (value) async {
                  setState(() {
                    _isTelugu = value;
                  });
                  // 🌐 Persist + apply language
                  if (Get.isRegistered<LocaleController>()) {
                    await Get.find<LocaleController>().changeLanguage(
                      value ? 'te' : 'en',
                    );
                  } else {
                    if (value) {
                      Get.updateLocale(const Locale('te', 'IN'));
                    } else {
                      Get.updateLocale(const Locale('en', 'US'));
                    }
                  }
                },
              ),
              const SizedBox(width: 6),
              CustomText(
                textName: "తె",
                fontFamily: FontFamily.poppins,
                fontWeightType:
                    _isTelugu ? FontWeightType.bold : FontWeightType.regular,
                textColor: _isTelugu ? const Color(0xFF0369A1) : _textGrey,
                fontSize: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: CustomText(
          textName: "profile".tr,
          fontFamily: FontFamily.poppins,
          fontWeightType: FontWeightType.bold,
          textColor: _primaryDark,
          fontSize: 16,
        ),
      ),
      body: Obx(() {
        final response = _profileController.staffprofileDataResponce.value;
        final Data? data = response.data;

        // ✅ Shimmer loading state
        if (data == null) {
          return _buildShimmerBody();
        }

        final name = data.name ?? "";
        final email = data.email ?? "";
        final role = data.role ?? "";
        final tankNames =
            (data.tankName ?? []).where((t) => t.trim().isNotEmpty).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------- AVATAR ----------
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A5F),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomText(
                    textName: _initials(name),
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.bold,
                    textColor: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ---------- NAME & EMAIL ----------
              CustomText(
                textName: name,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: _primaryDark,
                fontSize: 18,
              ),
              const SizedBox(height: 4),
              CustomText(
                textName: email,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: _textGrey,
                fontSize: 13,
              ),
              const SizedBox(height: 12),

              // ---------- ROLE TAG ----------
              if (role.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomText(
                    textName:
                        role[0].toUpperCase() + role.substring(1).toLowerCase(),
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.medium,
                    textColor: const Color(0xFF059669),
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 30),

              // ---------- ASSIGNED TANKS CARD ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textName: "assigned_tanks".tr,
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.regular,
                      textColor: _textGrey,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 12),
                    if (tankNames.isEmpty)
                      CustomText(
                        textName: "no_tanks".tr,
                        fontFamily: FontFamily.poppins,
                        fontWeightType: FontWeightType.regular,
                        textColor: _textGrey,
                        fontSize: 12,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            tankNames.map((t) => _buildTankTag(t)).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---------- LANGUAGE TOGGLE (after Assigned tanks) ----------
              _buildLanguageToggle(),
              const SizedBox(height: 16),

              // ---------- SIGN OUT BUTTON ----------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                  label: CustomText(
                    textName: "sign_out".tr,
                    fontFamily: FontFamily.poppins,
                    fontWeightType: FontWeightType.semiBold,
                    textColor: Colors.white,
                    fontSize: 15,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _signOutRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // Helper widget for the tank tags
  Widget _buildTankTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomText(
        textName: name,
        fontFamily: FontFamily.poppins,
        fontWeightType: FontWeightType.medium,
        textColor: const Color(0xFF0369A1),
        fontSize: 12,
      ),
    );
  }
}

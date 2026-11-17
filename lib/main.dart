import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_images.dart';
import 'package:superapp/constants/app_mediaquery.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/constants/localization/localStrings.dart';
import 'package:superapp/firebaseConfiguration.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:superapp/localNotifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:superapp/manager_section/manager_bottom_navigation/manager_bottom_navigation_screen.dart';
import 'package:superapp/services/dependency_injection.dart';
import 'package:superapp/staff_section/staff_bottom_navigation/staff_bottom_navigation.dart';
import 'package:superapp/view/screens/auth/splash_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/bottom_navigation.dart';
import 'package:superapp/view_model/api_controllers/api_logics/token_controller.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  LocalNotification.showNotification(message);
  print('Handling a message ${message}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  DependencyInjection.init();

  // 🌐 Load saved language BEFORE building the app
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('lang') ?? 'en';
  final initialLocale =
      savedLang == 'te' ? const Locale('te', 'IN') : const Locale('en', 'US');

  runApp(MyApp(initialLocale: initialLocale));
}

// 🌐 Locale controller — handles global language switching
class LocaleController extends GetxController {
  LocaleController({required Locale initialLocale})
      : locale = initialLocale.obs;

  final Rx<Locale> locale;

  Future<void> changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', langCode); // Save choice
    if (langCode == 'te') {
      locale.value = const Locale('te', 'IN');
    } else {
      locale.value = const Locale('en', 'US');
    }
    Get.updateLocale(locale.value); // Updates the WHOLE app immediately
  }
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    AppMediaquery().init(context);

    final localeController = Get.put(
      LocaleController(initialLocale: initialLocale),
      permanent: true,
    );

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: LocaleString(), // Your localization file
        locale: localeController.locale.value, // Binds app to this locale
        fallbackLocale: const Locale('en', 'US'),
        title: 'Aqua Manager',
        home: TokenLoader(),
      ),
    );
  }
}

class TokenLoader extends StatefulWidget {
  const TokenLoader({super.key});

  @override
  State<TokenLoader> createState() => _TokenLoaderState();
}

class _TokenLoaderState extends State<TokenLoader> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () async {
      _loadTokenAndNavigate();
    });
  }

  Future<void> _loadTokenAndNavigate() async {
    try {
      String token = await Get.find<TokenController>().loadToken();

      if (token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final String role =
            (prefs.getString("role") ?? "").toString().toLowerCase();

        Future.microtask(() {
          Widget targetScreen;

          switch (role) {
            case "staff":
              targetScreen = StaffBottomNavigation();
              break;
            case "manager":
              targetScreen = ManagerBottomNavigationScreen();
              break;
            case "owner":
            case "coowner":
              targetScreen = BottomNavigation();
              break;
            default:
              targetScreen = BottomNavigation();
              break;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        });
      } else {
        Future.microtask(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppImages.appLogo, height: 200, width: 200),
                    CustomText(
                      textName: "Aqua Manager",
                      fontFamily: FontFamily.poppins,
                      fontWeightType: FontWeightType.semiBold,
                      fontSize: 14,
                      textColor: AppColors.blackColor,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
              child: CustomText(
                textName: "RV Vertex Technologies Private Limited",
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                fontSize: 12,
                textColor: AppColors.greyColor11,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
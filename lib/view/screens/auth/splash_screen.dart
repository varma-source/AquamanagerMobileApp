import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_images.dart';
import 'package:superapp/constants/app_text.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/view/screens/auth/login_section/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Only ONE slide — local asset image of fish & shrimp
  final Map<String, dynamic> splashData = {
    "image": AppImages.appLogo,
    "title": "Fish & prawns",
    "desc":
        "Premium quality fish and prawns raised with care, from our farms to your family.",
    "color": const Color(0xFF1E88E5), // blue from the logo
  };

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    fcmtoken();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleNext() {
    Get.to(() => LoginScreen());
  }

  fcmtoken() async {
    // Request permission for notifications
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();

    // Check if permission is granted
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print("User granted permission");
      // AppLoaders.showLoading(
      //     context: context,
      //     note: 'Please wait while we are working on your request.');

      // Retrieve the FCM token
      String? fcmtoken = await FirebaseMessaging.instance.getToken();

      if (fcmtoken != null) {
        // Get.back();
        print("FCM TOKEN : $fcmtoken");

        AppTokens().setFcmToken(fcmtoken);

        // Update the state with the FCM token
      } else {
        print("Failed to get FCM token");
      }
    } else {
      print("User declined or has not accepted permission");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          Center(
            child: buildSplashItem(
              image: splashData["image"]!,
              title: splashData["title"]!,
              desc: splashData["desc"]!,
              color: splashData["color"]!,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: _handleNext,
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor, Color(0xFF087FC1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSplashItem({
    required String image,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Local Asset Image with Gradient Glow
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    image,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.set_meal, size: 100, color: color);
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          // Title
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomText(
                textName: title,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.bold,
                textColor: AppColors.blackColor,
                fontSize: 26,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomText(
                textName: desc,
                fontFamily: FontFamily.poppins,
                fontWeightType: FontWeightType.regular,
                textColor: Colors.grey[600]!,
                fontSize: 15,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

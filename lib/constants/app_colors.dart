import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF1E88E5);
  // static const Color secondaryColor = Color(0xFFD40000);
  // static const Color secondaryColor1 = Color(0xFF0000FF);
  static const Color primaryColor1 = Color(0xFFFF2D2D);
  static const Color secondaryColor = Color(0xFF003161);
  static const Color secondaryColor1 = Color(0xFF0000FF);
  static const Color secondaryColor2 = Color(0xFFE2DFF2);
  static const Color secondaryColor3 = Color(0xFF0018BE);

  static const Color blackColor = Color(0xFF000000);
  static const Color blackColor1 = Color(0xFF4A4A4A);
  static const Color blackColor2 = Color(0xFF3B3F54);
  static const Color whiteColor = Color(0xFFFFFFFF); // White

  static const Color greyColor = Color(0xFFD9D9D9);
  static const Color greyColor1 = Color(0xFFB8B8B8);
  static const Color greyColor2 = Color(0xFFF5F5F5);
  static const Color greyColor7 = Color(0xFFD4CBCF);
  static const Color greencolor = Color(0xFF1C7326);
  static const Color greencolor1 = Color(0xFF008955);
  static const Color greencolor2 = Color(0xFFCCE7DD);
  static const Color greencolor3 = Color(0xFF008000);
  static const Color greencolor4 = Color(0xFF81C784);
  static const Color greencolor5 = Color(0xFF01A777);
  static const Color greencolor6 = Color(0xFF257F40);
  static const Color litegreenColor = Color(0xFFE6F4EA);
  static const Color redColor = Color(0xFFFF5252);
  static const Color seatredColor = Color(0xFFF4ECEC);
  static const Color greyColor3 = Color(0xFFE5EAEF);
  static const Color greyColor4 = Color(0xFF6E7D85);
  static const Color greyColor5 = Color(0xFFE0DBD5);
  static const Color greyColor6 = Color(0xFF414141);
  static const Color greyColor9 = Color(0xFF808080);
  static const Color greyColor10 = Color(0xFFE0E0E0);
  static const Color greyColor11 = Color(0xFF767676);
  static const Color yellowColor = Color(0xFFE0EA16);
  static const Color lightPink = Color(0xFFF4C2C2);
  static const Color brownColor = Color(0xFFFBD6823);
  final LinearGradient primaryLinearGradient = const LinearGradient(
    colors: [
      primaryColor,
      secondaryColor,
    ], // Transition from primary to secondary color
    begin: Alignment.topLeft, // The gradient starts at the top-left corner
    end: Alignment.bottomRight, // The gradient ends at the bottom-right corner
  );
  final LinearGradient primaryLinearGradientDownToTop = const LinearGradient(
    colors: [
      primaryColor,
      secondaryColor,
    ], // Transition from primary to secondary color
    begin: Alignment.topCenter, // The gradient starts at the top-left corner
    end: Alignment.bottomCenter, // The gradient ends at the bottom-right corner
  );
  final LinearGradient whiteLinearGradient = const LinearGradient(
    colors: [
      greyColor,
      greyColor,
    ], // Transition from primary to secondary color
    begin: Alignment.topLeft, // The gradient starts at the top-left corner
    end: Alignment.bottomRight, // The gradient ends at the bottom-right corner
  );
  final RadialGradient primaryRadialGradient = const RadialGradient(
    colors: [primaryColor, secondaryColor],
    // stops: [0.5, 1.0], // You can adjust the stops as needed
    center: Alignment(0, 0), // Center of the gradient
    radius: 1.5, // Radius of the gradient
  );

  final LinearGradient primaryGradient1 = const LinearGradient(
    colors: [
      secondaryColor,
      primaryColor,
    ], // Transition from primary to secondary color
    begin: Alignment.topLeft, // The gradient starts at the top-left corner
    end: Alignment.bottomRight, // The gradient ends at the bottom-right corner
  );
  final LinearGradient primaryGradient2 = const LinearGradient(
    colors: [
      primaryColor1,
      secondaryColor3,
    ], // Transition from primary to secondary color
    begin: Alignment.topLeft, // The gradient starts at the top-left corner
    end: Alignment.bottomRight, // The gradient ends at the bottom-right corner
  );
  final LinearGradient homeGradient = const LinearGradient(
    colors: [
      whiteColor,
      secondaryColor2,
    ], // Transition from primary to secondary color
    begin: Alignment.topCenter, // The gradient starts at the top-left corner
    end: Alignment.bottomCenter, // The gradient ends at the bottom-right corner
  );
  final LinearGradient drawerGradient = const LinearGradient(
    colors: [
      greencolor6,
      brownColor,
    ], // Transition from primary to secondary color
    begin: Alignment.topCenter, // The gradient starts at the top-left corner
    end: Alignment.bottomCenter, // The gradient ends at the bottom-right corner
  );
}

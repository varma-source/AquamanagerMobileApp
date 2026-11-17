// import 'package:flutter/material.dart';
// import 'package:superapp/constants/app_images.dart';

// class AppLoaders {
//   static void showLoading({required BuildContext context, required String note}) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // Prevents closing on outside tap
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => false, // Disables the back button
//           child: Center(
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.8,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 20,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Animated Logo
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Colors.grey.shade100,
//                           Colors.grey.shade50,
//                         ],
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(40),
//                       child: Image.asset(
//                         AppImages.appLogo,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
                  
//                   // Loading Indicator
//                   const CircularProgressIndicator(
//                     strokeWidth: 3,
//                     color: Colors.black,
//                   ),
//                   const SizedBox(height: 20),
                  
//                   // Loading Text
//                   Text(
//                     note,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontFamily: 'PopM',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Method to hide loading
//   static void hideLoading(BuildContext context) {
//     if (Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
//   }
// }



import 'package:flutter/material.dart';
import 'package:superapp/constants/app_images.dart';

class AppLoaders {
  static void showLoading({required BuildContext context}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue,
                    Colors.purple,
                    Colors.pink,
                    Colors.orange,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0), // Border width
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      AppImages.appLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to hide loading
  static void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}
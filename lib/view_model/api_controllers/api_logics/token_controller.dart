// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:get/get.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:superapp/localNotifications.dart';

// class TokenController extends GetxController {
//   Future<String> loadToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     LocalNotification.initialize();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       LocalNotification.showNotification(message);
//     });

//     return prefs.getString('accessToken') ?? ''; // Retrieve the token
//   }
// }


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/localNotifications.dart';

class TokenController extends GetxController {
  /// Loads the saved access token from SharedPreferences.
  Future<String> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocalNotification.initialize();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotification.showNotification(message);
    });

    return prefs.getString('accessToken') ?? ''; // Retrieve the token
  }

  /// Saves the access token to SharedPreferences.
  Future<void> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    // print("TokenController accessToken saved----->$token");
  }

  /// Optional: clears the token on logout.
  Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }
}
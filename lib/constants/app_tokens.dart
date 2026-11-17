// class AppTokens {
//   AppTokens._privateConstructor();

//   static final AppTokens _instance = AppTokens._privateConstructor();

//   factory AppTokens() {
//     return _instance;
//   }

//   String accessToken = "";
//   String fcmToken = "";

//   setAccessToken(String token) {
//     accessToken = token;
//     print("accessToken----->$accessToken");
//   }

//   void setFcmToken(String token) {
//     fcmToken = token;
//     print("fcmToken----->$fcmToken");
//   }
// }



import 'package:shared_preferences/shared_preferences.dart';

class AppTokens {
  AppTokens._privateConstructor();

  static final AppTokens _instance = AppTokens._privateConstructor();

  factory AppTokens() {
    return _instance;
  }

  String accessToken = "";
  String fcmToken = "";

  Future<void> setAccessToken(String token) async {
    accessToken = token;
    print("accessToken----->$accessToken");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", token);
  }

  Future<void> setFcmToken(String token) async {
    fcmToken = token;
    print("fcmToken----->$fcmToken");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("fcmToken", token);
  }

  Future<String> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken") ?? "";
    return accessToken;
  }
}
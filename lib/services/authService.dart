import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_loaders.dart';
import 'package:superapp/constants/app_toast_msgs.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/main.dart';
import 'package:superapp/manager_section/manager_bottom_navigation/manager_bottom_navigation_screen.dart';
import 'package:superapp/services/controllerUtils.dart';
import 'package:superapp/services/dependency_injection.dart';
import 'package:superapp/staff_section/staff_bottom_navigation/staff_bottom_navigation.dart';
import 'package:superapp/view/screens/auth/login_section/forgot_password/otp_password.dart';
import 'package:superapp/view/screens/auth/login_section/forgot_password/reset_password_screen.dart';
import 'package:superapp/view/screens/auth/login_section/login_screen.dart';
import 'package:superapp/view/screens/bottom_navigation/bottom_navigation.dart';
import 'package:superapp/view_model/api_controllers/api_logics/token_controller.dart';

class Authservice {
  // =-=-=-=-=-=-=- login api -=-=-=-=-=-=-= //

  Future userLoginApi({required String email, required String password}) async {
    AppLoaders.showLoading(context: Get.context!);

    // ✅ Always refresh latest FCM token before API call
    await FirebaseMessaging.instance.deleteToken();
    String? freshFcmToken = await FirebaseMessaging.instance.getToken();

    if (freshFcmToken != null && freshFcmToken.isNotEmpty) {
      AppTokens().setFcmToken(freshFcmToken);
    }

    SharedPreferences accessTokenInstance =
        await SharedPreferences.getInstance();

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/login'),
    );
    request.body = json.encode({
      "email": email,
      "password": password,
      "fcmToken": AppTokens().fcmToken,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      print("LOGIN RESPONSE: $responseString");

      final decodedMap = json.decode(responseString);
      final String token = decodedMap['token'] ?? "";
      final Map<String, dynamic> userMap = decodedMap['user'] ?? {};
      final String role = (userMap['role'] ?? '').toString().toLowerCase();

      if (token.isNotEmpty) {
        await accessTokenInstance.setString("accessToken", token);
        await accessTokenInstance.setString("role", role); // save role locally

        await AppTokens().setAccessToken(token);
        print("Saved Token: $token");
        print("Saved Role: $role");
      }

      // 🌐 Language Handling
      // Get the language the user selected on the Login Screen
      final currentLangCode = Get.locale?.languageCode ?? 'en';

      // Save it to the global 'lang' key so it applies to the whole app
      await accessTokenInstance.setString('lang', currentLangCode);

      // Also apply the language globally
      if (Get.isRegistered<LocaleController>()) {
        await Get.find<LocaleController>().changeLanguage(currentLangCode);
      }

      Get.back(); // close loader

      // ✅ Role based navigation
      switch (role) {
        case "staff":
          Get.offAll(() => StaffBottomNavigation());
          break;
        case "manager":
          Get.offAll(() => ManagerBottomNavigationScreen());
          break;
        case "owner":
        case "coowner":
          Get.offAll(() => BottomNavigation());
          break;
        default:
          Get.offAll(() => BottomNavigation());
          break;
      }

      DependencyInjection.apiInit();
      ControllerUtils.initializeAllControllers();
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();
      AppToastMsgs.failedToast(
        "Error",
        decodedMap['message'] ?? "Something went wrong",
      );
    }
  }

  // =-=-=-=-=-=-=- register api -=-=-=-=-=-=-= //

  Future<void> userRegisterApi({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String confirmPassword,
    required String farmName,
    required String farmLocation,
    // ✅ OPTIONAL — pass null / empty string when no photo
    String? image,
    required String currency,
    required String location,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/auth/register'),
      );

      request.fields.addAll({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'password': password,
        'confirmPassword': confirmPassword,
        'farmName': farmName,
        'farmLocation': farmLocation,
        'currency': currency,
        'location': location,
      });

      // ✅ Only attach the image file if the user actually picked one
      if (image != null && image.trim().isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', image));
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Registration successful',
        );

        Get.offAll(() => LoginScreen());
      } else if (response.statusCode == 400) {
        Get.back();
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Bad request',
        );
      } else {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Something went wrong',
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
    }
  }

  // =-=-=-=-=-=-=- email verify -=-=-=-=-=-=-= //

  Future useremailverify({required String email}) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/generate-otp'),
    );
    request.body = json.encode({"email": email});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      Get.to(OtpPassword(emailId: email));
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- email with otp -=-=-=-=-=-=-= //

  Future userverifyemailotp({
    required String email,
    required String otp,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/verify-otp'),
    );
    request.body = json.encode({"email": email, "otp": otp});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      Get.to(ResetPasswordScreen(emailId: email));
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- email with password -=-=-=-=-=-=-= //

  Future userverifypassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/change-password'),
    );
    request.body = json.encode({
      "email": email,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      Get.to(LoginScreen());
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }
}

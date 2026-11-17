import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:superapp/constants/app_tokens.dart';


class AppFcmtoken {
  Future<void> fcmtoken() async {
    // Request permission for notifications
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      try {
        // Always delete the existing token
        await FirebaseMessaging.instance.deleteToken();
        print("Old FCM token deleted");
      } catch (e) {
        print("Error while deleting old FCM token: $e");
      }

      try {
        // Generate a new token
        String? newToken = await FirebaseMessaging.instance.getToken();
        if (newToken != null) {
          print("New FCM TOKEN: $newToken");

          // Save or update the token
          AppTokens().setFcmToken(newToken);
        } else {
          print("Failed to generate new FCM token");
        }
      } catch (e) {
        print("Error getting new FCM token: $e");
      }
    } else {
      print("Notification permission not granted");
    }
  }
}

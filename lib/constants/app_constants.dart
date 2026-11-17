import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';


class AppConstants {
  static const List drawerNames = [
    "Home",
    "My Rides",
    "Wallet",
    "Settings",
    // "About",
    "Share",
    "Favorite",
    "Customer Support",
    "Delete Account",
  ];

  static const List drawerIcons = [
    Icons.home,
    Icons.near_me_rounded,
    Icons.wallet_rounded,
    Icons.settings_rounded,
    // Icons.info_rounded,
    Icons.share_rounded,
    Icons.favorite_outline,
    Icons.contact_support_rounded,
    Icons.delete_outline,
  ];

  static const List settingNames = [
    'Notifications', // New Entry

    'Privacy Policy', // New Entry
    'Terms & Conditions', // New Entry
    // 'Language', // Existing Entry
  ];
  static const List settingIcons = [
    Icons.notifications_outlined, // Notifications
    Icons.privacy_tip_outlined, // Privacy Policy
    Icons.article_outlined, // Terms & Conditions
    // Icons.language, // Delete Account
  ];

  static const List wayPreferencesNames = [
    'Smoking not allowed',
    'Happy to play music',
    'No pets, please',
    '1 child allowed',
    'Food allowed',
    'Limited luggage space',
  ];

  static const List<IconData> wayPreferencesIcons = [
    Icons.smoke_free, // 'Smoking not allowed'
    Icons.music_note, // 'Happy to play music'
    Icons.pets_outlined, // 'No pets, please'
    Icons.child_friendly, // '1 child allowed'
    Icons.fastfood, // 'Food allowed'
    Icons.luggage, // 'Limited luggage space'
  ];
  static shareAppLink() {
    Share.share('Hi!', subject: 'App Link');
  }

  // ...........>>>>>>>>>>>>>>>              share images  whatsApp                >>>>>>>>>>>>>>>>...........  //
  static Future<void> shareImage(String imageUrl) async {
    try {
      // Fetch the image from the provided URL
      final http.Response response = await http.get(Uri.parse(imageUrl));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Get the bytes of the image
        final List<int> bytes = response.bodyBytes;

        // Get the temporary directory to save the image
        final Directory tempDir = await getTemporaryDirectory();
        final String imagePath = '${tempDir.path}/imageToShare.jpg';

        // Write the image bytes to a file in the temporary directory
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(bytes);

        // Share the image file via WhatsApp
        await Share.shareXFiles([
          XFile(imagePath),
        ], text: 'Image shared through UDBT Mobile App');
      } else {
        throw Exception('Failed to load image: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }
}

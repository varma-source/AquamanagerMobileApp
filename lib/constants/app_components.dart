import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class AppComponents {
  void supportWhatsApp({
    required String phoneNumber,
    required String passMessage,
  }) async {
    String message = passMessage;
    String url =
        'https://wa.me/$phoneNumber/?text=${Uri.encodeQueryComponent(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String calculateTimeDifference(String rideStartTime) {
    try {
      final DateFormat format = DateFormat("hh:mm a");
      final DateTime rideTime = format.parse(rideStartTime);
      final DateTime now = DateTime.now();
      final DateTime todayRideTime = DateTime(
        now.year,
        now.month,
        now.day,
        rideTime.hour,
        rideTime.minute,
      );

      final Duration difference = now.difference(todayRideTime);

      if (difference.isNegative) {
        return "In ${difference.abs().inMinutes} minutes";
      } else {
        return "${difference.inMinutes} min";
      }
    } catch (e) {
      return "Invalid time";
    }
  }

  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them.');
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }

      // Get the current position with timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Location request timed out. Please try again.');
        },
      );
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  Future<void> shareLocationViaWhatsApp() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    String message =
        "My current location: https://maps.google.com/?q=${position.latitude},${position.longitude}";
    String url = "https://wa.me/?text=${Uri.encodeComponent(message)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text("Could not open WhatsApp.")));
    }
  }

  Future<void> dialNumber(String phoneNumber) async {
    String url = "tel:$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text("Could not dial the number.")));
    }
  }

  String extractDateOnly(String isoDateString) {
    try {
      DateTime parsedDate = DateTime.parse(isoDateString);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  // void openGoogleMaps(double latitude, double longitude) async {
  //   final url = Uri.parse(
  //     "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
  //   );

  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not launch Google Maps';
  //   }
  // }

  // void openGoogleMaps(double latitude, double longitude) async {
  //   final url = Uri.parse(
  //     "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
  //   );

  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not open Google Maps';
  //   }
  // }
  void openGoogleMapsRoute(double destinationLat, double destinationLng) async {
    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double currentLat = position.latitude;
    double currentLng = position.longitude;

    // Construct Google Maps directions URL
    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&origin=$currentLat,$currentLng&destination=$destinationLat,$destinationLng&travelmode=driving",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }
}

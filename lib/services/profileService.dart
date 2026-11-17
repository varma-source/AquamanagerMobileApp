import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_loaders.dart';
import 'package:superapp/constants/app_toast_msgs.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/model/notification_model.dart';
import 'package:superapp/model/profile_model.dart';
import 'package:superapp/view/screens/bottom_navigation/bottom_navigation.dart';
import 'package:superapp/view_model/api_controllers/profile_controller.dart';

class ProfileService {
  // =-=-=-=-=-=-=- get profile -=-=-=-=-=-=-= //

  Future<Profiledata> fetchgetprofiledata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/getprofile'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Profiledata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- update profile -=-=-=-=-=-=-= //

  Future updateProfiledetails({
    required String name,
    required String phone,
    required String address,
    String? image, // ✅ now optional
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    final ProfileController _profileController = Get.find<ProfileController>();

    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(AppBaseUrls.baseUrl + 'app/auth/update-profile'),
      );

      request.fields.addAll({'name': name, 'phone': phone, 'address': address});

      // ✅ Only attach the image if the user actually picked one
      if (image != null && image.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', image));
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔄 Refresh profile data in place
        _profileController.fetchgetprofiledata();

        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Profile updated successfully',
        );
        // ❌ No Get.to — stay on same screen
      } else {
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Something went wrong',
        );
      }
    } catch (e) {
      Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
    }
  }

  // =-=-=-=-=-=-=- notification -=-=-=-=-=-=-= //

  Future<Notificationsdata> fetchnotificationsdata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(
        AppBaseUrls.baseUrl + 'app/notification/getallnotificationsbyuserid',
      ),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Notificationsdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- delete notification -=-=-=-=-=-=-= //

  Future userdeletenotification({required String id}) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'DELETE',
      Uri.parse(AppBaseUrls.baseUrl + 'app/notification/deletenotification'),
    );
    request.body = json.encode({"_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }
}

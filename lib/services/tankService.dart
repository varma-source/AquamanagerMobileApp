import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_loaders.dart';
import 'package:superapp/constants/app_toast_msgs.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/model/staff/get_worker_model.dart';
import 'package:superapp/model/staff/staff_model.dart';
import 'package:superapp/model/staff/staff_tank_model.dart';
import 'package:superapp/model/staff/worker_advance_model.dart';
import 'package:superapp/model/staff/worker_model.dart';
import 'package:superapp/model/tank/all_tank_model.dart';
import 'package:superapp/model/tank/get_form_model.dart';
import 'package:superapp/model/tank/tank_staff_model.dart';
import 'package:superapp/view/screens/bottom_navigation/bottom_navigation.dart';
import 'package:superapp/view/screens/bottom_navigation/profile_section/staff/staff_details.dart';
import 'package:superapp/view_model/api_controllers/staff/staff_controller.dart';
import 'package:superapp/view_model/api_controllers/staff/worker_controller.dart';

class TankService {
  // =-=-=-=-=-=-=- get tank data -=-=-=-=-=-=-= //

  Future<AllTankdata> fetchgetanksdata({required String farmId}) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json', // ✅ REQUIRED
    };

    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/tanks/getalltanks'),
    );

    request.headers.addAll(headers);
    request.body = json.encode({"farmId": farmId});

    // debugPrint("📤 fetchgetanksdata → farmId: $farmId");

    http.StreamedResponse response = await request.send();

    var responseString = await response.stream.bytesToString();
    // debugPrint("📥 Status: ${response.statusCode}");
    // debugPrint("📥 Body: $responseString");

    if (response.statusCode == 200) {
      final decodedMap = json.decode(responseString);
      return AllTankdata.fromJson(decodedMap);
    } else {
      final decodedMap = json.decode(responseString);
      AppToastMsgs.failedToast(
        "Error",
        decodedMap['message'] ?? 'Unknown error',
      );
      throw Exception(decodedMap['message'] ?? 'Unknown error');
    }
  }

  // =-=-=-=-=-=-=- add tank -=-=-=-=-=-=-= //

  Future useraddTank({
    required String name,
    required String tankType,
    required String pondSize,
    required String address,
    required double latitude,
    required double longitude,
    List<String>? staffIds, // ✅ Changed to List
    String? farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      const double d = 0.01;
      final double latTop = latitude + d;
      final double latBottom = latitude - d;
      final double lngLeft = longitude - d;
      final double lngRight = longitude + d;

      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/tanks/addtank'),
      );

      request.body = json.encode({
        "name": name,
        "tankType": tankType,
        "pondSize": pondSize,
        "address": address,
        // ✅ Sends as: "staffId": ["id1", "id2"]
        "staffId": staffIds ?? [],
        "farmId": farmId,
        "location": {
          "type": "Polygon",
          "coordinates": [
            [
              [lngLeft, latTop],
              [lngRight, latTop],
              [lngRight, latBottom],
              [lngLeft, latBottom],
              [lngLeft, latTop],
            ],
          ],
        },
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Tank added successfully',
        );
        Get.offAll(() => BottomNavigation());
      } else {
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

  // =-=-=-=-=-=-=- edit tank -=-=-=-=-=-=-= //

  Future<void> userEditTank({
    required String tankId,
    required String name,
    required String tankType,
    required String pondSize,
    required String address,
    required String locationJson,
    required List<String> staffIds, // ✅ Changed to List
    required String status,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };

    var request = http.Request(
      'PUT',
      Uri.parse('${AppBaseUrls.baseUrl}app/tanks/edittank/$tankId'),
    );

    request.body = json.encode({
      "name": name,
      "tankType": tankType,
      "pondSize": pondSize,
      "address": address,
      // ✅ Sends as: "staffId": ["id1", "id2"]
      "staffId": staffIds,
      "status": status,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.successToast(
        "Success",
        decodedMap['message'] ?? 'Tank updated successfully',
      );
    } else {
      final decodedMap = json.decode(responseString);
      AppToastMsgs.failedToast(
        "Error",
        decodedMap['message'] ?? 'Something went wrong',
      );
      throw Exception(decodedMap['message'] ?? 'Something went wrong');
    }
  }

  // =-=-=-=-=-=-=- add staff -=-=-=-=-=-=-= //

  Future<void> userAddstaff({
    required String name,
    required String email,
    required String phone,
    required String joiningDate, // yyyy-MM-dd
    required String monthlySalary,
    required String adharNumber,
    required String advanceSalary,
    required String role,
    required List<String>? tankId,
    required String password,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/staff/addstaff'),
      );

      request.body = json.encode({
        "name": name,
        "email": email,
        "phone": phone,
        "joiningDate": joiningDate,
        "monthlySalary": monthlySalary,
        "adharNumber": adharNumber,
        "advanceSalary": advanceSalary,
        "role": role,
        "status": "active",
        "tankId": tankId,
        "password": password,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Staff added successfully',
        );
        // ❌ No Get.offAll(BottomNavigation()) — stay on same screen
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

  // =-=-=-=-=-=-= get staff -=-=-=-=-=-=-= //

  Future<Staffdata> fetchstaffdata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/staff/getallstaff'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Staffdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- active staff -=-=-=-=-=-=-= //

  Future useractivestaff({
    required String staffId,
    required String status,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'PUT',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/update-staff-status'),
    );
    request.body = json.encode({"staffId": staffId, "status": status});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      Get.to(BottomNavigation());
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- edit staff -=-=-=-=-=-=-= //

  Future<void> userEditStaff({
    required String staffId,
    required String name,
    required String joiningDate,
    required String monthlySalary,
    required String adharNumber,
    required String advanceSalary,
    required String role,
    required String advanceAlreadyGiven,
    required List<String>? tankId, // ✅ array when staff, null otherwise
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'PUT',
        Uri.parse(AppBaseUrls.baseUrl + 'app/staff/editstaff/$staffId'),
      );

      request.body = json.encode({
        "name": name,
        "joiningDate": joiningDate,
        "monthlySalary": monthlySalary,
        "adharNumber": adharNumber,
        "advanceSalary": advanceSalary,
        "role": role,
        "status": "active",
        "advanceAlreadyGiven": advanceAlreadyGiven,
        "tankId": tankId,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Staff updated successfully',
        );
        // ❌ No Get.offAll(BottomNavigation()) — stay on same screen
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

  // =-=-=-=-=-=-=- delete api -=-=-=-=-=-=-= //

  Future userdeletestaff({required String staffId}) async {
    final StaffController _staffController = Get.find<StaffController>();
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'DELETE',
      Uri.parse(AppBaseUrls.baseUrl + 'app/staff/deletestaff/$staffId'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      _staffController.fetchstaffdata();
      // Get.back();
      // Get.to();
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- staff tank -=-=-=-=-=-=-= //

  Future<Stafftankdata> fetchstafftankdata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/tanks/getall-user-tanks'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Stafftankdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get worker -=-=-=-=-=-=-= //

  Future<Workersdata> fetchworkerdata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/worker/getall'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Workersdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add worker -=-=-=-=-=-=-= //

  Future<void> useraddworker({
    required String name,
    required String joiningDate,
    required String monthlySalary,
    required String aadhaarNumber,
    required String advanceAlreadyGiven,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/worker/add'),
      );

      request.body = json.encode({
        "name": name,
        "joiningDate": joiningDate,
        "monthlySalary": monthlySalary,
        "aadhaarNumber": aadhaarNumber,
        "advanceAlreadyGiven": advanceAlreadyGiven,
        "status": "active",
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Worker added successfully',
        );
        // ❌ No Get.offAll(BottomNavigation()) — stay on same screen
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

  // =-=-=-=-=-=-=- edit worker -=-=-=-=-=-=-= //

  Future<void> usereditworker({
    required String name,
    required String phone,
    required String joiningDate,
    required String monthlySalary,
    required String aadhaarNumber,
    required String advanceAlreadyGiven,
    required String workerId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'PUT',
        Uri.parse(AppBaseUrls.baseUrl + 'app/worker/edit/$workerId'),
      );

      request.body = json.encode({
        "name": name,
        "phone": phone,
        "joiningDate": joiningDate,
        "monthlySalary": monthlySalary,
        "aadhaarNumber": aadhaarNumber,
        "advanceAlreadyGiven": advanceAlreadyGiven,
        "status": "active",
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Worker updated successfully',
        );
        // ❌ No Get.to(BottomNavigation()) — stay on same screen
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

  // =-=-=-=-=-=-=- work delete -=-=-=-=-=-=-= //

  Future userworkdelete({required String workerId}) async {
    final WorkerController _workerController = Get.find<WorkerController>();
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'DELETE',
      Uri.parse(AppBaseUrls.baseUrl + 'app/worker/delete/$workerId'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // Get.back();
      // Get.to();
      _workerController.fetchworkerdata();
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- add advance -=-=-=-=-=-=-= //

  Future<void> useraddadvance({
    required String workerId,
    required String date,
    required String amount,
    required String purpose,
    required String paidBy,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/worker-advance/add'),
      );

      request.body = json.encode({
        "workerId": workerId,
        "date": date,
        "amount": amount,
        "purpose": purpose,
        "paidBy": paidBy,
        "status": "active",
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Advance added successfully',
        );
        // ❌ No Get.to(StaffDetails()) — stay on same screen
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

  // =-=-=-=-=-=-=- get worker advance -=-=-=-=-=-=-= //

  Future<Workeradvancedata> fetchworkeradvancedata({
    required String workerId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(
        AppBaseUrls.baseUrl + 'app/worker-advance/getworkeradvancesby-workerid',
      ),
    );
    request.body = json.encode({"workerId": workerId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Workeradvancedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get worker -=-=-=-=-=-=-= //

  Future<Getworkerdata> fetchgetworkerdata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/worker-advance/getall'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Getworkerdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add form -=-=-=-=-=-=-= //

  Future useraddform({
    required String farmName,
    required String farmLocation,
    required String currency,
    required String location,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/addform'),
    );
    request.body = json.encode({
      "farmName": farmName,
      "farmLocation": farmLocation,
      "currency": currency,
      'location': location,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      Get.back();
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- form get -=-=-=-=-=-=-= //

  Future<Getformdata> fetchgetformdata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/getallfarms'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Getformdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get tank staff -=-=-=-=-=-=-= //

  Future<TankStaffData> fetchtankstaffdata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/staff/getall-role-staff'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return TankStaffData.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }
}

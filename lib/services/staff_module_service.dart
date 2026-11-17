import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_loaders.dart';
import 'package:superapp/constants/app_toast_msgs.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/model/staff_module/staff_crop_drop_model.dart';
import 'package:superapp/model/staff_module/staff_expense_model.dart';
import 'package:superapp/model/staff_module/staff_feed_drop_model.dart';
import 'package:superapp/model/staff_module/staff_get_biomass_model.dart';
import 'package:superapp/model/staff_module/staff_get_feed_model.dart';
import 'package:superapp/model/staff_module/staff_get_medicine_model.dart';
import 'package:superapp/model/staff_module/staff_home_model.dart';
import 'package:superapp/model/staff_module/staff_manager_staff_model.dart';
import 'package:superapp/model/staff_module/staff_medicine_drop_model.dart';
import 'package:superapp/model/staff_module/staff_my_feed_model.dart';
import 'package:superapp/model/staff_module/staff_profile_model.dart';
import 'package:superapp/model/staff_module/staff_request_advance_model.dart';
import 'package:superapp/staff_section/staff_bottom_navigation/staff_bottom_navigation.dart';

class StaffModuleService {
  // =-=-=-=-=-=-=- staff profile -=-=-=-=-=-=-= //

  Future<StaffProfiledata> fetchstaffprofiledata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/get-staff-profile'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffProfiledata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get staff home data -=-=-=-=-=-=-= //

  Future<StaffHomedata> fetchstaffhomedata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/auth/home-screen'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffHomedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- ADD LABOUR -=-=-=-=-=-=-= //

  Future<void> addLabour({
    required String tankId,
    required String farmId,
    required String date,
    required String noofpersonsWorked,
    required String chargesPerPerson,
    required String Extras,
    required String TotalLabourCost,
    required String Notes,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/labour'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'noofpersonsWorked': noofpersonsWorked,
      'chargesPerPerson': chargesPerPerson,
      'Extras': Extras,
      'TotalLabourCost': TotalLabourCost,
      'Notes': Notes,
      'farmId': farmId,
    });

    // ✅ Image is OPTIONAL — only attach if path provided
    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back(); // close loader only

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- ADD SALARY -=-=-=-=-=-=-=
  Future<void> addSalary({
    required String tankId,
    required String farmId,
    required String date,
    required String personsJsonString,
    required String TotalSalaries,
    required String notes,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/salary'),
      );

      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'persons': personsJsonString,
        'TotalSalaries': TotalSalaries,
        'notes': notes,
        'farmId': farmId,
      });

      // ✅ Image is OPTIONAL
      if (receiptImage.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Salary added successfully',
        );
      } else {
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Something went wrong',
        );
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Network or file error occurred: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- ADD TIFFIN -=-=-=-=-=-=-=
  Future<void> addTiffin({
    required String tankId,
    required String farmId,
    required String date,
    required String description,
    required String amount,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/tiffins'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'description': description,
      'amount': amount,
      'farmId': farmId,
    });

    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back();

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- ADD PETROL -=-=-=-=-=-=-=
  Future<void> addPetrol({
    required String tankId,
    required String farmId,
    required String date,
    required String category,
    required String description,
    required String amount,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/petrol'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'category': category,
      'description': description,
      'amount': amount,
      'farmId': farmId,
    });

    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back();

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- ADD DIESEL -=-=-=-=-=-=-=
  Future<void> addDiesel({
    required String tankId,
    required String farmId,
    required String date,
    required String description,
    required String amount,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/diesel'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'description': description,
      'amount': amount,
      'farmId': farmId,
    });

    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back();

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- ADD ELECTRICAL -=-=-=-=-=-=-=
  Future<void> addElectrical({
    required String tankId,
    required String farmId,
    required String date,
    required String itemName,
    required String unit,
    required String Quantity,
    required String pricePerUnit,
    required String Total,
    required String Notes,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/electrical'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'itemName': itemName,
      'unit': unit,
      'Quantity': Quantity,
      'pricePerUnit': pricePerUnit,
      'Total': Total,
      'Notes': Notes,
      'farmId': farmId,
    });

    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back();

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- ADD PLUMBING -=-=-=-=-=-=-=
  Future<void> addPlumbing({
    required String tankId,
    required String farmId,
    required String date,
    required String itemName,
    required String quantity,
    required String pricePerQuantity,
    required String total,
    required String notes,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/plumbing'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'itemName': itemName,
      'quantity': quantity,
      'pricePerQuantity': pricePerQuantity,
      'total': total,
      'notes': notes,
      'farmId': farmId,
    });

    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back();

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- ADD TRANSPORT -=-=-=-=-=-=-=
  Future<void> addTransport({
    required String tankId,
    required String farmId,
    required String date,
    required String description,
    required String Amount,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/transport'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'description': description,
      'Amount': Amount,
      'farmId': farmId,
    });

    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back();

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- ADD UTILITIES -=-=-=-=-=-=-=
  Future<void> addUtilities({
    required String tankId,
    required String farmId,
    required String date,
    required String description,
    required String Amount,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/utilities'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'description': description,
      'Amount': Amount,
      'farmId': farmId,
    });

    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back();

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- ADD OTHER -=-=-=-=-=-=-=
  Future<void> addOther({
    required String tankId,
    required String farmId,
    required String date,
    required String description,
    required String Amount,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/add/other'),
    );
    request.fields.addAll({
      'tankId': tankId,
      'date': date,
      'description': description,
      'Amount': Amount,
      'farmId': farmId,
    });

    if (receiptImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('receiptImage', receiptImage),
      );
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    Get.back();

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- get staff expense -=-=-=-=-=-=-= //

  Future<Staffexpensedata> fetchstaffexpensedata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/expense/getall'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Staffexpensedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get staff medicine drop data -=-=-=-=-=-=-= //

  Future<StaffMedicineDropdata> fetchstaffmedicinedropdata({
    required String farmId,
    required String tankId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/auth/get-medicines'),
    );
    request.body = json.encode({"farmId": farmId, "tankId": tankId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffMedicineDropdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add medicine log -=-=-=-=-=-=-= //

  Future userstafflogmedicineadd({
    required String medicineId,
    required String tankId,
    required String farmId,
    required String date,
    required String quanTityUsed,
    required String notes,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/medicine-usage/add'),
    );
    request.body = json.encode({
      "medicineId": medicineId,
      "tankId": tankId,
      "farmId": farmId,
      "date": date,
      "quanTityUsed": quanTityUsed,
      "notes": notes,
      "status": "active",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back(); // Closes the loading dialog ONLY
      Get.back();

      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back(); // Closes the loading dialog ONLY

      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- staff get medicine -=-=-=-=-=-=-= //

  Future<StaffGetMedicinedata> fetchgetmedicinedata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/medicine-usage/get-all'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffGetMedicinedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- crop drop -=-=-=-=-=-=-= //

  Future<StaffCropDropdata> fetchstaffcropdropdata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/auth/get-species'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffCropDropdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- feed drop -=-=-=-=-=-=-= //

  Future<StaffFeedDropdata> fetchstafffeeddropdata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/auth/get-purchases'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffFeedDropdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add feed -=-=-=-=-=-=-= //

  Future userstaffaddfeed({
    required String tankId,
    required String purchaseId,
    required String farmId,
    required String speciesId,
    required String date,
    required String kg,
    required String remarks,
    required String feedingType,
  }) async {
    // AppLoaders.showLoading(context: Get.context!);
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/logfeeding/add'),
    );
    request.body = json.encode({
      "tankId": tankId,
      "purchaseId": purchaseId,
      "farmId": farmId,
      "speciesId": speciesId,
      "date": date,
      "kg": kg,
      "remarks": remarks,
      "status": "active",
      "feedingType": feedingType,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // Get.back(); // Close loading only

      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // Get.back(); // Close loading only

      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- get feed -=-=-=-=-=-=-= //

  Future<StaffGetFeedetails> fetchstaffgetfeedata({
    required String tankId,
    required String farmId,
    required String speciesId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/logfeeding/get-all'),
    );
    request.body = json.encode({
      "tankId": tankId,
      "farmId": farmId,
      "speciesId": speciesId,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffGetFeedetails.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add staff biomass -=-=-=-=-=-=-= //

  Future userstaffaddbiomass({
    required String tankId,
    required String farmId,
    required String date,
    required String estimaTedBiomassKg,
    required String averageBodyWeight,
    required String survival,
    required String reamrks,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/biomass-estimate/add'),
    );
    request.body = json.encode({
      "tankId": tankId,
      "farmId": farmId,
      "date": date,
      "estimaTedBiomassKg": estimaTedBiomassKg,
      "averageBodyWeight": averageBodyWeight,
      "survival": survival,
      "reamrks": reamrks,
      "status": "active",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back(); // Close loading only

      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back(); // Close loading only

      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- get biomass -=-=-=-=-=-=-= //

  Future<StaffGetBiomassetails> fetchstaffgetbiomassdata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/biomass-estimate/get-all'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffGetBiomassetails.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get feed my entires -=-=-=-=-=-=-= //

  Future<StaffMyFeeddata> fetchstaffmyfeedata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/logfeeding/get-staff-logfeedings'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffMyFeeddata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- request advance -=-=-=-=-=-=-= //

  Future userstaffrequestadvance({
    required String date,
    required String amount,
    required String purpose,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/request-advance/add'),
    );
    request.body = json.encode({
      "date": date,
      "amount": amount,
      "purpose": purpose,
      "status": "pending",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back(); // Close the loading dialog only

      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back(); // Close the loading dialog only

      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- get request advance -=-=-=-=-=-=-= //

  Future<StaffRequestAdvancedata> fetchrequestadvancedata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/request-advance/get-all'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffRequestAdvancedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- staff manager staff -=-=-=-=-=-=-= //

  Future<StaffManagerStaffdata> fetchstaffmanagerstaffdata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'staff/auth/get-managerstaff'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return StaffManagerStaffdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }
}

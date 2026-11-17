import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_loaders.dart';
import 'package:superapp/constants/app_toast_msgs.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/manager_section/manager_bottom_navigation/manager_bottom_navigation_screen.dart';
import 'package:superapp/model/staff_module/staff_expense_model.dart';
import 'package:superapp/staff_section/staff_bottom_navigation/staff_bottom_navigation.dart';

class ManagerModuleService {
  // =-=-=-=-=-=-=- ADD LABOUR -=-=-=-=-=-=-=
  Future<void> addmanagerLabour({
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

    // ✅ Image optional
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
  Future<void> addmanagerSalary({
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
  Future<void> addmanagerTiffin({
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
  Future<void> addmanagerPetrol({
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
  Future<void> addmanagerDiesel({
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
  Future<void> addmanagerElectrical({
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
  Future<void> addmanagerPlumbing({
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
  Future<void> addmanagerTransport({
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
  Future<void> addmanagerUtilities({
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
  Future<void> addmanagerOther({
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

  // =-=-=-=-=-=-=- add medicine log -=-=-=-=-=-=-= //

  Future usermanagerlogmedicineadd({
    required String medicineId,
    required String tankId,
    required String farmId,
    required String date,
    required String quanTityUsed,
    required String notes,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
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

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY (same as staff screens)
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Medicine usage logged successfully',
        );
        // ❌ No Get.to / Get.offAll — stay on same screen
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

  // =-=-=-=-=-=-=- add staff biomass -=-=-=-=-=-=-= //

  Future usermanageraddbiomass({
    required String tankId,
    required String farmId,
    required String date,
    required String estimaTedBiomassKg,
    required String averageBodyWeight,
    required String survival,
    required String reamrks,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
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
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Biomass estimate added',
        );
        // ❌ No Get.to — dialog already popped, stay on feed screen
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

  // =-=-=-=-=-=-=- add feed -=-=-=-=-=-=-= //

  Future usermanageraddfeed({
    required String tankId,
    required String purchaseId,
    required String farmId,
    required String speciesId,
    required String date,
    required String kg,
    required String remarks,
    required String feedingType,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
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
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ Plain Get.back() — closes loader ONLY
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Feeding logged successfully',
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

  // =-=-=-=-=-=-=- request advance -=-=-=-=-=-=-= //

  Future usermanagerrequestadvance({
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

      Get.back(); // Closes the loading dialog ONLY

      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back(); // Closes the loading dialog ONLY

      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- manager add staff -=-=-=-=-=-=-= //

  Future<void> usermanageraddstaff({
    required String name,
    required String email,
    required String phone,
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
        "role": role,
        "status": "active",
        "tankId": tankId,
        "password": password,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back(); // Close the loading dialog ONLY
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Staff added successfully',
        );
      } else {
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Something went wrong',
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
    }
  }

  // =-=-=-=-=-=-=- edit manager staff -=-=-=-=-=-=-= //

  Future<void> usermanagerEditStaff({
    required String staffId,
    required String name,
    required String role,
    required List<String>? tankId,
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
        "role": role,
        "status": "active",
        "tankId": tankId,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ EXACTLY like add API — plain Get.back() closes loader ONLY
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Staff updated successfully',
        );
      } else {
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Something went wrong',
        );
      }
    } catch (e) {
      Get.back(); // ✅ Same as add API
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
    }
  }
}

import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:superapp/constants/app_base_urls.dart';
import 'package:superapp/constants/app_loaders.dart';
import 'package:superapp/constants/app_toast_msgs.dart';
import 'package:superapp/constants/app_tokens.dart';
import 'package:superapp/model/over_view/account_balance_model.dart';
import 'package:superapp/model/over_view/account_get_expence_model.dart';
import 'package:superapp/model/over_view/account_staff_advance_model.dart';
import 'package:superapp/model/over_view/biomass_model.dart';
import 'package:superapp/model/over_view/bottom_feed_model.dart';
import 'package:superapp/model/over_view/bottom_madicine_model.dart';
import 'package:superapp/model/over_view/bottom_pandl_model.dart';
import 'package:superapp/model/over_view/expence_model.dart';
import 'package:superapp/model/over_view/expense_party_model.dart';
import 'package:superapp/model/over_view/feed_party_model.dart';
import 'package:superapp/model/over_view/get_feed_model.dart';
import 'package:superapp/model/over_view/harvest_model.dart';
import 'package:superapp/model/over_view/home_feeding_fcr_model.dart';
import 'package:superapp/model/over_view/home_feeding_stock_model.dart';
import 'package:superapp/model/over_view/home_harvest_model.dart';
import 'package:superapp/model/over_view/home_medicine_mosel.dart';
import 'package:superapp/model/over_view/home_pandl_model.dart';
import 'package:superapp/model/over_view/home_tank_over_view_model.dart';
import 'package:superapp/model/over_view/log_feeding_model.dart';
import 'package:superapp/model/over_view/medicine_data_model.dart';
import 'package:superapp/model/over_view/medicine_party_model.dart';
import 'package:superapp/model/over_view/medicine_useage_model.dart';
import 'package:superapp/model/over_view/party_advance_model.dart';
import 'package:superapp/model/over_view/party_model.dart';
import 'package:superapp/model/over_view/purchase_model.dart';
import 'package:superapp/model/over_view/species_model.dart';
import 'package:superapp/view/screens/bottom_navigation/bottom_navigation.dart';
import 'package:superapp/view_model/api_controllers/over_view/biomass_controller.dart';
import 'package:superapp/view_model/api_controllers/over_view/species_controller.dart';

class OverviewService {
  /// ================== add stock  ==================///

  Future useraddstock({
    required String tankId,
    required String date,
    required String speciesName,
    required String cropName,
    required String quantityStocked,
    required String averageWeightAtStocking,
    required String stockingCostPerUnit,
    required String supplier,
    required String notes,
    required String totalAmount,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/stock/add'),
      );

      request.body = json.encode({
        "tankId": tankId,
        "date": date,
        "speciesName": speciesName,
        "cropName": cropName,
        "quantityStocked": quantityStocked,
        "averageWeightAtStocking": averageWeightAtStocking,
        "stockingCostPerUnit": stockingCostPerUnit,
        "supplier": supplier,
        "notes": notes,
        "status": "active",
        "totalAmount": totalAmount,
        "farmId": farmId,
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
          decodedMap['message'] ?? 'Stock added successfully',
        );
        // Get.back();
        // Get.back();
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

  // =-=-=-=-=-=-= edit stock -=-=-=-=-=-=-= //

  Future usereditstock({
    required String stockId,
    required String tankId,
    required String date,
    required String speciesName,
    required String cropName,
    required String quantityStocked,
    required String averageWeightAtStocking,
    required String stockingCostPerUnit,
    required String supplier,
    required String notes,
    required String totalAmount,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'PUT',
        Uri.parse(AppBaseUrls.baseUrl + 'app/stock/edit/$stockId'),
      );

      request.body = json.encode({
        "tankId": tankId,
        "date": date,
        "speciesName": speciesName,
        "cropName": cropName,
        "quantityStocked": quantityStocked,
        "averageWeightAtStocking": averageWeightAtStocking,
        "stockingCostPerUnit": stockingCostPerUnit,
        "supplier": supplier,
        "notes": notes,
        "status": "active",
        "totalAmount": totalAmount,
        "farmId": farmId,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // 1st Get.back() — closes the loader ONLY
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Stock updated successfully',
        );

        // 2nd Get.back() — goes back to the previous screen
        Get.back();
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

  // =-=-=-=-=-=-=- add party -=-=-=-=-=-=-= //

  Future useraddparty({
    required String name,
    required String phone,
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
        Uri.parse(AppBaseUrls.baseUrl + 'app/party/add'),
      );

      request.body = json.encode({
        "name": name,
        "phone": phone,
        "notes": notes,
        "status": "active",
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // 1st Get.back() — closes the loader ONLY
      Get.back();
      Get.back();
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Party added successfully',
        );

        // 2nd Get.back() — goes back to the previous screen
        Get.back();
        Get.back();
      } else {
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Something went wrong',
        );
      }
    } catch (e) {
      Get.back(); // closes loader on error
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
    }
  }

  // =-=-=-=-=-=-=- get party -=-=-=-=-=-=-= //

  Future<Partysdropdata> fetchpartydata() async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/party/getall'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Partysdropdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add partyPayment -=-=-=-=-=-=-= //

  Future<Map<String, dynamic>?> useraddpartypayment({
    required String partyId,
    required String date,
    required String amount,
    required String notes,
    required String paymentMethod,
    required String paymentType,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    final headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    try {
      final request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/party-payment/add'),
      );
      request.headers.addAll(headers);

      final payload = json.encode({
        "partyId": partyId,
        "date": date,
        "amount": amount,
        "notes": notes,
        "paymentMethod": paymentMethod,
        "paymentType": paymentType,
      });
      request.bodyBytes = utf8.encode(payload);

      final http.StreamedResponse response = await request.send();
      final String responseString = await response.stream.bytesToString();

      // Safe decode — server may return HTML on error
      Map<String, dynamic> decodedMap = {};
      try {
        final d = json.decode(responseString);
        if (d is Map<String, dynamic>) decodedMap = d;
      } catch (_) {}

      // ✅ 1) Close loader first (safe — no-op if not open)
      if (Get.isDialogOpen == true) Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ 2) Success toast
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Payment added successfully',
        );
        Get.offAll(() => BottomNavigation());

        return decodedMap;
      } else {
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ??
              'Failed to add payment (${response.statusCode})',
        );
        return null;
      }
    } catch (e, stack) {
      if (Get.isDialogOpen == true) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      return null;
    }
  }

  // =-=-=-=-=-=-=- party advance -=-=-=-=-=-=-= //

  Future<Partyadvancedata> fetchpartyadvance({required String partyId}) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(
        AppBaseUrls.baseUrl + 'app/party-payment/get-party-paymentsby-partyId',
      ),
    );
    request.body = json.encode({"partyId": partyId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Partyadvancedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add feed purchase -=-=-=-=-=-=-= //

  Future useraddfeedpurchase({
    required String tankId,
    required String? partyId,
    required String date,
    required String feedName,
    required String brand,
    required String quantityPurchased,
    required String pricePerKg,
    required String supplierName,
    required String invoiceReference,
    required String paymentMethod,
    required String totalAmount,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/purchase/add'),
      );

      request.body = json.encode({
        "tankId": tankId,
        "partyId": partyId,
        "date": date,
        "feedName": feedName,
        "brand": brand,
        "quantityPurchased": quantityPurchased,
        "pricePerKg": pricePerKg,
        "supplierName": supplierName,
        "invoiceReference": invoiceReference,
        "paymentMethod": paymentMethod,
        "status": "active",
        "totalAmount": totalAmount,
        "farmId": farmId,
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
          decodedMap['message'] ?? 'Feed purchase added successfully',
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

  // =-=-=-=-=-=-=- get feed -=-=-=-=-=-=-= //

  Future<Getfeedata> fetchgetfeedata({
    required String tankId,
    required String farmId,
    required String speciesId,
  }) async {
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/logfeeding/getall'),
    );

    request.body = json.encode({
      "speciesId": speciesId,
      "tankId": tankId,
      "farmId": farmId,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Getfeedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add log purchange -=-=-=-=-=-=-= //

  Future useraddlogfeeding({
    required String tankId,
    required String purchaseId,
    required String date,
    required String kg,
    required String remarks,
    required String speciesId,
    required String farmId,
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
        Uri.parse(AppBaseUrls.baseUrl + 'app/logfeeding/add'),
      );

      request.body = json.encode({
        "tankId": tankId,
        "purchaseId": purchaseId,
        "date": date,
        "kg": kg,
        "remarks": remarks,
        "speciesId": speciesId,
        "status": "active",
        "farmId": farmId,
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

  // =-=-=-=-=-=-=- add biomass -=-=-=-=-=-=-= //

  Future useraddbiomassapi({
    required String tankId,
    required String date,
    required String estimaTedBiomassKg,
    required String averageBodyWeight,
    required String survival,
    required String reamrks,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/bioEstimate/add'),
      );

      request.body = json.encode({
        "tankId": tankId,
        "date": date,
        "estimaTedBiomassKg": estimaTedBiomassKg,
        "averageBodyWeight": averageBodyWeight,
        "survival": survival,
        "reamrks": reamrks,
        "status": "active",
        "farmId": farmId,
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      // ✅ ONE Get.back() — closes loader ONLY
      // (the dialog is popped by the screen AFTER await)
      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Biomass estimate added',
        );
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

  // =-=-=-=-=-=-=- add medicine -=-=-=-=-=-=-= //

  Future useraddmedicine({
    required String? partyId,
    required String tankId,
    required String purchaseDate,
    required String medicineName,
    required String brand,
    required String quantityPurchased,
    required String pricePerUnits,
    required String totalAmount,
    required String invoiceReference,
    required String paidBy,
    required String medicineType,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/medicine/add'),
      );

      request.body = json.encode({
        "partyId": partyId,
        "tankId": tankId,
        "purchaseDate": purchaseDate,
        "medicineName": medicineName,
        "brand": brand,
        "quantityPurchased": quantityPurchased,
        "pricePerUnits": pricePerUnits,
        "totalAmount": totalAmount,
        "invoiceReference": invoiceReference,
        "paidBy": paidBy,
        "medicineType": medicineType,
        "status": "active",
        "farmId": farmId,
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
          decodedMap['message'] ?? 'Medicine added successfully',
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

  // =-=-=-=-=-=-=- get medicine -=-=-=-=-=-=-= //

  Future<Medicinedata> fetchmedicinedata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/medicine/getall'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Medicinedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- medicineUsage -=-=-=-=-=-=-= //

  Future usermedicineusage({
    required String medicineId,
    required String tankId,
    required String date,
    required String quanTityUsed,
    required String notes,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/medicineUsage/add'),
      );

      request.body = json.encode({
        "medicineId": medicineId,
        "tankId": tankId,
        "date": date,
        "quanTityUsed": quanTityUsed,
        "notes": notes,
        "status": "active",
        "farmId": farmId,
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
          decodedMap['message'] ?? 'Medicine usage logged successfully',
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

  // =-=-=-=-=-=-=- get medicine -=-=-=-=-=-=-= //

  Future<Medicineuseagedata> fetchmedicineuseagedata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/medicineUsage/getall'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Medicineuseagedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=- medicine party -=-=-=-=-=-=-= //

  Future<MedicinePartydata> fetchmedicinepartydata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/medicine/getall-medicine-partys'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return MedicinePartydata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- feed party -=-=-=-=-=-=-= //

  Future<FeedPartyData> fetchfeddpartydata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/purchase/get-purchase-parties'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return FeedPartyData.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get expense -=-=-=-=-=-=-= //

  Future<ExpensePartyData> fetchexpensepartydata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/expense/getall-expenses-parties'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return ExpensePartyData.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get species -=-=-=-=-=-=-= //

  Future<Speciesdata> fetchspeciesdata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/stock/getallspecies'),
    );
    request.body = json.encode({"farmId": farmId, "tankId": tankId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Speciesdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- add harvest -=-=-=-=-=-=-= //

  Future useraddharvest({
    required String tankId,
    required String date,
    required String harvestType,
    required String quantityHarvested,
    required String averageSizeAtHarvest,
    required String totalAmount,
    required String marketName,
    required String notes,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);

    try {
      var headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/harvest/add'),
      );

      request.body = json.encode({
        "tankId": tankId,
        "date": date,
        "harvestType": harvestType,
        "quantityHarvested": quantityHarvested,
        "averageSizeAtHarvest": averageSizeAtHarvest,
        "totalAmount": totalAmount,
        "marketName": marketName,
        "notes": notes,
        "status": "active",
        "farmId": farmId,
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
          decodedMap['message'] ?? 'Harvest added successfully',
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

  // =-=-=-=-=-=-=- home over view -=-=-=-=-=-=-= //

  Future<Hometankoverviewdata> fetchhomeoverviewdata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/tank-overview'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Hometankoverviewdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get purchase -=-=-=-=-=-=-= //

  Future<Purchasedata> fetchpurchasedata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/purchase/getall'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Purchasedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get feeding fcr -=-=-=-=-=-=-= //

  Future<Feedingandfcrdata> fetchfeedingfcrdata({
    required String speciesId,
    required String tankId,
    required String purchaseId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/get-feeding-fcr'),
    );
    request.body = json.encode({
      "speciesId": speciesId,
      "tankId": tankId,
      "purchaseId": purchaseId,
      "farmId": farmId,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Feedingandfcrdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get bio mass -=-=-=-=-=-=-= //

  Future<Biomassdata> fetchbiomassdata({
    required String farmId,
    required String tankId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/bioEstimate/getall'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Biomassdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- log feed get -=-=-=-=-=-=-= //

  Future<Logfeedingdata> fetchlogfeedata({
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
      Uri.parse(AppBaseUrls.baseUrl + 'app/logfeeding/getall'),
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
      return Logfeedingdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get feed stock -=-=-=-=-=-=-= //

  Future<Feedingstockdata> fetchfeedstockdata({
    required String tankId,
    required String purchaseId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/get-feedingstock'),
    );
    request.body = json.encode({
      "tankId": tankId,
      "purchaseId": purchaseId,
      "farmId": farmId,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Feedingstockdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get home medicine -=-=-=-=-=-=-= //

  Future<Homemedicinedata> fetchhomemedicinedata({
    required String tankId,
    required String medicineId,
    required String medicineType,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/get-medicine-usage'),
    );
    request.body = json.encode({
      "tankId": tankId,
      "medicineId": medicineId,
      "medicineType": medicineType,
      "farmId": farmId,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Homemedicinedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get harvest -=-=-=-=-=-=-= //

  Future<Harvestdata> fetchharvestdata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/harvest/getall'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Harvestdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- homeharvest -=-=-=-=-=-=-= //

  Future<Homeharvestdata> fetchomeharverstdata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };

    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/get-harvest-summary'),
    );

    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseString = await response.stream.bytesToString();

    print("🌾 Harvest response: $responseString"); // debug

    if (response.statusCode == 200) {
      final decodedMap = json.decode(responseString);
      // ✅ parse into Homeharvestdata — matches your model
      return Homeharvestdata.fromJson(decodedMap);
    } else {
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
      throw Exception(decodedMap['message'] ?? 'Failed');
    }
  }

  // =-=-=-=-=-=-=- LABOUR -=-=-=-=-=-=-=
  Future useraddlabourexpense({
    required String farmId,
    required String tankId,
    required String date,
    required String noofpersonsWorked,
    required String chargesPerPerson,
    required String Extras,
    required String TotalLabourCost,
    required String Notes,
    required String partyId,
    required String receiptImage,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/labour'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'noofpersonsWorked': noofpersonsWorked,
        'chargesPerPerson': chargesPerPerson,
        'Extras': Extras,
        'TotalLabourCost': TotalLabourCost,
        'Notes': Notes,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- SALARY -=-=-=-=-=-=-=
  Future<void> useraddsalaryexpense({
    required String farmId,
    required String tankId,
    required String date,
    required String totalLabourCost,
    required String notes,
    required String partyId,
    required String receiptImage,
    required List<Map<String, dynamic>> persons,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/salary'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'persons': json.encode(persons),
        'TotalSalaries': totalLabourCost,
        'notes': notes,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Salary expense added successfully',
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
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- TIFFINS / MEALS -=-=-=-=-=-=-=
  Future useraddtiffens({
    required String tankId,
    required String date,
    required String description,
    required String amount,
    required String partyId,
    required String receiptImage,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/tiffins'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'description': description,
        'amount': amount,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- PETROL -=-=-=-=-=-=-=
  Future useraddpetrol({
    required String tankId,
    required String date,
    required String category,
    required String description,
    required String amount,
    required String partyId,
    required String receiptImage,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/petrol'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'category': category,
        'description': description,
        'amount': amount,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- DIESEL -=-=-=-=-=-=-=
  Future useradddiesel({
    required String tankId,
    required String date,
    required String description,
    required String amount,
    required String partyId,
    required String receiptImage,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/diesel'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'description': description,
        'amount': amount,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- ELECTRICAL -=-=-=-=-=-=-=
  Future useraddelectrial({
    required String tankId,
    required String date,
    required String itemName,
    required String unit,
    required String Quantity,
    required String pricePerUnit,
    required String Total,
    required String Notes,
    required String partyId,
    required String receiptImage,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/electrical'),
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
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- PLUMBING -=-=-=-=-=-=-=
  Future useraddplumbing({
    required String tankId,
    required String date,
    required String itemName,
    required String quantity,
    required String pricePerQuantity,
    required String total,
    required String notes,
    required String partyId,
    required String receiptImage,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/plumbing'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'itemName': itemName,
        'quantity': quantity,
        'pricePerQuantity': pricePerQuantity,
        'total': total,
        'notes': notes,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- TRANSPORT -=-=-=-=-=-=-=
  Future useraddtransport({
    required String tankId,
    required String date,
    required String description,
    required String Amount,
    required String partyId,
    required String receiptImage,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/transport'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'description': description,
        'Amount': Amount,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- UTILITIES -=-=-=-=-=-=-=
  Future useraddutilities({
    required String tankId,
    required String date,
    required String description,
    required String Amount,
    required String partyId,
    required String receiptImage,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/utilities'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'description': description,
        'Amount': Amount,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- OTHER -=-=-=-=-=-=-=
  Future useraddother({
    required String tankId,
    required String date,
    required String description,
    required String Amount,
    required String partyId,
    required String receiptImage,
    required String farmId,
  }) async {
    AppLoaders.showLoading(context: Get.context!);
    try {
      var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppBaseUrls.baseUrl + 'app/expense/add/other'),
      );
      request.fields.addAll({
        'tankId': tankId,
        'date': date,
        'description': description,
        'Amount': Amount,
        'partyId': partyId,
        'farmId': farmId,
      });

      if (receiptImage.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receiptImage', receiptImage),
        );
      }

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
      } else {
        AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
        throw Exception(decodedMap['message'] ?? 'Failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      rethrow;
    }
  }

  // =-=-=-=-=-=-=- get expence -=-=-=-=-=-=-= //

  Future<Expencedata> fetchexpencedata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/expense/getall'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Expencedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- delete expence -=-=-=-=-=-=-= //

  Future userdeleteexpenses({required String expenseId}) async {
    AppLoaders.showLoading(context: Get.context!);
    var headers = {'Authorization': 'Bearer ${AppTokens().accessToken}'};
    var request = http.Request(
      'DELETE',
      Uri.parse(AppBaseUrls.baseUrl + 'app/expense/delete/$expenseId'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      Get.back();
      // Get.to(BottomNavigation());
      AppToastMsgs.successToast("Success", decodedMap['message'] ?? '');
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      Get.back();
      AppToastMsgs.failedToast("Error", decodedMap['message'] ?? '');
    }
  }

  // =-=-=-=-=-=-=- get p and l -=-=-=-=-=-=-= //

  Future<HomePandLdata> fetchgetpandldata({
    required String tankId,
    required String farmId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/pl-view'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return HomePandLdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- bottom P and L -=-=-=-=-=-=-= //

  Future<Bottompandldata> fetchbottompandl({
    required String farmId,
    required String tankId,
    required String fromDate,
    required String toDate,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/pl-report'),
    );
    request.body = json.encode({
      "farmId": farmId,
      "tankId": tankId,
      "fromDate": fromDate,
      "toDate": toDate,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Bottompandldata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get account -=-=-=-=-=-=-= //

  Future<Accountbalancedata> fetchaccountdata({
    required String farmId,
    required String tankId,
    required String fromDate,
    required String toDate,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/getbalancesheet'),
    );
    request.body = json.encode({
      "farmId": farmId,
      "tankId": tankId,
      "fromDate": fromDate,
      "toDate": toDate,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Accountbalancedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- bootom feed -=-=-=-=-=-=-= //

  Future<Bottomfeeddata> fetchbottomfeedata({
    required String farmId,
    required String tankId,
    required String fromDate,
    required String toDate,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/getfeed-stock'),
    );
    request.body = json.encode({
      "farmId": farmId,
      "tankId": tankId,
      "fromDate": fromDate,
      "toDate": toDate,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Bottomfeeddata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- get bottom medicine -=-=-=-=-=-=-= //

  Future<Bottommedicinedata> fetchbottomedicinedata({
    required String farmId,
    required String tankId,
    required String fromDate,
    required String toDate,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/home/medicine-report'),
    );
    request.body = json.encode({
      "farmId": farmId,
      "tankId": tankId,
      "fromDate": fromDate,
      "toDate": toDate,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return Bottommedicinedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=--=-=-=- account get expence -=-=-=-=-=-=-= //

  Future<AccountGetExpensedata> fetchaccountgetexpencedata({
    required String farmId,
    required String tankId,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/get-staff-expenses'),
    );
    request.body = json.encode({"tankId": tankId, "farmId": farmId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return AccountGetExpensedata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- status change -=-=-=-=-=-=-= //

  Future<bool> userupdatexpense({
    required String staffExpenseId,
    required String status,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };
      final request = http.Request(
        'PUT',
        Uri.parse(
          AppBaseUrls.baseUrl + 'app/auth/update-staff-expenses-status',
        ),
      );
      request.body = json.encode({
        "staffExpenseId": staffExpenseId,
        "status": status,
      });
      request.headers.addAll(headers);

      final http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final dynamic decodedMap = json.decode(responseString);

      // ✅ Close loader FIRST — before any return
      _closeLoader();

      final int code = response.statusCode;
      final bool ok = code == 200 || code == 201;

      if (ok) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Status updated',
        );
        return true;
      } else {
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Update failed',
        );
        return false;
      }
    } catch (e) {
      // ✅ Close loader even on exception
      _closeLoader();
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      return false;
    }
  }

  /// Closes whatever loading overlay `AppLoaders.showLoading` opened.
  /// Works for `Get.dialog`, `showGeneralDialog`, `Get.bottomSheet`,
  /// and custom overlay entries.
  void _closeLoader() {
    try {
      // 1) Standard dialog
      if (Get.isDialogOpen == true) {
        Get.back();
        return;
      }
      // 2) Bottom sheet
      if (Get.isBottomSheetOpen == true) {
        Get.back();
        return;
      }
      // 3) Snackbar (rare for a loader, but some impls use it)
      if (Get.isSnackbarOpen == true) {
        Get.closeCurrentSnackbar();
        return;
      }
      // 4) Generic overlays (covers showGeneralDialog / overlay entry)
      if (Get.isOverlaysOpen == true) {
        Get.back();
        return;
      }
    } catch (_) {
      // ignore — we don't want the loader close to throw
    }
  }

  // =-=-=-=-=-=-=- account get advance -=-=-=-=-=-=-= //

  Future<AccountStaffAdvancesdata> fetchgetaccountadvancedata() async {
    var headers = {
      'Authorization': 'Bearer ${AppTokens().accessToken}',
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse(AppBaseUrls.baseUrl + 'app/auth/staff-request-advances'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      return AccountStaffAdvancesdata.fromJson(decodedMap);
    } else {
      var responseString = await response.stream.bytesToString();
      final decodedMap = json.decode(responseString);
      // AppToastMsgs.failedToast("Error", decodedMap['message']);
      throw Exception(decodedMap['message']);
    }
  }

  // =-=-=-=-=-=-=- update advance -=-=-=-=-=-=-= //

  Future<bool> updatestaffadvance({
    required String staffAdvanceId,
    required String status,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer ${AppTokens().accessToken}',
        'Content-Type': 'application/json',
      };

      final request = http.Request(
        'PUT',
        Uri.parse(
          AppBaseUrls.baseUrl + 'app/auth/update-staff-request-advance',
        ),
      );
      request.body = json.encode({"_id": staffAdvanceId, "status": status});
      request.headers.addAll(headers);

      final http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final dynamic decodedMap = json.decode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToastMsgs.successToast(
          "Success",
          decodedMap['message'] ?? 'Status updated',
        );
        return true;
      } else {
        AppToastMsgs.failedToast(
          "Error",
          decodedMap['message'] ?? 'Update failed',
        );
        return false;
      }
    } catch (e) {
      AppToastMsgs.failedToast("Error", "Something went wrong: $e");
      return false;
    }
  }
}

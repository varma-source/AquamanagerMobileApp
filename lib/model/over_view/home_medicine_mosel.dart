// To parse this JSON data, do
//
//     final homemedicinedata = homemedicinedataFromJson(jsonString);

import 'dart:convert';

Homemedicinedata homemedicinedataFromJson(String str) => Homemedicinedata.fromJson(json.decode(str));

String homemedicinedataToJson(Homemedicinedata data) => json.encode(data.toJson());

class Homemedicinedata {
    final bool? success;
    final Data? data;

    Homemedicinedata({
        this.success,
        this.data,
    });

    factory Homemedicinedata.fromJson(Map<String, dynamic> json) => Homemedicinedata(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    final String? medicineId;
    final String? tankId;
    final String? medicineType;
    final int? totalRecords;
    final int? totalQuantityPurchased;
    final int? totalPricePerUnits;
    final int? totalPurchaseAmount;
    final int? costPerUnit;
    final int? totalQuantityUsed;
    final int? usedMedicineCost;
    final int? remainingQuantity;
    final int? remainingMedicineValue;

    Data({
        this.medicineId,
        this.tankId,
        this.medicineType,
        this.totalRecords,
        this.totalQuantityPurchased,
        this.totalPricePerUnits,
        this.totalPurchaseAmount,
        this.costPerUnit,
        this.totalQuantityUsed,
        this.usedMedicineCost,
        this.remainingQuantity,
        this.remainingMedicineValue,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        medicineId: json["medicineId"],
        tankId: json["tankId"],
        medicineType: json["medicineType"],
        totalRecords: json["totalRecords"],
        totalQuantityPurchased: json["totalQuantityPurchased"],
        totalPricePerUnits: json["totalPricePerUnits"],
        totalPurchaseAmount: json["totalPurchaseAmount"],
        costPerUnit: json["costPerUnit"],
        totalQuantityUsed: json["totalQuantityUsed"],
        usedMedicineCost: json["usedMedicineCost"],
        remainingQuantity: json["remainingQuantity"],
        remainingMedicineValue: json["remainingMedicineValue"],
    );

    Map<String, dynamic> toJson() => {
        "medicineId": medicineId,
        "tankId": tankId,
        "medicineType": medicineType,
        "totalRecords": totalRecords,
        "totalQuantityPurchased": totalQuantityPurchased,
        "totalPricePerUnits": totalPricePerUnits,
        "totalPurchaseAmount": totalPurchaseAmount,
        "costPerUnit": costPerUnit,
        "totalQuantityUsed": totalQuantityUsed,
        "usedMedicineCost": usedMedicineCost,
        "remainingQuantity": remainingQuantity,
        "remainingMedicineValue": remainingMedicineValue,
    };
}

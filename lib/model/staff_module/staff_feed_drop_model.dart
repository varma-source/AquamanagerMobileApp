// To parse this JSON data, do
//
//     final staffFeedDropdata = staffFeedDropdataFromJson(jsonString);

import 'dart:convert';

StaffFeedDropdata staffFeedDropdataFromJson(String str) => StaffFeedDropdata.fromJson(json.decode(str));

String staffFeedDropdataToJson(StaffFeedDropdata data) => json.encode(data.toJson());

class StaffFeedDropdata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Purchase>? purchases;

    StaffFeedDropdata({
        this.success,
        this.message,
        this.count,
        this.purchases,
    });

    factory StaffFeedDropdata.fromJson(Map<String, dynamic> json) => StaffFeedDropdata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        purchases: json["purchases"] == null ? [] : List<Purchase>.from(json["purchases"]!.map((x) => Purchase.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "purchases": purchases == null ? [] : List<dynamic>.from(purchases!.map((x) => x.toJson())),
    };
}

class Purchase {
    final String? id;
    final String? tankId;
    final String? userId;
    final String? partyId;
    final String? farmId;
    final DateTime? date;
    final String? feedName;
    final String? brand;
    final String? quantityPurchased;
    final String? pricePerKg;
    final String? supplierName;
    final String? invoiceReference;
    final String? paymentMethod;
    final String? status;
    final String? totalAmount;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final String? tankName;
    final String? farmName;
    final String? userName;

    Purchase({
        this.id,
        this.tankId,
        this.userId,
        this.partyId,
        this.farmId,
        this.date,
        this.feedName,
        this.brand,
        this.quantityPurchased,
        this.pricePerKg,
        this.supplierName,
        this.invoiceReference,
        this.paymentMethod,
        this.status,
        this.totalAmount,
        this.logCreatedDate,
        this.logModifiedDate,
        this.tankName,
        this.farmName,
        this.userName,
    });

    factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json["_id"],
        tankId: json["tankId"],
        userId: json["userId"],
        partyId: json["partyId"],
        farmId: json["farmId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        feedName: json["feedName"],
        brand: json["brand"],
        quantityPurchased: json["quantityPurchased"],
        pricePerKg: json["pricePerKg"],
        supplierName: json["supplierName"],
        invoiceReference: json["invoiceReference"],
        paymentMethod: json["paymentMethod"],
        status: json["status"],
        totalAmount: json["totalAmount"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        tankName: json["tankName"],
        farmName: json["farmName"],
        userName: json["userName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankId,
        "userId": userId,
        "partyId": partyId,
        "farmId": farmId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "feedName": feedName,
        "brand": brand,
        "quantityPurchased": quantityPurchased,
        "pricePerKg": pricePerKg,
        "supplierName": supplierName,
        "invoiceReference": invoiceReference,
        "paymentMethod": paymentMethod,
        "status": status,
        "totalAmount": totalAmount,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "tankName": tankName,
        "farmName": farmName,
        "userName": userName,
    };
}

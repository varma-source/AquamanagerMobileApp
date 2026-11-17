// To parse this JSON data, do
//
//     final purchasedata = purchasedataFromJson(jsonString);

import 'dart:convert';

Purchasedata purchasedataFromJson(String str) => Purchasedata.fromJson(json.decode(str));

String purchasedataToJson(Purchasedata data) => json.encode(data.toJson());

class Purchasedata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    Purchasedata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory Purchasedata.fromJson(Map<String, dynamic> json) => Purchasedata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
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
    final int? v;
    final String? partyName;
    final String? tankName;

    Datum({
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
        this.v,
        this.partyName,
        this.tankName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
        v: json["__v"],
        partyName: json["partyName"],
        tankName: json["tankName"],
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
        "__v": v,
        "partyName": partyName,
        "tankName": tankName,
    };
}

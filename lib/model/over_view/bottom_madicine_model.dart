// To parse this JSON data, do
//
//     final bottommedicinedata = bottommedicinedataFromJson(jsonString);

import 'dart:convert';

Bottommedicinedata bottommedicinedataFromJson(String str) => Bottommedicinedata.fromJson(json.decode(str));

String bottommedicinedataToJson(Bottommedicinedata data) => json.encode(data.toJson());

class Bottommedicinedata {
    final bool? success;
    final String? message;
    final int? count;
    final DateTime? fromDate;
    final DateTime? toDate;
    final List<Datum>? data;

    Bottommedicinedata({
        this.success,
        this.message,
        this.count,
        this.fromDate,
        this.toDate,
        this.data,
    });

    factory Bottommedicinedata.fromJson(Map<String, dynamic> json) => Bottommedicinedata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        fromDate: json["fromDate"] == null ? null : DateTime.parse(json["fromDate"]),
        toDate: json["toDate"] == null ? null : DateTime.parse(json["toDate"]),
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "fromDate": fromDate == null ? null : "${fromDate!.year.toString().padLeft(4, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}",
        "toDate": toDate == null ? null : "${toDate!.year.toString().padLeft(4, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}",
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    final String? id;
    final String? partyId;
    final String? tankId;
    final String? userId;
    final DateTime? purchaseDate;
    final String? medicineName;
    final String? brand;
    final String? quantityPurchased;
    final String? pricePerUnits;
    final String? totalAmount;
    final String? invoiceReference;
    final String? paidBy;
    final String? medicineType;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;
    final String? partyName;
    final String? tankName;

    Datum({
        this.id,
        this.partyId,
        this.tankId,
        this.userId,
        this.purchaseDate,
        this.medicineName,
        this.brand,
        this.quantityPurchased,
        this.pricePerUnits,
        this.totalAmount,
        this.invoiceReference,
        this.paidBy,
        this.medicineType,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.createdAt,
        this.updatedAt,
        this.v,
        this.partyName,
        this.tankName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        partyId: json["partyId"],
        tankId: json["tankId"],
        userId: json["userId"],
        purchaseDate: json["purchaseDate"] == null ? null : DateTime.parse(json["purchaseDate"]),
        medicineName: json["medicineName"],
        brand: json["brand"],
        quantityPurchased: json["quantityPurchased"],
        pricePerUnits: json["pricePerUnits"],
        totalAmount: json["totalAmount"],
        invoiceReference: json["invoiceReference"],
        paidBy: json["paidBy"],
        medicineType: json["medicineType"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        partyName: json["partyName"],
        tankName: json["tankName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "partyId": partyId,
        "tankId": tankId,
        "userId": userId,
        "purchaseDate": purchaseDate == null ? null : "${purchaseDate!.year.toString().padLeft(4, '0')}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}",
        "medicineName": medicineName,
        "brand": brand,
        "quantityPurchased": quantityPurchased,
        "pricePerUnits": pricePerUnits,
        "totalAmount": totalAmount,
        "invoiceReference": invoiceReference,
        "paidBy": paidBy,
        "medicineType": medicineType,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "partyName": partyName,
        "tankName": tankName,
    };
}

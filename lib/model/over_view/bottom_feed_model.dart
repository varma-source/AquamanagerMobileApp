// To parse this JSON data, do
//
//     final bottomfeeddata = bottomfeeddataFromJson(jsonString);

import 'dart:convert';

Bottomfeeddata bottomfeeddataFromJson(String str) =>
    Bottomfeeddata.fromJson(json.decode(str));

String bottomfeeddataToJson(Bottomfeeddata data) =>
    json.encode(data.toJson());

class Bottomfeeddata {
  final bool? success;
  final String? message;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? tankId;
  final int? count;
  final Summary? summary;
  final List<Datum>? data;

  Bottomfeeddata({
    this.success,
    this.message,
    this.fromDate,
    this.toDate,
    this.tankId,
    this.count,
    this.summary,
    this.data,
  });

  factory Bottomfeeddata.fromJson(Map<String, dynamic> json) => Bottomfeeddata(
        success: json["success"],
        message: json["message"],
        fromDate: json["fromDate"] == null
            ? null
            : DateTime.tryParse(json["fromDate"]),
        toDate: json["toDate"] == null
            ? null
            : DateTime.tryParse(json["toDate"]),
        tankId: json["tankId"],
        count: json["count"],
        summary: json["summary"] == null
            ? null
            : Summary.fromJson(json["summary"]),
        data: json["data"] == null
            ? []
            : List<Datum>.from(
                json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "fromDate": fromDate == null
            ? null
            : "${fromDate!.year.toString().padLeft(4, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}",
        "toDate": toDate == null
            ? null
            : "${toDate!.year.toString().padLeft(4, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}",
        "tankId": tankId,
        "count": count,
        "summary": summary?.toJson(),
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  final String? id;
  final String? tankId;
  final String? userId;
  final String? partyId;
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
        date: json["date"] == null ? null : DateTime.tryParse(json["date"]),
        feedName: json["feedName"],
        brand: json["brand"],
        quantityPurchased: json["quantityPurchased"],
        pricePerKg: json["pricePerKg"],
        supplierName: json["supplierName"],
        invoiceReference: json["invoiceReference"],
        paymentMethod: json["paymentMethod"],
        status: json["status"],
        totalAmount: json["totalAmount"],
        logCreatedDate: json["logCreatedDate"] == null
            ? null
            : DateTime.tryParse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null
            ? null
            : DateTime.tryParse(json["logModifiedDate"]),
        v: json["__v"],
        partyName: json["partyName"],
        tankName: json["tankName"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankId,
        "userId": userId,
        "partyId": partyId,
        "date": date == null
            ? null
            : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
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

class Summary {
  final String? id;            // ✅ was dynamic → now String?
  final num? quantityPurchased; // ✅ was int? → now num?
  final num? totalAmount;       // ✅ was int? → now num?
  final num? totalRecords;      // ✅ was int? → now num?

  Summary({
    this.id,
    this.quantityPurchased,
    this.totalAmount,
    this.totalRecords,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        id: json["_id"]?.toString(),
        quantityPurchased: json["quantityPurchased"] is num
            ? json["quantityPurchased"] as num
            : num.tryParse(json["quantityPurchased"]?.toString() ?? ""),
        totalAmount: json["totalAmount"] is num
            ? json["totalAmount"] as num
            : num.tryParse(json["totalAmount"]?.toString() ?? ""),
        totalRecords: json["totalRecords"] is num
            ? json["totalRecords"] as num
            : num.tryParse(json["totalRecords"]?.toString() ?? ""),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "quantityPurchased": quantityPurchased,
        "totalAmount": totalAmount,
        "totalRecords": totalRecords,
      };
}
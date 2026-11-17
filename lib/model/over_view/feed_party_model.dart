// To parse this JSON data, do
//
//     final feedPartyData = feedPartyDataFromJson(jsonString);

import 'dart:convert';

FeedPartyData feedPartyDataFromJson(String str) => FeedPartyData.fromJson(json.decode(str));

String feedPartyDataToJson(FeedPartyData data) => json.encode(data.toJson());

class FeedPartyData {
    final bool? success;
    final String? message;
    final List<Datum>? data;

    FeedPartyData({
        this.success,
        this.message,
        this.data,
    });

    factory FeedPartyData.fromJson(Map<String, dynamic> json) => FeedPartyData(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    final String? id;
    final DateTime? date;
    final String? userId;
    final String? purchaseId;
    final String? partyId;
    final String? quantityPurchased;
    final String? totalAmount;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    final String? feedName;
    final String? partyName;

    Datum({
        this.id,
        this.date,
        this.userId,
        this.purchaseId,
        this.partyId,
        this.quantityPurchased,
        this.totalAmount,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.feedName,
        this.partyName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        userId: json["userId"],
        purchaseId: json["purchaseId"],
        partyId: json["partyId"],
        quantityPurchased: json["quantityPurchased"],
        totalAmount: json["totalAmount"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        feedName: json["feedName"],
        partyName: json["partyName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "userId": userId,
        "purchaseId": purchaseId,
        "partyId": partyId,
        "quantityPurchased": quantityPurchased,
        "totalAmount": totalAmount,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "feedName": feedName,
        "partyName": partyName,
    };
}

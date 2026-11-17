// To parse this JSON data, do
//
//     final staffMyFeeddata = staffMyFeeddataFromJson(jsonString);

import 'dart:convert';

StaffMyFeeddata staffMyFeeddataFromJson(String str) => StaffMyFeeddata.fromJson(json.decode(str));

String staffMyFeeddataToJson(StaffMyFeeddata data) => json.encode(data.toJson());

class StaffMyFeeddata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    StaffMyFeeddata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory StaffMyFeeddata.fromJson(Map<String, dynamic> json) => StaffMyFeeddata(
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
    final String? staffId;
    final String? tankId;
    final String? farmId;
    final String? purchaseId;
    final String? userId;
    final String? speciesId;
    final DateTime? date;
    final String? kg;
    final String? remarks;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    final String? tankName;
    final String? feedName;
    final String? quantityPurchased;
    final String? pricePerKg;
    final String? speciesName;
    final String? farmName;

    Datum({
        this.id,
        this.staffId,
        this.tankId,
        this.farmId,
        this.purchaseId,
        this.userId,
        this.speciesId,
        this.date,
        this.kg,
        this.remarks,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.tankName,
        this.feedName,
        this.quantityPurchased,
        this.pricePerKg,
        this.speciesName,
        this.farmName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        staffId: json["staffId"],
        tankId: json["tankId"],
        farmId: json["farmId"],
        purchaseId: json["purchaseId"],
        userId: json["userId"],
        speciesId: json["speciesId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        kg: json["kg"],
        remarks: json["remarks"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        tankName: json["tankName"],
        feedName: json["feedName"],
        quantityPurchased: json["quantityPurchased"],
        pricePerKg: json["pricePerKg"],
        speciesName: json["speciesName"],
        farmName: json["farmName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "staffId": staffId,
        "tankId": tankId,
        "farmId": farmId,
        "purchaseId": purchaseId,
        "userId": userId,
        "speciesId": speciesId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "kg": kg,
        "remarks": remarks,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "tankName": tankName,
        "feedName": feedName,
        "quantityPurchased": quantityPurchased,
        "pricePerKg": pricePerKg,
        "speciesName": speciesName,
        "farmName": farmName,
    };
}

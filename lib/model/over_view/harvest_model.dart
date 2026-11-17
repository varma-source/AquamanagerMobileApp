// To parse this JSON data, do
//
//     final harvestdata = harvestdataFromJson(jsonString);

import 'dart:convert';

Harvestdata harvestdataFromJson(String str) => Harvestdata.fromJson(json.decode(str));

String harvestdataToJson(Harvestdata data) => json.encode(data.toJson());

class Harvestdata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Harvest>? harvests;

    Harvestdata({
        this.success,
        this.message,
        this.count,
        this.harvests,
    });

    factory Harvestdata.fromJson(Map<String, dynamic> json) => Harvestdata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        harvests: json["harvests"] == null ? [] : List<Harvest>.from(json["harvests"]!.map((x) => Harvest.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "harvests": harvests == null ? [] : List<dynamic>.from(harvests!.map((x) => x.toJson())),
    };
}

class Harvest {
    final String? id;
    final String? tankId;
    final String? userId;
    final String? farmId;
    final DateTime? date;
    final String? harvestType;
    final String? quantityHarvested;
    final String? averageSizeAtHarvest;
    final String? totalAmount;
    final String? marketName;
    final String? notes;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    final String? tankName;

    Harvest({
        this.id,
        this.tankId,
        this.userId,
        this.farmId,
        this.date,
        this.harvestType,
        this.quantityHarvested,
        this.averageSizeAtHarvest,
        this.totalAmount,
        this.marketName,
        this.notes,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.tankName,
    });

    factory Harvest.fromJson(Map<String, dynamic> json) => Harvest(
        id: json["_id"],
        tankId: json["tankId"],
        userId: json["userId"],
        farmId: json["farmId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        harvestType: json["harvestType"],
        quantityHarvested: json["quantityHarvested"],
        averageSizeAtHarvest: json["averageSizeAtHarvest"],
        totalAmount: json["totalAmount"],
        marketName: json["marketName"],
        notes: json["notes"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        tankName: json["tankName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankId,
        "userId": userId,
        "farmId": farmId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "harvestType": harvestType,
        "quantityHarvested": quantityHarvested,
        "averageSizeAtHarvest": averageSizeAtHarvest,
        "totalAmount": totalAmount,
        "marketName": marketName,
        "notes": notes,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "tankName": tankName,
    };
}

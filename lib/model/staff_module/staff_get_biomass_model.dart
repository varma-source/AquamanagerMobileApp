// To parse this JSON data, do
//
//     final staffGetBiomassetails = staffGetBiomassetailsFromJson(jsonString);

import 'dart:convert';

StaffGetBiomassetails staffGetBiomassetailsFromJson(String str) => StaffGetBiomassetails.fromJson(json.decode(str));

String staffGetBiomassetailsToJson(StaffGetBiomassetails data) => json.encode(data.toJson());

class StaffGetBiomassetails {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    StaffGetBiomassetails({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory StaffGetBiomassetails.fromJson(Map<String, dynamic> json) => StaffGetBiomassetails(
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
    final DateTime? date;
    final String? estimaTedBiomassKg;
    final String? averageBodyWeight;
    final String? survival;
    final String? reamrks;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;
    final String? tankName;
    final String? farmName;

    Datum({
        this.id,
        this.staffId,
        this.tankId,
        this.farmId,
        this.date,
        this.estimaTedBiomassKg,
        this.averageBodyWeight,
        this.survival,
        this.reamrks,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.createdAt,
        this.updatedAt,
        this.v,
        this.tankName,
        this.farmName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        staffId: json["staffId"],
        tankId: json["tankId"],
        farmId: json["farmId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        estimaTedBiomassKg: json["estimaTedBiomassKg"],
        averageBodyWeight: json["averageBodyWeight"],
        survival: json["survival"],
        reamrks: json["reamrks"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        tankName: json["tankName"],
        farmName: json["farmName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "staffId": staffId,
        "tankId": tankId,
        "farmId": farmId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "estimaTedBiomassKg": estimaTedBiomassKg,
        "averageBodyWeight": averageBodyWeight,
        "survival": survival,
        "reamrks": reamrks,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "tankName": tankName,
        "farmName": farmName,
    };
}

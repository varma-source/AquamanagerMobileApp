// To parse this JSON data, do
//
//     final medicineuseagedata = medicineuseagedataFromJson(jsonString);

import 'dart:convert';

Medicineuseagedata medicineuseagedataFromJson(String str) =>
    Medicineuseagedata.fromJson(json.decode(str));

String medicineuseagedataToJson(Medicineuseagedata data) =>
    json.encode(data.toJson());

class Medicineuseagedata {
  final bool? success;
  final String? message;
  final int? count;
  final List<Datum>? data;

  Medicineuseagedata({
    this.success,
    this.message,
    this.count,
    this.data,
  });

  factory Medicineuseagedata.fromJson(Map<String, dynamic> json) =>
      Medicineuseagedata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(
                json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  final String? id;
  final String? medicineId;
  final String? tankId;
  final String? farmId;          // ✅ ADDED
  final String? staffId;         // ✅ ADDED (null when owner created)
  final String? userId;          // null when staff created
  final String? date;
  final String? quanTityUsed;
  final String? notes;
  final String? status;

  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final int? v;

  final String? medicineName;
  final String? tankName;
  final String? staffName;       // ✅ ADDED (empty "" for owner rows)
  final String? farmName;        // ✅ ADDED (may be absent on some rows)

  Datum({
    this.id,
    this.medicineId,
    this.tankId,
    this.farmId,
    this.staffId,
    this.userId,
    this.date,
    this.quanTityUsed,
    this.notes,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.medicineName,
    this.tankName,
    this.staffName,
    this.farmName,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        medicineId: json["medicineId"],
        tankId: json["tankId"],
        farmId: json["farmId"],
        staffId: json["staffId"],
        userId: json["userId"],
        date: json["date"],
        quanTityUsed: json["quanTityUsed"],
        notes: json["notes"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null
            ? null
            : DateTime.tryParse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null
            ? null
            : DateTime.tryParse(json["logModifiedDate"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"]),
        v: json["__v"],
        medicineName: json["medicineName"],
        tankName: json["tankName"],
        staffName: json["staffName"],
        farmName: json["farmName"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "medicineId": medicineId,
        "tankId": tankId,
        "farmId": farmId,
        "staffId": staffId,
        "userId": userId,
        "date": date,
        "quanTityUsed": quanTityUsed,
        "notes": notes,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "medicineName": medicineName,
        "tankName": tankName,
        "staffName": staffName,
        "farmName": farmName,
      };
}
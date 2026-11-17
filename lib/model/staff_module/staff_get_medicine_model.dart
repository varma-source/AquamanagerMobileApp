// To parse this JSON data, do
//
//     final staffGetMedicinedata = staffGetMedicinedataFromJson(jsonString);

import 'dart:convert';

StaffGetMedicinedata staffGetMedicinedataFromJson(String str) => StaffGetMedicinedata.fromJson(json.decode(str));

String staffGetMedicinedataToJson(StaffGetMedicinedata data) => json.encode(data.toJson());

class StaffGetMedicinedata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    StaffGetMedicinedata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory StaffGetMedicinedata.fromJson(Map<String, dynamic> json) => StaffGetMedicinedata(
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
    final String? medicineId;
    final String? tankId;
    final String? farmId;
    final String? staffId;
    final DateTime? date;
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
    final String? farmName;

    Datum({
        this.id,
        this.medicineId,
        this.tankId,
        this.farmId,
        this.staffId,
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
        this.farmName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        medicineId: json["medicineId"],
        tankId: json["tankId"],
        farmId: json["farmId"],
        staffId: json["staffId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        quanTityUsed: json["quanTityUsed"],
        notes: json["notes"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        medicineName: json["medicineName"],
        tankName: json["tankName"],
        farmName: json["farmName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "medicineId": medicineId,
        "tankId": tankId,
        "farmId": farmId,
        "staffId": staffId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
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
        "farmName": farmName,
    };
}

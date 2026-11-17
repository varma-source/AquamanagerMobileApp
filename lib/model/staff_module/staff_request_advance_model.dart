// To parse this JSON data, do
//
//     final staffRequestAdvancedata = staffRequestAdvancedataFromJson(jsonString);

import 'dart:convert';

StaffRequestAdvancedata staffRequestAdvancedataFromJson(String str) => StaffRequestAdvancedata.fromJson(json.decode(str));

String staffRequestAdvancedataToJson(StaffRequestAdvancedata data) => json.encode(data.toJson());

class StaffRequestAdvancedata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    StaffRequestAdvancedata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory StaffRequestAdvancedata.fromJson(Map<String, dynamic> json) => StaffRequestAdvancedata(
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
    final DateTime? date;
    final String? amount;
    final String? purpose;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;

    Datum({
        this.id,
        this.staffId,
        this.date,
        this.amount,
        this.purpose,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        staffId: json["staffId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        amount: json["amount"],
        purpose: json["purpose"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "staffId": staffId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "amount": amount,
        "purpose": purpose,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

// To parse this JSON data, do
//
//     final getworkerdata = getworkerdataFromJson(jsonString);

import 'dart:convert';

Getworkerdata getworkerdataFromJson(String str) => Getworkerdata.fromJson(json.decode(str));

String getworkerdataToJson(Getworkerdata data) => json.encode(data.toJson());

class Getworkerdata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    Getworkerdata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory Getworkerdata.fromJson(Map<String, dynamic> json) => Getworkerdata(
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
    final String? workerId;
    final String? userId;
    final String? date;
    final String? amount;
    final String? purpose;
    final String? paidBy;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;

    Datum({
        this.id,
        this.workerId,
        this.userId,
        this.date,
        this.amount,
        this.purpose,
        this.paidBy,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        workerId: json["workerId"],
        userId: json["userId"],
        date: json["date"],
        amount: json["amount"],
        purpose: json["purpose"],
        paidBy: json["paidBy"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "workerId": workerId,
        "userId": userId,
        "date": date,
        "amount": amount,
        "purpose": purpose,
        "paidBy": paidBy,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

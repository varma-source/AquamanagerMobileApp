// To parse this JSON data, do
//
//     final staffManagerStaffdata = staffManagerStaffdataFromJson(jsonString);

import 'dart:convert';

StaffManagerStaffdata staffManagerStaffdataFromJson(String str) => StaffManagerStaffdata.fromJson(json.decode(str));

String staffManagerStaffdataToJson(StaffManagerStaffdata data) => json.encode(data.toJson());

class StaffManagerStaffdata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    StaffManagerStaffdata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory StaffManagerStaffdata.fromJson(Map<String, dynamic> json) => StaffManagerStaffdata(
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
    final String? userId;
    final List<String>? tankId;
    final String? name;
    final String? email;
    final String? phone;
    final String? password;
    final String? role;
    final String? status;
    final String? managerId;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    final List<String>? tankName;

    Datum({
        this.id,
        this.userId,
        this.tankId,
        this.name,
        this.email,
        this.phone,
        this.password,
        this.role,
        this.status,
        this.managerId,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.tankName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        userId: json["userId"],
        tankId: json["tankId"] == null ? [] : List<String>.from(json["tankId"]!.map((x) => x)),
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        role: json["role"],
        status: json["status"],
        managerId: json["managerId"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        tankName: json["tankName"] == null ? [] : List<String>.from(json["tankName"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "tankId": tankId == null ? [] : List<dynamic>.from(tankId!.map((x) => x)),
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "role": role,
        "status": status,
        "managerId": managerId,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "tankName": tankName == null ? [] : List<dynamic>.from(tankName!.map((x) => x)),
    };
}

// To parse this JSON data, do
//
//     final tankStaffData = tankStaffDataFromJson(jsonString);

import 'dart:convert';

TankStaffData tankStaffDataFromJson(String str) => TankStaffData.fromJson(json.decode(str));

String tankStaffDataToJson(TankStaffData data) => json.encode(data.toJson());

class TankStaffData {
    final bool? success;
    final String? message;
    final List<Staff>? staffs;

    TankStaffData({
        this.success,
        this.message,
        this.staffs,
    });

    factory TankStaffData.fromJson(Map<String, dynamic> json) => TankStaffData(
        success: json["success"],
        message: json["message"],
        staffs: json["staffs"] == null ? [] : List<Staff>.from(json["staffs"]!.map((x) => Staff.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "staffs": staffs == null ? [] : List<dynamic>.from(staffs!.map((x) => x.toJson())),
    };
}

class Staff {
    final String? id;
    final String? userId;
    final List<String>? tankId;
    final String? name;
    final String? email;
    final String? phone;
    final String? role;
    final String? status;
    final String? managerId;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    final String? adharNumber;
    final String? advanceAlreadyGiven;
    final String? advanceSalary;
    final String? joiningDate;
    final String? monthlySalary;
    final String? fcmToken;
    final List<String>? tankName;

    Staff({
        this.id,
        this.userId,
        this.tankId,
        this.name,
        this.email,
        this.phone,
        this.role,
        this.status,
        this.managerId,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.adharNumber,
        this.advanceAlreadyGiven,
        this.advanceSalary,
        this.joiningDate,
        this.monthlySalary,
        this.fcmToken,
        this.tankName,
    });

    factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json["_id"],
        userId: json["userId"],
        tankId: json["tankId"] == null ? [] : List<String>.from(json["tankId"]!.map((x) => x)),
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        role: json["role"],
        status: json["status"],
        managerId: json["managerId"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        adharNumber: json["adharNumber"],
        advanceAlreadyGiven: json["advanceAlreadyGiven"],
        advanceSalary: json["advanceSalary"],
        joiningDate: json["joiningDate"],
        monthlySalary: json["monthlySalary"],
        fcmToken: json["fcmToken"],
        tankName: json["tankName"] == null ? [] : List<String>.from(json["tankName"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "tankId": tankId == null ? [] : List<dynamic>.from(tankId!.map((x) => x)),
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "status": status,
        "managerId": managerId,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "adharNumber": adharNumber,
        "advanceAlreadyGiven": advanceAlreadyGiven,
        "advanceSalary": advanceSalary,
        "joiningDate": joiningDate,
        "monthlySalary": monthlySalary,
        "fcmToken": fcmToken,
        "tankName": tankName == null ? [] : List<dynamic>.from(tankName!.map((x) => x)),
    };
}

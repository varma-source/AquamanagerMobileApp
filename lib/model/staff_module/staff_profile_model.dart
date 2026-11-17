// To parse this JSON data, do
//
//     final staffProfiledata = staffProfiledataFromJson(jsonString);

import 'dart:convert';

StaffProfiledata staffProfiledataFromJson(String str) =>
    StaffProfiledata.fromJson(json.decode(str));

String staffProfiledataToJson(StaffProfiledata data) =>
    json.encode(data.toJson());

// ✅ Safe date parser — never throws
DateTime? _safeParseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    final s = value.trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }
  return null;
}

// ✅ Safe string parser
String? _safeString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

// ✅ Safe string-list parser
List<String>? _safeStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((x) => x != null)
        .map((x) => x.toString())
        .toList();
  }
  return [];
}

class StaffProfiledata {
  final bool? success;
  final Data? data;

  StaffProfiledata({
    this.success,
    this.data,
  });

  factory StaffProfiledata.fromJson(Map<String, dynamic> json) =>
      StaffProfiledata(
        success: json["success"] is bool ? json["success"] : null,
        data: json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class Data {
  final String? id;
  final String? userId;
  final List<String>? tankId;
  final String? name;
  final String? email;
  final String? phone;
  final DateTime? joiningDate;
  final String? monthlySalary;
  final String? adharNumber;
  final String? advanceSalary;
  final String? password;
  final String? role;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;
  final String? advanceAlreadyGiven;
  final List<String>? tankName;

  Data({
    this.id,
    this.userId,
    this.tankId,
    this.name,
    this.email,
    this.phone,
    this.joiningDate,
    this.monthlySalary,
    this.adharNumber,
    this.advanceSalary,
    this.password,
    this.role,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    this.advanceAlreadyGiven,
    this.tankName,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: _safeString(json["_id"]),
        userId: _safeString(json["userId"]),
        tankId: _safeStringList(json["tankId"]),
        name: _safeString(json["name"]),
        email: _safeString(json["email"]),
        phone: _safeString(json["phone"]),
        joiningDate: _safeParseDate(json["joiningDate"]),
        monthlySalary: _safeString(json["monthlySalary"]),
        adharNumber: _safeString(json["adharNumber"]),
        advanceSalary: _safeString(json["advanceSalary"]),
        password: _safeString(json["password"]),
        role: _safeString(json["role"]),
        status: _safeString(json["status"]),
        logCreatedDate: _safeParseDate(json["logCreatedDate"]),
        logModifiedDate: _safeParseDate(json["logModifiedDate"]),
        v: json["__v"] is int ? json["__v"] : null,
        advanceAlreadyGiven: _safeString(json["advanceAlreadyGiven"]),
        tankName: _safeStringList(json["tankName"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "tankId": tankId == null
            ? []
            : List<dynamic>.from(tankId!.map((x) => x)),
        "name": name,
        "email": email,
        "phone": phone,
        "joiningDate": joiningDate == null
            ? null
            : "${joiningDate!.year.toString().padLeft(4, '0')}-"
                "${joiningDate!.month.toString().padLeft(2, '0')}-"
                "${joiningDate!.day.toString().padLeft(2, '0')}",
        "monthlySalary": monthlySalary,
        "adharNumber": adharNumber,
        "advanceSalary": advanceSalary,
        "password": password,
        "role": role,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "advanceAlreadyGiven": advanceAlreadyGiven,
        "tankName": tankName == null
            ? []
            : List<dynamic>.from(tankName!.map((x) => x)),
      };
}
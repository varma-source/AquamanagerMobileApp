import 'dart:convert';

Staffdata staffdataFromJson(String str) =>
    Staffdata.fromJson(json.decode(str));

String staffdataToJson(Staffdata data) => json.encode(data.toJson());

// ✅ Safe date parser — never throws
DateTime? _parseDate(dynamic value) {
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

class Staffdata {
  final bool? success;
  final String? message;
  final List<Staff>? staffs;

  Staffdata({
    this.success,
    this.message,
    this.staffs,
  });

  factory Staffdata.fromJson(Map<String, dynamic> json) => Staffdata(
        success: json["success"],
        message: json["message"],
        staffs: json["staffs"] == null
            ? []
            : List<Staff>.from(json["staffs"]!.map((x) => Staff.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "staffs": staffs == null
            ? []
            : List<dynamic>.from(staffs!.map((x) => x.toJson())),
      };
}

class Staff {
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
  final List<String>? tankName;

  Staff({
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
    this.tankName,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json["_id"],
        userId: json["userId"],
        tankId: json["tankId"] == null
            ? []
            : List<String>.from(json["tankId"]!.map((x) => x)),
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        // ✅ Use safe parser here
        joiningDate: _parseDate(json["joiningDate"]),
        monthlySalary: json["monthlySalary"],
        adharNumber: json["adharNumber"],
        advanceSalary: json["advanceSalary"],
        password: json["password"],
        role: json["role"],
        status: json["status"],
        // ✅ Use safe parser here
        logCreatedDate: _parseDate(json["logCreatedDate"]),
        logModifiedDate: _parseDate(json["logModifiedDate"]),
        v: json["__v"],
        tankName: json["tankName"] == null
            ? []
            : List<String>.from(json["tankName"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "tankId":
            tankId == null ? [] : List<dynamic>.from(tankId!.map((x) => x)),
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
        "tankName": tankName == null
            ? []
            : List<dynamic>.from(tankName!.map((x) => x)),
      };
}
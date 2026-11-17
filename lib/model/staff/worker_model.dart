import 'dart:convert';

Workersdata workersdataFromJson(String str) =>
    Workersdata.fromJson(json.decode(str));

String workersdataToJson(Workersdata data) => json.encode(data.toJson());

class Workersdata {
  final bool? success;
  final String? message;
  final List<Datum>? data;

  Workersdata({
    this.success,
    this.message,
    this.data,
  });

  factory Workersdata.fromJson(Map<String, dynamic> json) => Workersdata(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(
                json["data"]!.map((x) => Datum.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  final String? id;
  final String? name;
  final String? phone;
  final DateTime? joiningDate;
  final String? monthlySalary;
  final String? aadhaarNumber;
  final String? advanceAlreadyGiven;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Datum({
    this.id,
    this.name,
    this.phone,
    this.joiningDate,
    this.monthlySalary,
    this.aadhaarNumber,
    this.advanceAlreadyGiven,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
        joiningDate: _parseDate(json["joiningDate"]),
        monthlySalary: json["monthlySalary"]?.toString(),
        aadhaarNumber: json["aadhaarNumber"],
        advanceAlreadyGiven: json["advanceAlreadyGiven"]?.toString(),
        status: json["status"],
        logCreatedDate: _parseDate(json["logCreatedDate"]),
        logModifiedDate: _parseDate(json["logModifiedDate"]),
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phone": phone,
        "joiningDate": joiningDate == null
            ? null
            : "${joiningDate!.year.toString().padLeft(4, '0')}-"
                "${joiningDate!.month.toString().padLeft(2, '0')}-"
                "${joiningDate!.day.toString().padLeft(2, '0')}",
        "monthlySalary": monthlySalary,
        "aadhaarNumber": aadhaarNumber,
        "advanceAlreadyGiven": advanceAlreadyGiven,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

/// ✅ Safe date parser — never throws
/// Handles:
///  - null
///  - ""
///  - "null" / "Invalid Date"
///  - yyyy-MM-dd
///  - ISO strings ("2026-10-11T16:47:05.233+05:30")
///  - dd/mm/yyyy or dd-mm-yyyy
///  - numeric timestamps (int / numeric string)
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  if (value is int) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } catch (_) {
      return null;
    }
  }

  final str = value.toString().trim();
  if (str.isEmpty) return null;
  if (str.toLowerCase() == "null") return null;
  if (str.toLowerCase() == "invalid date") return null;

  // Try standard ISO / yyyy-MM-dd
  try {
    return DateTime.parse(str);
  } catch (_) {}

  // Try dd/mm/yyyy or dd-mm-yyyy
  final ddmm = RegExp(r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})$');
  final m = ddmm.firstMatch(str);
  if (m != null) {
    try {
      final d = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      var y = int.parse(m.group(3)!);
      if (y < 100) y += 2000;
      return DateTime(y, mo, d);
    } catch (_) {
      return null;
    }
  }

  // Try numeric string timestamp
  final asInt = int.tryParse(str);
  if (asInt != null) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(asInt);
    } catch (_) {
      return null;
    }
  }

  return null;
}
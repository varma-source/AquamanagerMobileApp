// To parse this JSON data, do
//
//     final workeradvancedata = workeradvancedataFromJson(jsonString);

import 'dart:convert';

Workeradvancedata workeradvancedataFromJson(String str) =>
    Workeradvancedata.fromJson(json.decode(str));

String workeradvancedataToJson(Workeradvancedata data) =>
    json.encode(data.toJson());

class Workeradvancedata {
  final bool? success;
  final String? message;
  final int? count;
  final List<Datum>? data;

  Workeradvancedata({
    this.success,
    this.message,
    this.count,
    this.data,
  });

  factory Workeradvancedata.fromJson(Map<String, dynamic> json) =>
      Workeradvancedata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(
                json["data"]!.map((x) => Datum.fromJson(x)),
              ),
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
  final String? workerId;
  final DateTime? date;
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
        // ✅ Safe — handles null, "", "Invalid Date", "null" etc.
        date: _parseDate(json["date"]),
        amount: json["amount"]?.toString(),
        purpose: json["purpose"],
        paidBy: json["paidBy"],
        status: json["status"],
        logCreatedDate: _parseDate(json["logCreatedDate"]),
        logModifiedDate: _parseDate(json["logModifiedDate"]),
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "workerId": workerId,
        "date": date == null
            ? null
            : "${date!.year.toString().padLeft(4, '0')}-"
                "${date!.month.toString().padLeft(2, '0')}-"
                "${date!.day.toString().padLeft(2, '0')}",
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

/// ✅ Safe date parser — never throws.
/// Handles:
///  - null
///  - ""
///  - "null"
///  - "Invalid Date"
///  - dd/mm/yyyy (e.g. "07/10/2026")
///  - yyyy-MM-dd (e.g. "2026-10-07")
///  - ISO strings (e.g. "2026-10-07T00:00:00.000Z")
///  - milliseconds since epoch (int / numeric string)
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  // Numeric timestamp (ms)
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

  // Try standard ISO / yyyy-MM-dd first
  try {
    return DateTime.parse(str);
  } catch (_) {
    // fall through
  }

  // Try dd/mm/yyyy or dd-mm-yyyy
  final ddmm = RegExp(r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})$');
  final m = ddmm.firstMatch(str);
  if (m != null) {
    try {
      final d = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      var y = int.parse(m.group(3)!);
      if (y < 100) y += 2000; // 2-digit year → 20xx
      return DateTime(y, mo, d);
    } catch (_) {
      return null;
    }
  }

  // Try parsing as numeric milliseconds string
  final asInt = int.tryParse(str);
  if (asInt != null) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(asInt);
    } catch (_) {
      return null;
    }
  }

  // Give up — return null instead of crashing
  return null;
}
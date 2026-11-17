// To parse this JSON data, do
//
//     final biomassdata = biomassdataFromJson(jsonString);

import 'dart:convert';

Biomassdata biomassdataFromJson(String str) =>
    Biomassdata.fromJson(json.decode(str));

String biomassdataToJson(Biomassdata data) => json.encode(data.toJson());

class Biomassdata {
  final bool? success;
  final String? message;
  final int? count;
  final List<Datum>? data;

  Biomassdata({this.success, this.message, this.count, this.data});

  factory Biomassdata.fromJson(Map<String, dynamic> json) => Biomassdata(
    success: json["success"] is bool ? json["success"] : null,
    message: json["message"]?.toString(),
    count:
        json["count"] is int
            ? json["count"]
            : (json["count"] != null ? int.tryParse("${json["count"]}") : null),
    data:
        json["data"] is List
            ? List<Datum>.from(
              (json["data"] as List).map((x) {
                try {
                  return Datum.fromJson(x as Map<String, dynamic>);
                } catch (_) {
                  return Datum();
                }
              }),
            )
            : [],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "count": count,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  final String? id;
  final String? tankId;
  final String? farmId; // ✅ ADDED
  final String? userId;
  final DateTime? date;
  final String? estimaTedBiomassKg;
  final String? averageBodyWeight;
  final String? survival;
  final String? reamrks;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? tankName;

  Datum({
    this.id,
    this.tankId,
    this.farmId, // ✅ ADDED
    this.userId,
    this.date,
    this.estimaTedBiomassKg,
    this.averageBodyWeight,
    this.survival,
    this.reamrks,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.tankName,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"]?.toString(),
    tankId: json["tankId"]?.toString(),
    farmId: json["farmId"]?.toString(), // ✅ ADDED
    userId: json["userId"]?.toString(),
    // ✅ Safe date parsing — never throws
    date: _parseDate(json["date"]),
    estimaTedBiomassKg: json["estimaTedBiomassKg"]?.toString(),
    averageBodyWeight: json["averageBodyWeight"]?.toString(),
    survival: json["survival"]?.toString(),
    reamrks: json["reamrks"]?.toString(),
    status: json["status"]?.toString(),
    logCreatedDate: _parseDate(json["logCreatedDate"]),
    logModifiedDate: _parseDate(json["logModifiedDate"]),
    createdAt: _parseDate(json["createdAt"]),
    updatedAt: _parseDate(json["updatedAt"]),
    v: json["__v"] is int ? json["__v"] as int : null,
    tankName: json["tankName"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "tankId": tankId,
    "farmId": farmId, // ✅ ADDED
    "userId": userId,
    "date":
        date == null
            ? null
            : "${date!.year.toString().padLeft(4, '0')}-"
                "${date!.month.toString().padLeft(2, '0')}-"
                "${date!.day.toString().padLeft(2, '0')}",
    "estimaTedBiomassKg": estimaTedBiomassKg,
    "averageBodyWeight": averageBodyWeight,
    "survival": survival,
    "reamrks": reamrks,
    "status": status,
    "logCreatedDate": logCreatedDate?.toIso8601String(),
    "logModifiedDate": logModifiedDate?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "tankName": tankName,
  };
}

/// ✅ Safe date parser — handles:
///  - null
///  - ""
///  - "null" / "Invalid Date"
///  - yyyy-MM-dd
///  - ISO strings ("2026-10-09T02:41:15.602+05:30")
///  - dd/mm/yyyy
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

  try {
    return DateTime.parse(str);
  } catch (_) {}

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

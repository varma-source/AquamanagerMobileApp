// To parse this JSON data, do
//
//     final partyadvancedata = partyadvancedataFromJson(jsonString);

import 'dart:convert';

Partyadvancedata partyadvancedataFromJson(String str) =>
    Partyadvancedata.fromJson(json.decode(str));

String partyadvancedataToJson(Partyadvancedata data) =>
    json.encode(data.toJson());

class Partyadvancedata {
  final bool? success;
  final String? message;
  final List<Datum>? data;

  Partyadvancedata({
    this.success,
    this.message,
    this.data,
  });

  factory Partyadvancedata.fromJson(Map<String, dynamic> json) =>
      Partyadvancedata(
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
  final String? userId;
  final String? partyId;
  final DateTime? date;
  final String? amount;
  final String? notes;
  final String? paymentMethod;
  final String? paymentType;   // ✅ ADD
  final String? logCreatedDate;
  final String? logModifiedDate;
  final int? v;
  final String? partyName;

  Datum({
    this.id,
    this.userId,
    this.partyId,
    this.date,
    this.amount,
    this.notes,
    this.paymentMethod,
    this.paymentType,          // ✅ ADD
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    this.partyName,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        userId: json["userId"],
        partyId: json["partyId"],
        date: _parseDate(json["date"]),
        amount: json["amount"]?.toString(),
        notes: json["notes"],
        paymentMethod: json["paymentMethod"],
        paymentType: json["paymentType"],   // ✅ ADD
        logCreatedDate: json["logCreatedDate"],
        logModifiedDate: json["logModifiedDate"],
        v: json["__v"],
        partyName: json["partyName"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "partyId": partyId,
        "date": date == null
            ? null
            : "${date!.year.toString().padLeft(4, '0')}-"
                "${date!.month.toString().padLeft(2, '0')}-"
                "${date!.day.toString().padLeft(2, '0')}",
        "amount": amount,
        "notes": notes,
        "paymentMethod": paymentMethod,
        "paymentType": paymentType,           // ✅ ADD
        "logCreatedDate": logCreatedDate,
        "logModifiedDate": logModifiedDate,
        "__v": v,
        "partyName": partyName,
      };
}

/// ✅ Safe date parser — never throws
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
// To parse this JSON data, do
//
//     final partysdropdata = partysdropdataFromJson(jsonString);

import 'dart:convert';

Partysdropdata partysdropdataFromJson(String str) =>
    Partysdropdata.fromJson(json.decode(str));

String partysdropdataToJson(Partysdropdata data) =>
    json.encode(data.toJson());

class Partysdropdata {
  final bool? success;
  final String? message;
  final int? count;
  final List<Datum>? data;

  Partysdropdata({
    this.success,
    this.message,
    this.count,
    this.data,
  });

  factory Partysdropdata.fromJson(Map<String, dynamic> json) =>
      Partysdropdata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(
                json["data"]!.map((x) => Datum.fromJson(x))),
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
  // ── existing fields (unchanged) ──
  final String? id;
  final String? name;
  final String? phone;
  final String? notes;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;

  // ── NEW fields added to match the Postman response ──
  final String? userId;
  final String? partyId;
  final String? date;
  final String? amount;
  final String? paymentType;
  final String? paymentMethod;
  final String? partyName;

  Datum({
    // existing
    this.id,
    this.name,
    this.phone,
    this.notes,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    // new
    this.userId,
    this.partyId,
    this.date,
    this.amount,
    this.paymentType,
    this.paymentMethod,
    this.partyName,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        // existing
        id: json["_id"],
        name: json["name"],
        phone: json["phone"],
        notes: json["notes"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null
            ? null
            : DateTime.tryParse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null
            ? null
            : DateTime.tryParse(json["logModifiedDate"]),
        v: json["__v"],
        // new
        userId: json["userId"],
        partyId: json["partyId"],
        date: json["date"],
        amount: json["amount"],
        paymentType: json["paymentType"],
        paymentMethod: json["paymentMethod"],
        partyName: json["partyName"],
      );

  Map<String, dynamic> toJson() => {
        // existing
        "_id": id,
        "name": name,
        "phone": phone,
        "notes": notes,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        // new
        "userId": userId,
        "partyId": partyId,
        "date": date,
        "amount": amount,
        "paymentType": paymentType,
        "paymentMethod": paymentMethod,
        "partyName": partyName,
      };
}
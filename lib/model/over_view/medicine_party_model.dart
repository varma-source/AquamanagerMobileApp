// To parse this JSON data, do
//
//     final medicinePartydata = medicinePartydataFromJson(jsonString);

import 'dart:convert';

MedicinePartydata medicinePartydataFromJson(String str) => MedicinePartydata.fromJson(json.decode(str));

String medicinePartydataToJson(MedicinePartydata data) => json.encode(data.toJson());

class MedicinePartydata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    MedicinePartydata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory MedicinePartydata.fromJson(Map<String, dynamic> json) => MedicinePartydata(
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
    final DateTime? date;
    final String? userId;
    final String? medicineId;
    final String? partyId;
    final String? amount;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    final String? medicineName;
    final String? partyName;
    final String? partyPhone;

    Datum({
        this.id,
        this.date,
        this.userId,
        this.medicineId,
        this.partyId,
        this.amount,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.medicineName,
        this.partyName,
        this.partyPhone,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        userId: json["userId"],
        medicineId: json["medicineId"],
        partyId: json["partyId"],
        amount: json["amount"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        medicineName: json["medicineName"],
        partyName: json["partyName"],
        partyPhone: json["partyPhone"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "userId": userId,
        "medicineId": medicineId,
        "partyId": partyId,
        "amount": amount,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "medicineName": medicineName,
        "partyName": partyName,
        "partyPhone": partyPhone,
    };
}

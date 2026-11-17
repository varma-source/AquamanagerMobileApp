// To parse this JSON data, do
//
//     final getfeedata = getfeedataFromJson(jsonString);

import 'dart:convert';

Getfeedata getfeedataFromJson(String str) =>
    Getfeedata.fromJson(json.decode(str));

String getfeedataToJson(Getfeedata data) => json.encode(data.toJson());

class Getfeedata {
  final bool? success;
  final String? message;
  final int? count;
  final List<Datum>? data;

  Getfeedata({
    this.success,
    this.message,
    this.count,
    this.data,
  });

  factory Getfeedata.fromJson(Map<String, dynamic> json) => Getfeedata(
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
  final String? id;
  final String? tankId;
  final String? farmId;        
  final String? purchaseId;
  final String? userId;        
  final String? staffId;       
  final String? speciesId;     
  final DateTime? date;
  final String? kg;
  final String? remarks;
  final String? feedingType; // ✅ Added from API JSON
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;
  final String? tankName;
  final String? feedName;
  final String? staffName;     

  Datum({
    this.id,
    this.tankId,
    this.farmId,
    this.purchaseId,
    this.userId,
    this.staffId,
    this.speciesId,
    this.date,
    this.kg,
    this.remarks,
    this.feedingType, // ✅ Added
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    this.tankName,
    this.feedName,
    this.staffName,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        tankId: json["tankId"],
        farmId: json["farmId"],
        purchaseId: json["purchaseId"],
        userId: json["userId"],
        staffId: json["staffId"],
        speciesId: json["speciesId"],
        date: json["date"] == null
            ? null
            : DateTime.tryParse(json["date"]),
        kg: json["kg"],
        remarks: json["remarks"],
        feedingType: json["feedingType"], // ✅ Added
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null
            ? null
            : DateTime.tryParse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null
            ? null
            : DateTime.tryParse(json["logModifiedDate"]),
        v: json["__v"],
        tankName: json["tankName"],
        feedName: json["feedName"],
        staffName: json["staffName"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankId,
        "farmId": farmId,
        "purchaseId": purchaseId,
        "userId": userId,
        "staffId": staffId,
        "speciesId": speciesId,
        "date": date == null
            ? null
            : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "kg": kg,
        "remarks": remarks,
        "feedingType": feedingType, // ✅ Added
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "tankName": tankName,
        "feedName": feedName,
        "staffName": staffName,
      };
}

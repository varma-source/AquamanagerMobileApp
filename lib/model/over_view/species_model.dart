// To parse this JSON data, do
//
//     final speciesdata = speciesdataFromJson(jsonString);

import 'dart:convert';

Speciesdata speciesdataFromJson(String str) => Speciesdata.fromJson(json.decode(str));

String speciesdataToJson(Speciesdata data) => json.encode(data.toJson());

class Speciesdata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    Speciesdata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory Speciesdata.fromJson(Map<String, dynamic> json) => Speciesdata(
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
    final String? userId;
    final String? farmId;
    final String? tankId;
    final String? speciesName;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    final String? tankName;
    final String? farmName;
    final bool? isCurrent;

    Datum({
        this.id,
        this.userId,
        this.farmId,
        this.tankId,
        this.speciesName,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.tankName,
        this.farmName,
        this.isCurrent,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        userId: json["userId"],
        farmId: json["farmId"],
        tankId: json["tankId"],
        speciesName: json["speciesName"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        tankName: json["tankName"],
        farmName: json["farmName"],
        isCurrent: json["isCurrent"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "farmId": farmId,
        "tankId": tankId,
        "speciesName": speciesName,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "tankName": tankName,
        "farmName": farmName,
        "isCurrent": isCurrent,
    };
}

// To parse this JSON data, do
//
//     final staffHomedata = staffHomedataFromJson(jsonString);

import 'dart:convert';

StaffHomedata staffHomedataFromJson(String str) => StaffHomedata.fromJson(json.decode(str));

String staffHomedataToJson(StaffHomedata data) => json.encode(data.toJson());

class StaffHomedata {
    final bool? success;
    final String? message;
    final List<Datum>? data;

    StaffHomedata({
        this.success,
        this.message,
        this.data,
    });

    factory StaffHomedata.fromJson(Map<String, dynamic> json) => StaffHomedata(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    final String? id;
    final String? farmId;
    final String? tankType;
    final String? pondSize;
    final String? tankId;
    final String? tankName;
    final String? farmName;

    Datum({
        this.id,
        this.farmId,
        this.tankType,
        this.pondSize,
        this.tankId,
        this.tankName,
        this.farmName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        farmId: json["farmId"],
        tankType: json["tankType"],
        pondSize: json["pondSize"],
        tankId: json["tankId"],
        tankName: json["tankName"],
        farmName: json["farmName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "farmId": farmId,
        "tankType": tankType,
        "pondSize": pondSize,
        "tankId": tankId,
        "tankName": tankName,
        "farmName": farmName,
    };
}

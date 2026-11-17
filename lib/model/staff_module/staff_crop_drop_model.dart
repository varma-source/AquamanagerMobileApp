// To parse this JSON data, do
//
//     final staffCropDropdata = staffCropDropdataFromJson(jsonString);

import 'dart:convert';

StaffCropDropdata staffCropDropdataFromJson(String str) => StaffCropDropdata.fromJson(json.decode(str));

String staffCropDropdataToJson(StaffCropDropdata data) => json.encode(data.toJson());

class StaffCropDropdata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Species>? species;

    StaffCropDropdata({
        this.success,
        this.message,
        this.count,
        this.species,
    });

    factory StaffCropDropdata.fromJson(Map<String, dynamic> json) => StaffCropDropdata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        species: json["species"] == null ? [] : List<Species>.from(json["species"]!.map((x) => Species.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "species": species == null ? [] : List<dynamic>.from(species!.map((x) => x.toJson())),
    };
}

class Species {
    final String? id;
    final String? userId;
    final String? farmId;
    final String? tankId;
    final String? speciesName;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final bool? isCurrent; // ✅ ADDED THIS LINE
    final String? tankName;
    final String? farmName;
    final String? userName;

    Species({
        this.id,
        this.userId,
        this.farmId,
        this.tankId,
        this.speciesName,
        this.logCreatedDate,
        this.logModifiedDate,
        this.isCurrent, // ✅ ADDED THIS LINE
        this.tankName,
        this.farmName,
        this.userName,
    });

    factory Species.fromJson(Map<String, dynamic> json) => Species(
        id: json["_id"],
        userId: json["userId"],
        farmId: json["farmId"],
        tankId: json["tankId"],
        speciesName: json["speciesName"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        isCurrent: json["isCurrent"], // ✅ ADDED THIS LINE
        tankName: json["tankName"],
        farmName: json["farmName"],
        userName: json["userName"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "farmId": farmId,
        "tankId": tankId,
        "speciesName": speciesName,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "isCurrent": isCurrent, // ✅ ADDED THIS LINE
        "tankName": tankName,
        "farmName": farmName,
        "userName": userName,
    };
}
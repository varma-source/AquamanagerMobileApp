// To parse this JSON data, do
//
//     final accountbalancedata = accountbalancedataFromJson(jsonString);

import 'dart:convert';

Accountbalancedata accountbalancedataFromJson(String str) =>
    Accountbalancedata.fromJson(json.decode(str));

String accountbalancedataToJson(Accountbalancedata data) =>
    json.encode(data.toJson());

class Accountbalancedata {
  final bool? success;
  final String? message;
  final List<Overview>? overview;

  Accountbalancedata({
    this.success,
    this.message,
    this.overview,
  });

  factory Accountbalancedata.fromJson(Map<String, dynamic> json) =>
      Accountbalancedata(
        success: json["success"],
        message: json["message"],
        overview: json["overview"] == null
            ? []
            : List<Overview>.from(
                json["overview"]!.map((x) => Overview.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "overview": overview == null
            ? []
            : List<dynamic>.from(overview!.map((x) => x.toJson())),
      };
}

class Overview {
  final String? id;
  final String? userId;
  final String? farmId;
  final String? name;
  final String? tankType;
  final String? pondSize;
  final String? address;
  final Location? location;

  // ✅ These are arrays in the JSON, not single strings
  final List<String>? staffId;
  final List<String>? staffName;

  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;

  final Summary? stockSummary;
  final Summary? medicineSummary;

  // ✅ JSON returns "" or "yyyy-MM-dd" — use String to avoid parse crashes
  final String? fromDate;
  final String? toDate;

  Overview({
    this.id,
    this.userId,
    this.farmId,
    this.name,
    this.tankType,
    this.pondSize,
    this.address,
    this.location,
    this.staffId,
    this.staffName,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    this.stockSummary,
    this.medicineSummary,
    this.fromDate,
    this.toDate,
  });

  factory Overview.fromJson(Map<String, dynamic> json) => Overview(
        id: json["_id"],
        userId: json["userId"],
        farmId: json["farmId"],
        name: json["name"],
        tankType: json["tankType"],
        pondSize: json["pondSize"],
        address: json["address"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        staffId: json["staffId"] == null
            ? []
            : List<String>.from(json["staffId"]!.map((x) => x)),
        staffName: json["staffName"] == null
            ? []
            : List<String>.from(json["staffName"]!.map((x) => x)),
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null
            ? null
            : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null
            ? null
            : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        stockSummary: json["stockSummary"] == null
            ? null
            : Summary.fromJson(json["stockSummary"]),
        medicineSummary: json["medicineSummary"] == null
            ? null
            : Summary.fromJson(json["medicineSummary"]),
        fromDate: json["fromDate"],
        toDate: json["toDate"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "farmId": farmId,
        "name": name,
        "tankType": tankType,
        "pondSize": pondSize,
        "address": address,
        "location": location?.toJson(),
        "staffId":
            staffId == null ? [] : List<dynamic>.from(staffId!.map((x) => x)),
        "staffName":
            staffName == null ? [] : List<dynamic>.from(staffName!.map((x) => x)),
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "stockSummary": stockSummary?.toJson(),
        "medicineSummary": medicineSummary?.toJson(),
        "fromDate": fromDate,
        "toDate": toDate,
      };
}

class Location {
  final String? type;
  final List<List<List<double>>>? coordinates;

  Location({
    this.type,
    this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json["type"],
        coordinates: json["coordinates"] == null
            ? []
            : List<List<List<double>>>.from(json["coordinates"]!.map((x) =>
                List<List<double>>.from(x.map((x) =>
                    List<double>.from(x.map((x) => x?.toDouble())))))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => List<dynamic>.from(
                x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
      };
}

class Summary {
  // ✅ _id can be null OR a string, not "dynamic"
  final String? id;
  final num? quantityPurchased;
  final num? totalAmount;
  final num? totalRecords;
  final num? quantityStocked;

  Summary({
    this.id,
    this.quantityPurchased,
    this.totalAmount,
    this.totalRecords,
    this.quantityStocked,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        id: json["_id"]?.toString(),
        quantityPurchased: json["quantityPurchased"],
        totalAmount: json["totalAmount"],
        totalRecords: json["totalRecords"],
        quantityStocked: json["quantityStocked"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "quantityPurchased": quantityPurchased,
        "totalAmount": totalAmount,
        "totalRecords": totalRecords,
        "quantityStocked": quantityStocked,
      };
}
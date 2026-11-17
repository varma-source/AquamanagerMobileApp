// To parse this JSON data, do
//
//     final allTankdata = allTankdataFromJson(jsonString);

import 'dart:convert';

AllTankdata allTankdataFromJson(String str) => AllTankdata.fromJson(json.decode(str));

String allTankdataToJson(AllTankdata data) => json.encode(data.toJson());

class AllTankdata {
    final bool? success;
    final String? message;
    final String? farmId;
    final int? count;
    final List<Tank>? tanks;

    AllTankdata({
        this.success,
        this.message,
        this.farmId,
        this.count,
        this.tanks,
    });

    factory AllTankdata.fromJson(Map<String, dynamic> json) => AllTankdata(
        success: json["success"],
        message: json["message"],
        farmId: json["farmId"],
        count: json["count"],
        tanks: json["tanks"] == null ? [] : List<Tank>.from(json["tanks"]!.map((x) => Tank.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "farmId": farmId,
        "count": count,
        "tanks": tanks == null ? [] : List<dynamic>.from(tanks!.map((x) => x.toJson())),
    };
}

class Tank {
  final String? id;
  final String? userId;
  final String? farmId;
  final String? name;
  final String? tankType;
  final String? pondSize;
  final String? address;
  final Location? location;
  final List<String>? staffId; 
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;
  final List<String>? staffName;
  final HarvestSummary? harvestSummary;
  final PurchaseSummary? purchaseSummary;

  Tank({
    this.id,
    this.userId,
    this.farmId,
    this.name,
    this.tankType,
    this.pondSize,
    this.address,
    this.location,
    this.staffId,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    this.staffName,
    this.harvestSummary,
    this.purchaseSummary,
  });

  factory Tank.fromJson(Map<String, dynamic> json) {
    // ✅ Safely parse staffId whether it's a String, a List of Strings, or a List of Objects
    List<String>? parsedStaffIds;
    if (json["staffId"] != null) {
      if (json["staffId"] is String) {
        parsedStaffIds = [json["staffId"]];
      } else if (json["staffId"] is List) {
        parsedStaffIds = (json["staffId"] as List).map((x) {
          if (x is Map && x.containsKey('_id')) {
            return x['_id'].toString();
          }
          return x.toString();
        }).toList();
      }
    }

    return Tank(
      id: json["_id"],
      userId: json["userId"],
      farmId: json["farmId"],
      name: json["name"],
      tankType: json["tankType"],
      pondSize: json["pondSize"],
      address: json["address"],
      location: json["location"] == null ? null : Location.fromJson(json["location"]),
      staffId: parsedStaffIds, 
      status: json["status"],
      logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
      logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
      v: json["__v"],
      staffName: json["staffName"] == null ? [] : List<String>.from(json["staffName"]!.map((x) => x)),
      harvestSummary: json["harvestSummary"] == null ? null : HarvestSummary.fromJson(json["harvestSummary"]),
      purchaseSummary: json["purchaseSummary"] == null ? null : PurchaseSummary.fromJson(json["purchaseSummary"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "farmId": farmId,
    "name": name,
    "tankType": tankType,
    "pondSize": pondSize,
    "address": address,
    "location": location?.toJson(),
    "staffId": staffId == null ? [] : List<dynamic>.from(staffId!.map((x) => x)),
    "status": status,
    "logCreatedDate": logCreatedDate?.toIso8601String(),
    "logModifiedDate": logModifiedDate?.toIso8601String(),
    "__v": v,
    "staffName": staffName == null ? [] : List<dynamic>.from(staffName!.map((x) => x)),
    "harvestSummary": harvestSummary?.toJson(),
    "purchaseSummary": purchaseSummary?.toJson(),
  };
}

class HarvestSummary {
    // ✅ Changed from int? to double? and added safe parsing
    final double? totalRecords;
    final double? totalQuantityHarvested;
    final double? totalAmount;

    HarvestSummary({
        this.totalRecords,
        this.totalQuantityHarvested,
        this.totalAmount,
    });

    factory HarvestSummary.fromJson(Map<String, dynamic> json) => HarvestSummary(
        totalRecords: json["totalRecords"] == null ? null : double.tryParse(json["totalRecords"].toString()),
        totalQuantityHarvested: json["totalQuantityHarvested"] == null ? null : double.tryParse(json["totalQuantityHarvested"].toString()),
        totalAmount: json["totalAmount"] == null ? null : double.tryParse(json["totalAmount"].toString()),
    );

    Map<String, dynamic> toJson() => {
        "totalRecords": totalRecords,
        "totalQuantityHarvested": totalQuantityHarvested,
        "totalAmount": totalAmount,
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
        coordinates: json["coordinates"] == null ? [] : List<List<List<double>>>.from(json["coordinates"]!.map((x) => List<List<double>>.from(x.map((x) => List<double>.from(x.map((x) => x?.toDouble())))))) ,
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => List<dynamic>.from(x.map((x) => List<dynamic>.from(x.map((x) => x)))))) ,
    };
}

class PurchaseSummary {
    // ✅ Changed from int? to double? and added safe parsing
    final double? totalPurchaseRecords;
    final double? totalQuantityPurchased;
    final double? totalPurchaseAmount;

    PurchaseSummary({
        this.totalPurchaseRecords,
        this.totalQuantityPurchased,
        this.totalPurchaseAmount,
    });

    factory PurchaseSummary.fromJson(Map<String, dynamic> json) => PurchaseSummary(
        totalPurchaseRecords: json["totalPurchaseRecords"] == null ? null : double.tryParse(json["totalPurchaseRecords"].toString()),
        totalQuantityPurchased: json["totalQuantityPurchased"] == null ? null : double.tryParse(json["totalQuantityPurchased"].toString()),
        totalPurchaseAmount: json["totalPurchaseAmount"] == null ? null : double.tryParse(json["totalPurchaseAmount"].toString()),
    );

    Map<String, dynamic> toJson() => {
        "totalPurchaseRecords": totalPurchaseRecords,
        "totalQuantityPurchased": totalQuantityPurchased,
        "totalPurchaseAmount": totalPurchaseAmount,
    };
}
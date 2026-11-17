// To parse this JSON data, do
//
//     final hometankoverviewdata = hometankoverviewdataFromJson(jsonString);

import 'dart:convert';

Hometankoverviewdata hometankoverviewdataFromJson(String str) => Hometankoverviewdata.fromJson(json.decode(str));

String hometankoverviewdataToJson(Hometankoverviewdata data) => json.encode(data.toJson());

class Hometankoverviewdata {
    final bool? success;
    final String? message;
    final List<Overview>? overview;

    Hometankoverviewdata({
        this.success,
        this.message,
        this.overview,
    });

    factory Hometankoverviewdata.fromJson(Map<String, dynamic> json) => Hometankoverviewdata(
        success: json["success"],
        message: json["message"],
        overview: json["overview"] == null ? [] : List<Overview>.from(json["overview"]!.map((x) => Overview.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "overview": overview == null ? [] : List<dynamic>.from(overview!.map((x) => x.toJson())),
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
    
    // ✅ Changed to List<String> to match the API response array
    final List<String>? staffId; 
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    
    // ✅ Changed to List<String> to match the API response array
    final List<String>? staffName; 
    final List<Stock>? stocks;

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
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.staffName,
        this.stocks,
    });

    factory Overview.fromJson(Map<String, dynamic> json) => Overview(
        id: json["_id"],
        userId: json["userId"],
        farmId: json["farmId"],
        name: json["name"],
        tankType: json["tankType"],
        pondSize: json["pondSize"],
        address: json["address"],
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        
        // ✅ Safely parse arrays
        staffId: json["staffId"] == null ? [] : List<String>.from(json["staffId"]!.map((x) => x)),
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        
        // ✅ Safely parse arrays
        staffName: json["staffName"] == null ? [] : List<String>.from(json["staffName"]!.map((x) => x)),
        stocks: json["stocks"] == null ? [] : List<Stock>.from(json["stocks"]!.map((x) => Stock.fromJson(x))),
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
        
        // ✅ Serialize as arrays
        "staffId": staffId == null ? [] : List<dynamic>.from(staffId!.map((x) => x)),
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        
        // ✅ Serialize as arrays
        "staffName": staffName == null ? [] : List<dynamic>.from(staffName!.map((x) => x)),
        "stocks": stocks == null ? [] : List<dynamic>.from(stocks!.map((x) => x.toJson())),
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
        coordinates: json["coordinates"] == null ? [] : List<List<List<double>>>.from(json["coordinates"]!.map((x) => List<List<double>>.from(x.map((x) => List<double>.from(x.map((x) => x?.toDouble())))))),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => List<dynamic>.from(x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
    };
}

class Stock {
    final String? id;
    final String? tankId;
    final String? date;
    final String? speciesName;
    final String? cropName;
    final String? quantityStocked;
    final String? averageWeightAtStocking;
    final String? stockingCostPerUnit;
    final String? supplier;
    final String? notes;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;
    final String? userId;
    final String? totalAmount;

    Stock({
        this.id,
        this.tankId,
        this.date,
        this.speciesName,
        this.cropName,
        this.quantityStocked,
        this.averageWeightAtStocking,
        this.stockingCostPerUnit,
        this.supplier,
        this.notes,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.createdAt,
        this.updatedAt,
        this.v,
        this.userId,
        this.totalAmount,
    });

    factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        id: json["_id"],
        tankId: json["tankId"],
        date: json["date"],
        speciesName: json["speciesName"],
        cropName: json["cropName"],
        quantityStocked: json["quantityStocked"],
        averageWeightAtStocking: json["averageWeightAtStocking"],
        stockingCostPerUnit: json["stockingCostPerUnit"],
        supplier: json["supplier"],
        notes: json["notes"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        userId: json["userId"],
        totalAmount: json["totalAmount"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankId,
        "date": date,
        "speciesName": speciesName,
        "cropName": cropName,
        "quantityStocked": quantityStocked,
        "averageWeightAtStocking": averageWeightAtStocking,
        "stockingCostPerUnit": stockingCostPerUnit,
        "supplier": supplier,
        "notes": notes,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "userId": userId,
        "totalAmount": totalAmount,
    };
}
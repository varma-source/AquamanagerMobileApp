// To parse this JSON data, do
//
//     final getformdata = getformdataFromJson(jsonString);

import 'dart:convert';

Getformdata getformdataFromJson(String str) => Getformdata.fromJson(json.decode(str));

String getformdataToJson(Getformdata data) => json.encode(data.toJson());

class Getformdata {
    final bool? success;
    final String? message;
    final int? totalFarms;
    final List<Datum>? data;

    Getformdata({
        this.success,
        this.message,
        this.totalFarms,
        this.data,
    });

    factory Getformdata.fromJson(Map<String, dynamic> json) => Getformdata(
        success: json["success"],
        message: json["message"],
        totalFarms: json["totalFarms"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "totalFarms": totalFarms,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    final Location? location;
    final String? id;
    final String? userId;
    final DateTime? date;
    final String? farmName;
    final String? farmLocation;
    final String? currency;
    final String? status;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;

    Datum({
        this.location,
        this.id,
        this.userId,
        this.date,
        this.farmName,
        this.farmLocation,
        this.currency,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        id: json["_id"],
        userId: json["userId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        farmName: json["farmName"],
        farmLocation: json["farmLocation"],
        currency: json["currency"],
        status: json["status"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "_id": id,
        "userId": userId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "farmName": farmName,
        "farmLocation": farmLocation,
        "currency": currency,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
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

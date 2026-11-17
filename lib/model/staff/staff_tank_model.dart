import 'dart:convert';

Stafftankdata stafftankdataFromJson(String str) => Stafftankdata.fromJson(json.decode(str));

String stafftankdataToJson(Stafftankdata data) => json.encode(data.toJson());

class Stafftankdata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Datum>? data;

    Stafftankdata({
        this.success,
        this.message,
        this.count,
        this.data,
    });

    factory Stafftankdata.fromJson(Map<String, dynamic> json) => Stafftankdata(
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
    final Location? location;
    final String? id;
    final String? userId;
    final String? farmId;
    final String? name;
    final String? tankType;
    final String? pondSize;
    final String? address;
    
    // ✅ Changed to List<String>?
    final List<String>? staffId; 
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;

    Datum({
        this.location,
        this.id,
        this.userId,
        this.farmId,
        this.name,
        this.tankType,
        this.pondSize,
        this.address,
        this.staffId,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
    });

    factory Datum.fromJson(Map<String, dynamic> json) {
      // ✅ Safely parse staffId
      List<String>? parsedStaffIds;
      if (json["staffId"] != null) {
        if (json["staffId"] is String) {
          parsedStaffIds = [json["staffId"]];
        } else if (json["staffId"] is List) {
          parsedStaffIds = (json["staffId"] as List).map((x) {
            if (x is Map && x.containsKey('_id')) return x['_id'].toString();
            return x.toString();
          }).toList();
        }
      }

      return Datum(
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        id: json["_id"],
        userId: json["userId"],
        farmId: json["farmId"],
        name: json["name"],
        tankType: json["tankType"],
        pondSize: json["pondSize"],
        address: json["address"],
        staffId: parsedStaffIds,
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
      );
    }

    Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "_id": id,
        "userId": userId,
        "farmId": farmId,
        "name": name,
        "tankType": tankType,
        "pondSize": pondSize,
        "address": address,
        "staffId": staffId == null ? [] : List<dynamic>.from(staffId!.map((x) => x)),
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
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
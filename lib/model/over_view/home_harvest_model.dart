// To parse this JSON data, do
//
//     final homeharvestdata = homeharvestdataFromJson(jsonString);

import 'dart:convert';

Homeharvestdata homeharvestdataFromJson(String str) => Homeharvestdata.fromJson(json.decode(str));

String homeharvestdataToJson(Homeharvestdata data) => json.encode(data.toJson());

class Homeharvestdata {
    final bool? success;
    final Data? data;

    Homeharvestdata({
        this.success,
        this.data,
    });

    factory Homeharvestdata.fromJson(Map<String, dynamic> json) => Homeharvestdata(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    final int? totalRecords;
    final int? totalQuantityHarvested;
    final int? totalAmount;

    Data({
        this.totalRecords,
        this.totalQuantityHarvested,
        this.totalAmount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalRecords: json["totalRecords"],
        totalQuantityHarvested: json["totalQuantityHarvested"],
        totalAmount: json["totalAmount"],
    );

    Map<String, dynamic> toJson() => {
        "totalRecords": totalRecords,
        "totalQuantityHarvested": totalQuantityHarvested,
        "totalAmount": totalAmount,
    };
}

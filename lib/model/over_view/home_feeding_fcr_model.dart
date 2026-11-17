// To parse this JSON data, do
//
//     final feedingandfcrdata = feedingandfcrdataFromJson(jsonString);

import 'dart:convert';

Feedingandfcrdata feedingandfcrdataFromJson(String str) => Feedingandfcrdata.fromJson(json.decode(str));

String feedingandfcrdataToJson(Feedingandfcrdata data) => json.encode(data.toJson());

class Feedingandfcrdata {
    final bool? success;
    final Data? data;

    Feedingandfcrdata({
        this.success,
        this.data,
    });

    factory Feedingandfcrdata.fromJson(Map<String, dynamic> json) => Feedingandfcrdata(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    final int? todaysFeed;
    final int? cumulativeFeed;
    final int? firstBiomass;
    final int? latestBiomass;
    final DateTime? latestLogCreatedDate;
    final double? estimatedFcr;

    Data({
        this.todaysFeed,
        this.cumulativeFeed,
        this.firstBiomass,
        this.latestBiomass,
        this.latestLogCreatedDate,
        this.estimatedFcr,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        todaysFeed: json["todaysFeed"],
        cumulativeFeed: json["cumulativeFeed"],
        firstBiomass: json["firstBiomass"],
        latestBiomass: json["latestBiomass"],
        latestLogCreatedDate: json["latestLogCreatedDate"] == null ? null : DateTime.parse(json["latestLogCreatedDate"]),
        estimatedFcr: json["estimatedFcr"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "todaysFeed": todaysFeed,
        "cumulativeFeed": cumulativeFeed,
        "firstBiomass": firstBiomass,
        "latestBiomass": latestBiomass,
        "latestLogCreatedDate": latestLogCreatedDate?.toIso8601String(),
        "estimatedFcr": estimatedFcr,
    };
}

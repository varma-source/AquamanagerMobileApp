// To parse this JSON data, do
//
//     final feedingstockdata = feedingstockdataFromJson(jsonString);

import 'dart:convert';

Feedingstockdata feedingstockdataFromJson(String str) => Feedingstockdata.fromJson(json.decode(str));

String feedingstockdataToJson(Feedingstockdata data) => json.encode(data.toJson());

class Feedingstockdata {
    final bool? success;
    final Data? data;

    Feedingstockdata({
        this.success,
        this.data,
    });

    factory Feedingstockdata.fromJson(Map<String, dynamic> json) => Feedingstockdata(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
    };
}

class Data {
    final int? totalPurchased;
    final int? totalPurchaseAmount;
    final double? averageCostPerKg;
    final int? totalConsumed;
    final double? consumedFeedValue;
    final int? closingStock;
    final double? closingStockValue;

    Data({
        this.totalPurchased,
        this.totalPurchaseAmount,
        this.averageCostPerKg,
        this.totalConsumed,
        this.consumedFeedValue,
        this.closingStock,
        this.closingStockValue,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalPurchased: json["totalPurchased"],
        totalPurchaseAmount: json["totalPurchaseAmount"],
        averageCostPerKg: json["averageCostPerKg"]?.toDouble(),
        totalConsumed: json["totalConsumed"],
        consumedFeedValue: json["consumedFeedValue"]?.toDouble(),
        closingStock: json["closingStock"],
        closingStockValue: json["closingStockValue"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "totalPurchased": totalPurchased,
        "totalPurchaseAmount": totalPurchaseAmount,
        "averageCostPerKg": averageCostPerKg,
        "totalConsumed": totalConsumed,
        "consumedFeedValue": consumedFeedValue,
        "closingStock": closingStock,
        "closingStockValue": closingStockValue,
    };
}

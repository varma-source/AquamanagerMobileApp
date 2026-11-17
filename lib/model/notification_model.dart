// To parse this JSON data, do
//
//     final notificationsdata = notificationsdataFromJson(jsonString);

import 'dart:convert';

Notificationsdata notificationsdataFromJson(String str) => Notificationsdata.fromJson(json.decode(str));

String notificationsdataToJson(Notificationsdata data) => json.encode(data.toJson());

class Notificationsdata {
    final bool? success;
    final String? message;
    final List<NotifResult>? notifResult;

    Notificationsdata({
        this.success,
        this.message,
        this.notifResult,
    });

    factory Notificationsdata.fromJson(Map<String, dynamic> json) => Notificationsdata(
        success: json["success"],
        message: json["message"],
        notifResult: json["notifResult"] == null ? [] : List<NotifResult>.from(json["notifResult"]!.map((x) => NotifResult.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "notifResult": notifResult == null ? [] : List<dynamic>.from(notifResult!.map((x) => x.toJson())),
    };
}

class NotifResult {
    final String? id;
    final DateTime? date;
    final String? time;
    final String? title;
    final String? description;
    final String? sendTo;
    final String? isdeleted;
    final bool? seen;
    final String? staffId;
    final String? staffRequestAdvanceId;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final int? v;
    final String? tankId;
    final String? harvestId;
    final String? staffExpenseId;
    final String? purchaseId;
    final String? logFeedingId;
    final String? medicineId;
    final String? medicineUsageId;

    NotifResult({
        this.id,
        this.date,
        this.time,
        this.title,
        this.description,
        this.sendTo,
        this.isdeleted,
        this.seen,
        this.staffId,
        this.staffRequestAdvanceId,
        this.logCreatedDate,
        this.logModifiedDate,
        this.v,
        this.tankId,
        this.harvestId,
        this.staffExpenseId,
        this.purchaseId,
        this.logFeedingId,
        this.medicineId,
        this.medicineUsageId,
    });

    factory NotifResult.fromJson(Map<String, dynamic> json) => NotifResult(
        id: json["_id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        time: json["time"],
        title: json["title"],
        description: json["description"],
        sendTo: json["sendTo"],
        isdeleted: json["isdeleted"],
        seen: json["seen"],
        staffId: json["staffId"],
        staffRequestAdvanceId: json["staffRequestAdvanceId"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        v: json["__v"],
        tankId: json["tankId"],
        harvestId: json["harvestId"],
        staffExpenseId: json["staffExpenseId"],
        purchaseId: json["purchaseId"],
        logFeedingId: json["logFeedingId"],
        medicineId: json["medicineId"],
        medicineUsageId: json["medicineUsageId"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "time": time,
        "title": title,
        "description": description,
        "sendTo": sendTo,
        "isdeleted": isdeleted,
        "seen": seen,
        "staffId": staffId,
        "staffRequestAdvanceId": staffRequestAdvanceId,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "tankId": tankId,
        "harvestId": harvestId,
        "staffExpenseId": staffExpenseId,
        "purchaseId": purchaseId,
        "logFeedingId": logFeedingId,
        "medicineId": medicineId,
        "medicineUsageId": medicineUsageId,
    };
}

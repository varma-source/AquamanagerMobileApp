// To parse this JSON data, do
//
//     final profiledata = profiledataFromJson(jsonString);

import 'dart:convert';

Profiledata profiledataFromJson(String str) =>
    Profiledata.fromJson(json.decode(str));

String profiledataToJson(Profiledata data) => json.encode(data.toJson());

class Profiledata {
  final bool? success;
  final Data? data;

  Profiledata({
    this.success,
    this.data,
  });

  factory Profiledata.fromJson(Map<String, dynamic> json) => Profiledata(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

class Data {
  final Location? location;
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? image;
  final String? password;

  // ✅ these may not be returned by profile API — kept for compatibility
  final String? farmName;
  final String? farmLocation;
  final String? currency;

  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  // ✅ added
  final String? role;      // "owner" / "staff" / "manager" etc.
  final String? fcmToken;  // firebase cloud messaging token

  final Policy? policy;
  final AboutUs? aboutUs;
  final List<Faq>? faqs;

  Data({
    this.location,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.image,
    this.password,
    this.farmName,
    this.farmLocation,
    this.currency,
    this.logCreatedDate,
    this.logModifiedDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.role,
    this.fcmToken,
    this.policy,
    this.aboutUs,
    this.faqs,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        image: json["image"],
        password: json["password"],
        farmName: json["farmName"],
        farmLocation: json["farmLocation"],
        currency: json["currency"],
        logCreatedDate: json["logCreatedDate"] == null
            ? null
            : DateTime.tryParse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null
            ? null
            : DateTime.tryParse(json["logModifiedDate"]),
        status: json["status"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"]),
        v: json["__v"],
        role: json["role"],           // ✅
        fcmToken: json["fcmToken"],   // ✅
        policy:
            json["policy"] == null ? null : Policy.fromJson(json["policy"]),
        aboutUs: json["aboutUs"] == null
            ? null
            : AboutUs.fromJson(json["aboutUs"]),
        faqs: json["faqs"] == null
            ? []
            : List<Faq>.from(json["faqs"]!.map((x) => Faq.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "location": location?.toJson(),
        "_id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "image": image,
        "password": password,
        "farmName": farmName,
        "farmLocation": farmLocation,
        "currency": currency,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "role": role,
        "fcmToken": fcmToken,
        "policy": policy?.toJson(),
        "aboutUs": aboutUs?.toJson(),
        "faqs": faqs == null
            ? []
            : List<dynamic>.from(faqs!.map((x) => x.toJson())),
      };
}

class AboutUs {
  final String? email;
  final String? phone;

  AboutUs({
    this.email,
    this.phone,
  });

  factory AboutUs.fromJson(Map<String, dynamic> json) => AboutUs(
        email: json["email"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "phone": phone,
      };
}

class Faq {
  final String? id;
  final String? question;
  final String? answer;
  final String? priority;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;

  Faq({
    this.id,
    this.question,
    this.answer,
    this.priority,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
        id: json["_id"],
        question: json["question"],
        answer: json["answer"],
        priority: json["priority"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null
            ? null
            : DateTime.tryParse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null
            ? null
            : DateTime.tryParse(json["logModifiedDate"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "question": question,
        "answer": answer,
        "priority": priority,
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

class Policy {
  final String? termsAndCondition;
  final String? privacyPolicy;
  final String? aboutus;

  Policy({
    this.termsAndCondition,
    this.privacyPolicy,
    this.aboutus,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
        termsAndCondition: json["termsAndCondition"],
        privacyPolicy: json["privacyPolicy"],
        aboutus: json["aboutus"],
      );

  Map<String, dynamic> toJson() => {
        "termsAndCondition": termsAndCondition,
        "privacyPolicy": privacyPolicy,
        "aboutus": aboutus,
      };
}
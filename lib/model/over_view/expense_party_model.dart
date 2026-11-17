// To parse this JSON data, do
//
//     final expensePartyData = expensePartyDataFromJson(jsonString);

import 'dart:convert';

ExpensePartyData expensePartyDataFromJson(String str) => ExpensePartyData.fromJson(json.decode(str));

String expensePartyDataToJson(ExpensePartyData data) => json.encode(data.toJson());

class ExpensePartyData {
    final bool? success;
    final String? message;
    final List<Datum>? data;

    ExpensePartyData({
        this.success,
        this.message,
        this.data,
    });

    factory ExpensePartyData.fromJson(Map<String, dynamic> json) => ExpensePartyData(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    final String? id;
    final DateTime? date;
    final String? userId;
    final String? expenseId;
    final String? partyId;
    final String? category;
    final String? amount;
    final String? status;
    final DateTime? logCreatedDate;
    final DateTime? logModifiedDate;
    final String? partyName;
    final Expense? expense;

    Datum({
        this.id,
        this.date,
        this.userId,
        this.expenseId,
        this.partyId,
        this.category,
        this.amount,
        this.status,
        this.logCreatedDate,
        this.logModifiedDate,
        this.partyName,
        this.expense,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        userId: json["userId"],
        expenseId: json["expenseId"],
        partyId: json["partyId"],
        category: json["category"],
        amount: json["amount"],
        status: json["status"],
        logCreatedDate: json["logCreatedDate"] == null ? null : DateTime.parse(json["logCreatedDate"]),
        logModifiedDate: json["logModifiedDate"] == null ? null : DateTime.parse(json["logModifiedDate"]),
        partyName: json["partyName"],
        expense: json["expense"] == null ? null : Expense.fromJson(json["expense"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "userId": userId,
        "expenseId": expenseId,
        "partyId": partyId,
        "category": category,
        "amount": amount,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "partyName": partyName,
        "expense": expense?.toJson(),
    };
}

class Expense {
    final String? id;
    final String? tankId;
    final String? createdBy;
    final String? farmId;
    final DateTime? date;
    final String? category;
    final Labour? labour;
    final Salary? salary;
    final Diesel? tiffinsMeals;
    final Diesel? petrol;
    final Diesel? diesel;
    final Diesel? electrical;
    final Plumbing? plumbing;
    final Diesel? transport;
    final Diesel? utilities;
    final Diesel? other;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int? v;

    Expense({
        this.id,
        this.tankId,
        this.createdBy,
        this.farmId,
        this.date,
        this.category,
        this.labour,
        this.salary,
        this.tiffinsMeals,
        this.petrol,
        this.diesel,
        this.electrical,
        this.plumbing,
        this.transport,
        this.utilities,
        this.other,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json["_id"],
        tankId: json["tankId"],
        createdBy: json["createdBy"],
        farmId: json["farmId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        category: json["category"],
        labour: json["labour"] == null ? null : Labour.fromJson(json["labour"]),
        salary: json["Salary"] == null ? null : Salary.fromJson(json["Salary"]),
        tiffinsMeals: json["TiffinsMeals"] == null ? null : Diesel.fromJson(json["TiffinsMeals"]),
        petrol: json["Petrol"] == null ? null : Diesel.fromJson(json["Petrol"]),
        diesel: json["Diesel"] == null ? null : Diesel.fromJson(json["Diesel"]),
        electrical: json["Electrical"] == null ? null : Diesel.fromJson(json["Electrical"]),
        plumbing: json["Plumbing"] == null ? null : Plumbing.fromJson(json["Plumbing"]),
        transport: json["Transport"] == null ? null : Diesel.fromJson(json["Transport"]),
        utilities: json["Utilities"] == null ? null : Diesel.fromJson(json["Utilities"]),
        other: json["Other"] == null ? null : Diesel.fromJson(json["Other"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankId,
        "createdBy": createdBy,
        "farmId": farmId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "category": category,
        "labour": labour?.toJson(),
        "Salary": salary?.toJson(),
        "TiffinsMeals": tiffinsMeals?.toJson(),
        "Petrol": petrol?.toJson(),
        "Diesel": diesel?.toJson(),
        "Electrical": electrical?.toJson(),
        "Plumbing": plumbing?.toJson(),
        "Transport": transport?.toJson(),
        "Utilities": utilities?.toJson(),
        "Other": other?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class Diesel {
    final String? receiptImage;

    Diesel({
        this.receiptImage,
    });

    factory Diesel.fromJson(Map<String, dynamic> json) => Diesel(
        receiptImage: json["receiptImage"],
    );

    Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
    };
}

class Labour {
    final String? receiptImage;
    final String? noofpersonsWorked;
    final String? chargesPerPerson;
    final String? extras;
    final String? totalLabourCost;
    final String? notes;
    final String? partyId;

    Labour({
        this.receiptImage,
        this.noofpersonsWorked,
        this.chargesPerPerson,
        this.extras,
        this.totalLabourCost,
        this.notes,
        this.partyId,
    });

    factory Labour.fromJson(Map<String, dynamic> json) => Labour(
        receiptImage: json["receiptImage"],
        noofpersonsWorked: json["noofpersonsWorked"],
        chargesPerPerson: json["chargesPerPerson"],
        extras: json["Extras"],
        totalLabourCost: json["TotalLabourCost"],
        notes: json["Notes"],
        partyId: json["partyId"],
    );

    Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "noofpersonsWorked": noofpersonsWorked,
        "chargesPerPerson": chargesPerPerson,
        "Extras": extras,
        "TotalLabourCost": totalLabourCost,
        "Notes": notes,
        "partyId": partyId,
    };
}

class Plumbing {
    final String? itemName;
    final int? quantity;
    final int? pricePerQuantity;
    final int? total;
    final String? notes;
    final String? partyId;
    final String? receiptImage;

    Plumbing({
        this.itemName,
        this.quantity,
        this.pricePerQuantity,
        this.total,
        this.notes,
        this.partyId,
        this.receiptImage,
    });

    factory Plumbing.fromJson(Map<String, dynamic> json) => Plumbing(
        itemName: json["itemName"],
        quantity: json["quantity"],
        pricePerQuantity: json["pricePerQuantity"],
        total: json["total"],
        notes: json["notes"],
        partyId: json["partyId"],
        receiptImage: json["receiptImage"],
    );

    Map<String, dynamic> toJson() => {
        "itemName": itemName,
        "quantity": quantity,
        "pricePerQuantity": pricePerQuantity,
        "total": total,
        "notes": notes,
        "partyId": partyId,
        "receiptImage": receiptImage,
    };
}

class Salary {
    final String? notes;
    final String? receiptImage;
    final List<dynamic>? persons;

    Salary({
        this.notes,
        this.receiptImage,
        this.persons,
    });

    factory Salary.fromJson(Map<String, dynamic> json) => Salary(
        notes: json["notes"],
        receiptImage: json["receiptImage"],
        persons: json["persons"] == null ? [] : List<dynamic>.from(json["persons"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "notes": notes,
        "receiptImage": receiptImage,
        "persons": persons == null ? [] : List<dynamic>.from(persons!.map((x) => x)),
    };
}

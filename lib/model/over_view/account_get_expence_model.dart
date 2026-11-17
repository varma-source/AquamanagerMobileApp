// To parse this JSON data, do
//
//     final accountGetExpensedata = accountGetExpensedataFromJson(jsonString);

import 'dart:convert';

AccountGetExpensedata accountGetExpensedataFromJson(String str) =>
    AccountGetExpensedata.fromJson(json.decode(str));

String accountGetExpensedataToJson(AccountGetExpensedata data) =>
    json.encode(data.toJson());

class AccountGetExpensedata {
  final bool? success;
  final String? message;
  final int? count;
  final List<Datum>? data;

  AccountGetExpensedata({
    this.success,
    this.message,
    this.count,
    this.data,
  });

  factory AccountGetExpensedata.fromJson(Map<String, dynamic> json) =>
      AccountGetExpensedata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(
                json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  final String? id;
  final String? tankId;
  final String? createdBy;
  final String? farmId;
  final String? staffId;
  final String? staffName;      // ✅ was StaffName enum
  final DateTime? date;
  final String? status;          // ✅ was Status enum
  final String? category;

  final Labour? labour;
  final Salary? salary;
  final ExpenseItem? tiffinsMeals;
  final ExpenseItem? petrol;
  final ExpenseItem? diesel;
  final Electrical? electrical;
  final Plumbing? plumbing;
  final ExpenseItem? transport;
  final ExpenseItem? utilities;
  final ExpenseItem? other;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Datum({
    this.id,
    this.tankId,
    this.createdBy,
    this.farmId,
    this.staffId,
    this.staffName,
    this.date,
    this.status,
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

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        tankId: json["tankId"],
        createdBy: json["createdBy"],
        farmId: json["farmId"],
        staffId: json["staffId"],
        staffName: json["staffName"],
        date: json["date"] == null ? null : DateTime.tryParse(json["date"]),
        status: json["status"],
        category: json["category"],
        labour:
            json["labour"] == null ? null : Labour.fromJson(json["labour"]),
        salary:
            json["Salary"] == null ? null : Salary.fromJson(json["Salary"]),
        tiffinsMeals: json["TiffinsMeals"] == null
            ? null
            : ExpenseItem.fromJson(json["TiffinsMeals"]),
        petrol: json["Petrol"] == null
            ? null
            : ExpenseItem.fromJson(json["Petrol"]),
        diesel: json["Diesel"] == null
            ? null
            : ExpenseItem.fromJson(json["Diesel"]),
        electrical: json["Electrical"] == null
            ? null
            : Electrical.fromJson(json["Electrical"]),
        plumbing: json["Plumbing"] == null
            ? null
            : Plumbing.fromJson(json["Plumbing"]),
        transport: json["Transport"] == null
            ? null
            : ExpenseItem.fromJson(json["Transport"]),
        utilities: json["Utilities"] == null
            ? null
            : ExpenseItem.fromJson(json["Utilities"]),
        other: json["Other"] == null
            ? null
            : ExpenseItem.fromJson(json["Other"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankId,
        "createdBy": createdBy,
        "farmId": farmId,
        "staffId": staffId,
        "staffName": staffName,
        "date": date == null
            ? null
            : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "status": status,
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

// ═══════════════════════════════════════════════════════════════
// EXPENSE ITEM — generic for TiffinsMeals / Petrol / Diesel /
//                Transport / Utilities / Other
// ═══════════════════════════════════════════════════════════════
class ExpenseItem {
  final String? receiptImage;
  final String? description;
  final num? amount;

  ExpenseItem({
    this.receiptImage,
    this.description,
    this.amount,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        receiptImage: json["receiptImage"],
        description: json["description"],
        amount: json["amount"] ?? json["Amount"],
      );

  Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "description": description,
        "amount": amount,
      };
}

// ═══════════════════════════════════════════════════════════════
// ELECTRICAL
// ═══════════════════════════════════════════════════════════════
class Electrical {
  final String? receiptImage;
  final String? itemName;
  final String? unit;
  final num? quantity;
  final num? pricePerUnit;
  final num? total;
  final String? notes;

  Electrical({
    this.receiptImage,
    this.itemName,
    this.unit,
    this.quantity,
    this.pricePerUnit,
    this.total,
    this.notes,
  });

  factory Electrical.fromJson(Map<String, dynamic> json) => Electrical(
        receiptImage: json["receiptImage"],
        itemName: json["itemName"],
        unit: json["unit"],
        quantity: json["Quantity"],
        pricePerUnit: json["pricePerUnit"],
        total: json["Total"],
        notes: json["Notes"],
      );

  Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "itemName": itemName,
        "unit": unit,
        "Quantity": quantity,
        "pricePerUnit": pricePerUnit,
        "Total": total,
        "Notes": notes,
      };
}

// ═══════════════════════════════════════════════════════════════
// LABOUR
// ═══════════════════════════════════════════════════════════════
class Labour {
  final String? noofpersonsWorked;
  final String? chargesPerPerson;
  final String? extras;
  final String? totalLabourCost;
  final String? notes;
  final String? receiptImage;

  Labour({
    this.noofpersonsWorked,
    this.chargesPerPerson,
    this.extras,
    this.totalLabourCost,
    this.notes,
    this.receiptImage,
  });

  factory Labour.fromJson(Map<String, dynamic> json) => Labour(
        noofpersonsWorked: json["noofpersonsWorked"],
        chargesPerPerson: json["chargesPerPerson"],
        extras: json["Extras"],
        totalLabourCost: json["TotalLabourCost"],
        notes: json["Notes"],
        receiptImage: json["receiptImage"],
      );

  Map<String, dynamic> toJson() => {
        "noofpersonsWorked": noofpersonsWorked,
        "chargesPerPerson": chargesPerPerson,
        "Extras": extras,
        "TotalLabourCost": totalLabourCost,
        "Notes": notes,
        "receiptImage": receiptImage,
      };
}

// ═══════════════════════════════════════════════════════════════
// PLUMBING
// ═══════════════════════════════════════════════════════════════
class Plumbing {
  final String? notes;
  final String? receiptImage;
  final String? itemName;
  final num? quantity;
  final num? pricePerQuantity;
  final num? total;

  Plumbing({
    this.notes,
    this.receiptImage,
    this.itemName,
    this.quantity,
    this.pricePerQuantity,
    this.total,
  });

  factory Plumbing.fromJson(Map<String, dynamic> json) => Plumbing(
        notes: json["notes"],
        receiptImage: json["receiptImage"],
        itemName: json["itemName"],
        quantity: json["quantity"],
        pricePerQuantity: json["pricePerQuantity"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "notes": notes,
        "receiptImage": receiptImage,
        "itemName": itemName,
        "quantity": quantity,
        "pricePerQuantity": pricePerQuantity,
        "total": total,
      };
}

// ═══════════════════════════════════════════════════════════════
// SALARY
// ═══════════════════════════════════════════════════════════════
class Salary {
  final String? notes;
  final String? receiptImage;
  final List<Person>? persons;
  final String? totalSalaries;

  Salary({
    this.notes,
    this.receiptImage,
    this.persons,
    this.totalSalaries,
  });

  factory Salary.fromJson(Map<String, dynamic> json) => Salary(
        notes: json["notes"],
        receiptImage: json["receiptImage"],
        persons: json["persons"] == null
            ? []
            : List<Person>.from(
                json["persons"]!.map((x) => Person.fromJson(x))),
        totalSalaries: json["TotalSalaries"],
      );

  Map<String, dynamic> toJson() => {
        "notes": notes,
        "receiptImage": receiptImage,
        "persons": persons == null
            ? []
            : List<dynamic>.from(persons!.map((x) => x.toJson())),
        "TotalSalaries": totalSalaries,
      };
}

class Person {
  final String? staffId;
  final DateTime? joiningDate;
  final String? salaryAmount;
  final String? id;

  Person({
    this.staffId,
    this.joiningDate,
    this.salaryAmount,
    this.id,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        staffId: json["staffId"],
        joiningDate: json["joiningDate"] == null
            ? null
            : DateTime.tryParse(json["joiningDate"]),
        salaryAmount: json["salaryAmount"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "staffId": staffId,
        "joiningDate": joiningDate == null
            ? null
            : "${joiningDate!.year.toString().padLeft(4, '0')}-${joiningDate!.month.toString().padLeft(2, '0')}-${joiningDate!.day.toString().padLeft(2, '0')}",
        "salaryAmount": salaryAmount,
        "_id": id,
      };
}
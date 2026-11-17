import 'dart:convert';

Expencedata expencedataFromJson(String str) =>
    Expencedata.fromJson(json.decode(str));

String expencedataToJson(Expencedata data) => json.encode(data.toJson());

class Expencedata {
  final bool? success;
  final String? message;
  final int? count;
  final List<Expense>? expenses;

  Expencedata({
    this.success,
    this.message,
    this.count,
    this.expenses,
  });

  factory Expencedata.fromJson(Map<String, dynamic> json) => Expencedata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        expenses: json["expenses"] == null
            ? []
            : List<Expense>.from(
                json["expenses"]!.map((x) => Expense.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "expenses": expenses == null
            ? []
            : List<dynamic>.from(expenses!.map((x) => x.toJson())),
      };
}

class Expense {
  final Labour? labour;
  final Salary? salary;
  final Diesel? tiffinsMeals;
  final Diesel? petrol;
  final Diesel? diesel;
  final Electrical? electrical;
  final Plumbing? plumbing;
  final Diesel? transport;
  final Diesel? utilities;
  final Diesel? other;
  final String? id;
  final String? tankId;
  final String? createdBy;
  final String? farmId;
  final DateTime? date;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Expense({
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
    this.id,
    this.tankId,
    this.createdBy,
    this.farmId,
    this.date,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        labour:
            json["labour"] == null ? null : Labour.fromJson(json["labour"]),
        salary:
            json["Salary"] == null ? null : Salary.fromJson(json["Salary"]),
        tiffinsMeals: json["TiffinsMeals"] == null
            ? null
            : Diesel.fromJson(json["TiffinsMeals"]),
        petrol:
            json["Petrol"] == null ? null : Diesel.fromJson(json["Petrol"]),
        diesel:
            json["Diesel"] == null ? null : Diesel.fromJson(json["Diesel"]),
        electrical: json["Electrical"] == null
            ? null
            : Electrical.fromJson(json["Electrical"]),
        plumbing: json["Plumbing"] == null
            ? null
            : Plumbing.fromJson(json["Plumbing"]),
        transport: json["Transport"] == null
            ? null
            : Diesel.fromJson(json["Transport"]),
        utilities: json["Utilities"] == null
            ? null
            : Diesel.fromJson(json["Utilities"]),
        other:
            json["Other"] == null ? null : Diesel.fromJson(json["Other"]),
        id: json["_id"],
        tankId: json["tankId"],
        createdBy: json["createdBy"],
        farmId: json["farmId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        category: json["category"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
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
        "_id": id,
        "tankId": tankId,
        "createdBy": createdBy,
        "farmId": farmId,
        "date": date == null
            ? null
            : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "category": category,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

// ═══════════════════════════════════════════════════
// DIESEL (also used by Tiffins, Petrol, Transport, Utilities, Other)
// ═══════════════════════════════════════════════════
class Diesel {
  final String? receiptImage;
  final String? description;
  final String? partyId;
  final int? dieselAmount;
  final int? amount;

  Diesel({
    this.receiptImage,
    this.description,
    this.partyId,
    this.dieselAmount,
    this.amount,
  });

  factory Diesel.fromJson(Map<String, dynamic> json) => Diesel(
        receiptImage: json["receiptImage"],
        description: json["description"],
        partyId: json["partyId"],
        dieselAmount: json["amount"],
        amount: json["Amount"],
      );

  Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "description": description,
        "partyId": partyId,
        "amount": dieselAmount,
        "Amount": amount,
      };
}

// ═══════════════════════════════════════════════════
// ELECTRICAL
// ═══════════════════════════════════════════════════
class Electrical {
  final String? receiptImage;
  final String? itemName;
  final String? unit;
  final int? quantity;
  final int? pricePerUnit;
  final int? total;
  final String? notes;
  final String? partyId;

  Electrical({
    this.receiptImage,
    this.itemName,
    this.unit,
    this.quantity,
    this.pricePerUnit,
    this.total,
    this.notes,
    this.partyId,
  });

  factory Electrical.fromJson(Map<String, dynamic> json) => Electrical(
        receiptImage: json["receiptImage"],
        itemName: json["itemName"],
        unit: json["unit"],
        quantity: json["Quantity"],
        pricePerUnit: json["pricePerUnit"],
        total: json["Total"],
        notes: json["Notes"],
        partyId: json["partyId"],
      );

  Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "itemName": itemName,
        "unit": unit,
        "Quantity": quantity,
        "pricePerUnit": pricePerUnit,
        "Total": total,
        "Notes": notes,
        "partyId": partyId,
      };
}

// ═══════════════════════════════════════════════════
// LABOUR
// ═══════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════
// PLUMBING
// ═══════════════════════════════════════════════════
class Plumbing {
  final String? notes;
  final String? receiptImage;
  final String? itemName;
  final int? quantity;
  final int? pricePerQuantity;
  final int? total;
  final String? partyId;

  Plumbing({
    this.notes,
    this.receiptImage,
    this.itemName,
    this.quantity,
    this.pricePerQuantity,
    this.total,
    this.partyId,
  });

  factory Plumbing.fromJson(Map<String, dynamic> json) => Plumbing(
        notes: json["notes"],
        receiptImage: json["receiptImage"],
        itemName: json["itemName"],
        quantity: json["quantity"],
        pricePerQuantity: json["pricePerQuantity"],
        total: json["total"],
        partyId: json["partyId"],
      );

  Map<String, dynamic> toJson() => {
        "notes": notes,
        "receiptImage": receiptImage,
        "itemName": itemName,
        "quantity": quantity,
        "pricePerQuantity": pricePerQuantity,
        "total": total,
        "partyId": partyId,
      };
}

// ═══════════════════════════════════════════════════
// SALARY
// ═══════════════════════════════════════════════════
class Salary {
  final String? notes;
  final String? receiptImage;
  final List<Person>? persons;
  final String? totalSalaries;
  final String? partyId;

  Salary({
    this.notes,
    this.receiptImage,
    this.persons,
    this.totalSalaries,
    this.partyId,
  });

  factory Salary.fromJson(Map<String, dynamic> json) => Salary(
        notes: json["notes"],
        receiptImage: json["receiptImage"],
        persons: json["persons"] == null
            ? []
            : List<Person>.from(
                json["persons"]!.map((x) => Person.fromJson(x))),
        totalSalaries: json["TotalSalaries"],
        partyId: json["partyId"],
      );

  Map<String, dynamic> toJson() => {
        "notes": notes,
        "receiptImage": receiptImage,
        "persons": persons == null
            ? []
            : List<dynamic>.from(persons!.map((x) => x.toJson())),
        "TotalSalaries": totalSalaries,
        "partyId": partyId,
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
            : DateTime.parse(json["joiningDate"]),
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

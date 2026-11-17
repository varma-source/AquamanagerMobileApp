import 'dart:convert';

Staffexpensedata staffexpensedataFromJson(String str) => Staffexpensedata.fromJson(json.decode(str));

String staffexpensedataToJson(Staffexpensedata data) => json.encode(data.toJson());

class Staffexpensedata {
    final bool? success;
    final String? message;
    final int? count;
    final List<Expense>? expenses;

    Staffexpensedata({
        this.success,
        this.message,
        this.count,
        this.expenses,
    });

    factory Staffexpensedata.fromJson(Map<String, dynamic> json) => Staffexpensedata(
        success: json["success"],
        message: json["message"],
        count: json["count"],
        expenses: json["expenses"] == null ? [] : List<Expense>.from(json["expenses"]!.map((x) => Expense.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "count": count,
        "expenses": expenses == null ? [] : List<dynamic>.from(expenses!.map((x) => x.toJson())),
    };
}

class Expense {
    final Labour? labour;
    final Salary? salary;
    final TiffinsMeals? tiffinsMeals;
    final Diesel? petrol;
    final Diesel? diesel;
    final Electrical? electrical;
    final Plumbing? plumbing;
    final Other? transport;
    final Other? utilities;
    final Other? other;
    final String? id;
    final String? tankId;
    final String? tankName;
    final String? createdBy;
    final String? farmId;
    final String? staffId;
    final DateTime? date;
    final String? status;
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
        this.tankName,
        this.createdBy,
        this.farmId,
        this.staffId,
        this.date,
        this.status,
        this.category,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        labour: json["labour"] == null ? null : Labour.fromJson(json["labour"]),
        salary: json["Salary"] == null ? null : Salary.fromJson(json["Salary"]),
        tiffinsMeals: json["TiffinsMeals"] == null ? null : TiffinsMeals.fromJson(json["TiffinsMeals"]),
        petrol: json["Petrol"] == null ? null : Diesel.fromJson(json["Petrol"]),
        diesel: json["Diesel"] == null ? null : Diesel.fromJson(json["Diesel"]),
        electrical: json["Electrical"] == null ? null : Electrical.fromJson(json["Electrical"]),
        plumbing: json["Plumbing"] == null ? null : Plumbing.fromJson(json["Plumbing"]),
        transport: json["Transport"] == null ? null : Other.fromJson(json["Transport"]),
        utilities: json["Utilities"] == null ? null : Other.fromJson(json["Utilities"]),
        other: json["Other"] == null ? null : Other.fromJson(json["Other"]),
        id: json["_id"],
        tankId: json["tankId"],
        tankName: json["tankName"],
        createdBy: json["createdBy"],
        farmId: json["farmId"],
        staffId: json["staffId"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        status: json["status"],
        category: json["category"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
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
        "tankName": tankName,
        "createdBy": createdBy,
        "farmId": farmId,
        "staffId": staffId,
        "date": date == null ? null : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "status": status,
        "category": category,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class Diesel {
    final String? receiptImage;
    final String? description;
    final int? amount;

    Diesel({
        this.receiptImage,
        this.description,
        this.amount,
    });

    factory Diesel.fromJson(Map<String, dynamic> json) => Diesel(
        receiptImage: json["receiptImage"],
        description: json["description"],
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "description": description,
        "amount": amount,
    };
}

class Electrical {
    final String? receiptImage;
    final String? itemName;
    final String? unit;
    final int? quantity;
    final int? pricePerUnit;
    final int? total;
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

class Labour {
    final String? receiptImage;
    final String? noofpersonsWorked;
    final String? chargesPerPerson;
    final String? extras;
    final String? totalLabourCost;
    final String? notes;

    Labour({
        this.receiptImage,
        this.noofpersonsWorked,
        this.chargesPerPerson,
        this.extras,
        this.totalLabourCost,
        this.notes,
    });

    factory Labour.fromJson(Map<String, dynamic> json) => Labour(
        receiptImage: json["receiptImage"],
        noofpersonsWorked: json["noofpersonsWorked"],
        chargesPerPerson: json["chargesPerPerson"],
        extras: json["Extras"],
        totalLabourCost: json["TotalLabourCost"],
        notes: json["Notes"],
    );

    Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "noofpersonsWorked": noofpersonsWorked,
        "chargesPerPerson": chargesPerPerson,
        "Extras": extras,
        "TotalLabourCost": totalLabourCost,
        "Notes": notes,
    };
}

class Other {
    final String? receiptImage;
    final String? description;
    final int? amount;

    Other({
        this.receiptImage,
        this.description,
        this.amount,
    });

    factory Other.fromJson(Map<String, dynamic> json) => Other(
        receiptImage: json["receiptImage"],
        description: json["description"],
        amount: json["Amount"],
    );

    Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "description": description,
        "Amount": amount,
    };
}

class Plumbing {
    final String? notes;
    final String? receiptImage;
    final String? itemName;
    final int? quantity;
    final int? pricePerQuantity;
    final int? total;

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

class Salary {
    final List<Person>? persons;
    final String? totalSalaries;
    final String? notes;
    final String? receiptImage;

    Salary({
        this.persons,
        this.totalSalaries,
        this.notes,
        this.receiptImage,
    });

    factory Salary.fromJson(Map<String, dynamic> json) => Salary(
        persons: json["persons"] == null ? [] : List<Person>.from(json["persons"]!.map((x) => Person.fromJson(x))),
        totalSalaries: json["TotalSalaries"],
        notes: json["notes"],
        receiptImage: json["receiptImage"],
    );

    Map<String, dynamic> toJson() => {
        "persons": persons == null ? [] : List<dynamic>.from(persons!.map((x) => x.toJson())),
        "TotalSalaries": totalSalaries,
        "notes": notes,
        "receiptImage": receiptImage,
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
        joiningDate: json["joiningDate"] == null ? null : DateTime.parse(json["joiningDate"]),
        salaryAmount: json["salaryAmount"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "staffId": staffId,
        "joiningDate": joiningDate == null ? null : "${joiningDate!.year.toString().padLeft(4, '0')}-${joiningDate!.month.toString().padLeft(2, '0')}-${joiningDate!.day.toString().padLeft(2, '0')}",
        "salaryAmount": salaryAmount,
        "_id": id,
    };
}

class TiffinsMeals {
    final String? receiptImage;
    final String? description;
    final int? amount;

    TiffinsMeals({
        this.receiptImage,
        this.description,
        this.amount,
    });

    factory TiffinsMeals.fromJson(Map<String, dynamic> json) => TiffinsMeals(
        receiptImage: json["receiptImage"],
        description: json["description"],
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "receiptImage": receiptImage,
        "description": description,
        "amount": amount,
    };
}
// To parse this JSON data, do
//
//     final homePandLdata = homePandLdataFromJson(jsonString);

import 'dart:convert';

HomePandLdata homePandLdataFromJson(String str) =>
    HomePandLdata.fromJson(json.decode(str));

String homePandLdataToJson(HomePandLdata data) =>
    json.encode(data.toJson());

/// Safely parses a date from various possible formats.
/// Returns null if the value is null, empty, or unparseable.
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty || str.toLowerCase() == "null") return null;

  // Try ISO 8601 first (handles "2024-05-12" and full timestamps)
  try {
    return DateTime.parse(str);
  } catch (_) {}

  // Try dd/MM/yyyy or dd-MM-yyyy or yyyy/MM/dd etc.
  try {
    final parts = str.split(RegExp(r'[/\-\.]'));
    if (parts.length == 3) {
      // If first part is 4 digits => yyyy-MM-dd
      if (parts[0].length == 4) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      // Otherwise assume dd-MM-yyyy
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
  } catch (_) {}

  return null;
}

/// Formats a DateTime to yyyy-MM-dd string (for toJson).
String? _formatDate(DateTime? date) {
  if (date == null) return null;
  return "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";
}

class HomePandLdata {
  final bool? success;
  final String? message;
  final List<Overview>? overview;
  final List<Purchase>? purchases;
  final List<Medicine>? medicines;
  final List<Harvest>? harvests;
  final List<Expense>? expenses;

  HomePandLdata({
    this.success,
    this.message,
    this.overview,
    this.purchases,
    this.medicines,
    this.harvests,
    this.expenses,
  });

  factory HomePandLdata.fromJson(Map<String, dynamic> json) => HomePandLdata(
        success: json["success"],
        message: json["message"],
        overview: json["overview"] == null
            ? []
            : List<Overview>.from(
                json["overview"]!.map((x) => Overview.fromJson(x))),
        purchases: json["purchases"] == null
            ? []
            : List<Purchase>.from(
                json["purchases"]!.map((x) => Purchase.fromJson(x))),
        medicines: json["medicines"] == null
            ? []
            : List<Medicine>.from(
                json["medicines"]!.map((x) => Medicine.fromJson(x))),
        harvests: json["harvests"] == null
            ? []
            : List<Harvest>.from(
                json["harvests"]!.map((x) => Harvest.fromJson(x))),
        expenses: json["expenses"] == null
            ? []
            : List<Expense>.from(
                json["expenses"]!.map((x) => Expense.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "overview": overview == null
            ? []
            : List<dynamic>.from(overview!.map((x) => x.toJson())),
        "purchases": purchases == null
            ? []
            : List<dynamic>.from(purchases!.map((x) => x.toJson())),
        "medicines": medicines == null
            ? []
            : List<dynamic>.from(medicines!.map((x) => x.toJson())),
        "harvests": harvests == null
            ? []
            : List<dynamic>.from(harvests!.map((x) => x.toJson())),
        "expenses": expenses == null
            ? []
            : List<dynamic>.from(expenses!.map((x) => x.toJson())),
      };
}

class Expense {
  final String? id;
  final TankId? tankId;
  final CreatedBy? createdBy;
  final FarmId? farmId;
  final DateTime? date;
  final String? category;
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final Name? tankName;

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
    this.tankName,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json["_id"],
        tankId: tankIdValues.map[json["tankId"]],
        createdBy: createdByValues.map[json["createdBy"]],
        farmId: farmIdValues.map[json["farmId"]],
        date: _parseDate(json["date"]),
        category: json["category"],
        labour: json["labour"] == null
            ? null
            : Labour.fromJson(json["labour"]),
        salary: json["Salary"] == null
            ? null
            : Salary.fromJson(json["Salary"]),
        tiffinsMeals: json["TiffinsMeals"] == null
            ? null
            : Diesel.fromJson(json["TiffinsMeals"]),
        petrol: json["Petrol"] == null
            ? null
            : Diesel.fromJson(json["Petrol"]),
        diesel: json["Diesel"] == null
            ? null
            : Diesel.fromJson(json["Diesel"]),
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
        other: json["Other"] == null
            ? null
            : Diesel.fromJson(json["Other"]),
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
        v: json["__v"],
        tankName: nameValues.map[json["tankName"]],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankIdValues.reverse[tankId],
        "createdBy": createdByValues.reverse[createdBy],
        "farmId": farmIdValues.reverse[farmId],
        "date": _formatDate(date),
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
        "tankName": nameValues.reverse[tankName],
      };
}

enum CreatedBy {
  THE_6_ACCF9819_B97_BA3_DE3_A729_CB
}

final createdByValues = EnumValues({
  "6accf9819b97ba3de3a729cb": CreatedBy.THE_6_ACCF9819_B97_BA3_DE3_A729_CB
});

class Diesel {
  final DieselReceiptImage? receiptImage;
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
        receiptImage: dieselReceiptImageValues.map[json["receiptImage"]],
        description: json["description"],
        partyId: json["partyId"],
        dieselAmount: json["amount"],
        amount: json["Amount"],
      );

  Map<String, dynamic> toJson() => {
        "receiptImage": dieselReceiptImageValues.reverse[receiptImage],
        "description": description,
        "partyId": partyId,
        "amount": dieselAmount,
        "Amount": amount,
      };
}

enum DieselReceiptImage {
  EMPTY,
  UPLOADS_EXPENSE_IMG_1791885425998_SCALED_1000221561_JPG,
  UPLOADS_EXPENSE_IMG_1791885459367_SCALED_1000221561_JPG,
  UPLOADS_EXPENSE_IMG_1791885492323_SCALED_1000221561_JPG,
  UPLOADS_EXPENSE_IMG_1791885585808_SCALED_1000221561_JPG,
  UPLOADS_EXPENSE_IMG_1791885611569_SCALED_1000221561_JPG,
  UPLOADS_EXPENSE_IMG_1791885645440_SCALED_1000221561_JPG,
  UPLOADS_EXPENSE_IMG_1791885730716_SCALED_1000221561_JPG
}

final dieselReceiptImageValues = EnumValues({
  "": DieselReceiptImage.EMPTY,
  "uploads/expenseImg/1791885425998-scaled_1000221561.jpg":
      DieselReceiptImage.UPLOADS_EXPENSE_IMG_1791885425998_SCALED_1000221561_JPG,
  "uploads/expenseImg/1791885459367-scaled_1000221561.jpg":
      DieselReceiptImage.UPLOADS_EXPENSE_IMG_1791885459367_SCALED_1000221561_JPG,
  "uploads/expenseImg/1791885492323-scaled_1000221561.jpg":
      DieselReceiptImage.UPLOADS_EXPENSE_IMG_1791885492323_SCALED_1000221561_JPG,
  "uploads/expenseImg/1791885585808-scaled_1000221561.jpg":
      DieselReceiptImage.UPLOADS_EXPENSE_IMG_1791885585808_SCALED_1000221561_JPG,
  "uploads/expenseImg/1791885611569-scaled_1000221561.jpg":
      DieselReceiptImage.UPLOADS_EXPENSE_IMG_1791885611569_SCALED_1000221561_JPG,
  "uploads/expenseImg/1791885645440-scaled_1000221561.jpg":
      DieselReceiptImage.UPLOADS_EXPENSE_IMG_1791885645440_SCALED_1000221561_JPG,
  "uploads/expenseImg/1791885730716-scaled_1000221561.jpg":
      DieselReceiptImage.UPLOADS_EXPENSE_IMG_1791885730716_SCALED_1000221561_JPG
});

class Electrical {
  final ElectricalReceiptImage? receiptImage;
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
        receiptImage: electricalReceiptImageValues.map[json["receiptImage"]],
        itemName: json["itemName"],
        unit: json["unit"],
        quantity: json["Quantity"],
        pricePerUnit: json["pricePerUnit"],
        total: json["Total"],
        notes: json["Notes"],
        partyId: json["partyId"],
      );

  Map<String, dynamic> toJson() => {
        "receiptImage": electricalReceiptImageValues.reverse[receiptImage],
        "itemName": itemName,
        "unit": unit,
        "Quantity": quantity,
        "pricePerUnit": pricePerUnit,
        "Total": total,
        "Notes": notes,
        "partyId": partyId,
      };
}

enum ElectricalReceiptImage {
  EMPTY,
  UPLOADS_EXPENSE_IMG_1791885526558_SCALED_1000221561_JPG
}

final electricalReceiptImageValues = EnumValues({
  "": ElectricalReceiptImage.EMPTY,
  "uploads/expenseImg/1791885526558-scaled_1000221561.jpg":
      ElectricalReceiptImage.UPLOADS_EXPENSE_IMG_1791885526558_SCALED_1000221561_JPG
});

enum FarmId {
  THE_6_ACCF9819_B97_BA3_DE3_A729_CC
}

final farmIdValues = EnumValues({
  "6accf9819b97ba3de3a729cc": FarmId.THE_6_ACCF9819_B97_BA3_DE3_A729_CC
});

class Labour {
  final String? noofpersonsWorked;
  final String? chargesPerPerson;
  final String? extras;
  final String? totalLabourCost;
  final String? notes;
  final String? partyId;
  final LabourReceiptImage? receiptImage;

  Labour({
    this.noofpersonsWorked,
    this.chargesPerPerson,
    this.extras,
    this.totalLabourCost,
    this.notes,
    this.partyId,
    this.receiptImage,
  });

  factory Labour.fromJson(Map<String, dynamic> json) => Labour(
        noofpersonsWorked: json["noofpersonsWorked"],
        chargesPerPerson: json["chargesPerPerson"],
        extras: json["Extras"],
        totalLabourCost: json["TotalLabourCost"],
        notes: json["Notes"],
        partyId: json["partyId"],
        receiptImage: labourReceiptImageValues.map[json["receiptImage"]],
      );

  Map<String, dynamic> toJson() => {
        "noofpersonsWorked": noofpersonsWorked,
        "chargesPerPerson": chargesPerPerson,
        "Extras": extras,
        "TotalLabourCost": totalLabourCost,
        "Notes": notes,
        "partyId": partyId,
        "receiptImage": labourReceiptImageValues.reverse[receiptImage],
      };
}

enum LabourReceiptImage {
  EMPTY,
  UPLOADS_EXPENSE_IMG_1791885350297_SCALED_1000221561_JPG
}

final labourReceiptImageValues = EnumValues({
  "": LabourReceiptImage.EMPTY,
  "uploads/expenseImg/1791885350297-scaled_1000221561.jpg":
      LabourReceiptImage.UPLOADS_EXPENSE_IMG_1791885350297_SCALED_1000221561_JPG
});

class Plumbing {
  final String? notes;
  final PlumbingReceiptImage? receiptImage;
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
        receiptImage: plumbingReceiptImageValues.map[json["receiptImage"]],
        itemName: json["itemName"],
        quantity: json["quantity"],
        pricePerQuantity: json["pricePerQuantity"],
        total: json["total"],
        partyId: json["partyId"],
      );

  Map<String, dynamic> toJson() => {
        "notes": notes,
        "receiptImage": plumbingReceiptImageValues.reverse[receiptImage],
        "itemName": itemName,
        "quantity": quantity,
        "pricePerQuantity": pricePerQuantity,
        "total": total,
        "partyId": partyId,
      };
}

enum PlumbingReceiptImage {
  EMPTY,
  UPLOADS_EXPENSE_IMG_1791885554995_SCALED_1000221561_JPG
}

final plumbingReceiptImageValues = EnumValues({
  "": PlumbingReceiptImage.EMPTY,
  "uploads/expenseImg/1791885554995-scaled_1000221561.jpg":
      PlumbingReceiptImage.UPLOADS_EXPENSE_IMG_1791885554995_SCALED_1000221561_JPG
});

class Salary {
  final String? notes;
  final SalaryReceiptImage? receiptImage;
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
        receiptImage: salaryReceiptImageValues.map[json["receiptImage"]],
        persons: json["persons"] == null
            ? []
            : List<Person>.from(
                json["persons"]!.map((x) => Person.fromJson(x))),
        totalSalaries: json["TotalSalaries"],
        partyId: json["partyId"],
      );

  Map<String, dynamic> toJson() => {
        "notes": notes,
        "receiptImage": salaryReceiptImageValues.reverse[receiptImage],
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
        joiningDate: _parseDate(json["joiningDate"]),
        salaryAmount: json["salaryAmount"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "staffId": staffId,
        "joiningDate": _formatDate(joiningDate),
        "salaryAmount": salaryAmount,
        "_id": id,
      };
}

enum SalaryReceiptImage {
  EMPTY,
  UPLOADS_EXPENSE_IMG_1791885389295_SCALED_1000221561_JPG
}

final salaryReceiptImageValues = EnumValues({
  "": SalaryReceiptImage.EMPTY,
  "uploads/expenseImg/1791885389295-scaled_1000221561.jpg":
      SalaryReceiptImage.UPLOADS_EXPENSE_IMG_1791885389295_SCALED_1000221561_JPG
});

enum TankId {
  THE_6_ACDDA56_BDA03_FD5587_BB707
}

final tankIdValues = EnumValues({
  "6acdda56bda03fd5587bb707": TankId.THE_6_ACDDA56_BDA03_FD5587_BB707
});

enum Name {
  GOPI_4
}

final nameValues = EnumValues({
  "gopi 4": Name.GOPI_4
});

class Harvest {
  final String? id;
  final TankId? tankId;
  final CreatedBy? userId;
  final FarmId? farmId;
  final DateTime? date;
  final String? harvestType;
  final String? quantityHarvested;
  final String? averageSizeAtHarvest;
  final String? totalAmount;
  final String? marketName;
  final String? notes;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;
  final Name? tankName;

  Harvest({
    this.id,
    this.tankId,
    this.userId,
    this.farmId,
    this.date,
    this.harvestType,
    this.quantityHarvested,
    this.averageSizeAtHarvest,
    this.totalAmount,
    this.marketName,
    this.notes,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    this.tankName,
  });

  factory Harvest.fromJson(Map<String, dynamic> json) => Harvest(
        id: json["_id"],
        tankId: tankIdValues.map[json["tankId"]],
        userId: createdByValues.map[json["userId"]],
        farmId: farmIdValues.map[json["farmId"]],
        date: _parseDate(json["date"]),
        harvestType: json["harvestType"],
        quantityHarvested: json["quantityHarvested"],
        averageSizeAtHarvest: json["averageSizeAtHarvest"],
        totalAmount: json["totalAmount"],
        marketName: json["marketName"],
        notes: json["notes"],
        status: json["status"],
        logCreatedDate: _parseDate(json["logCreatedDate"]),
        logModifiedDate: _parseDate(json["logModifiedDate"]),
        v: json["__v"],
        tankName: nameValues.map[json["tankName"]],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankIdValues.reverse[tankId],
        "userId": createdByValues.reverse[userId],
        "farmId": farmIdValues.reverse[farmId],
        "date": _formatDate(date),
        "harvestType": harvestType,
        "quantityHarvested": quantityHarvested,
        "averageSizeAtHarvest": averageSizeAtHarvest,
        "totalAmount": totalAmount,
        "marketName": marketName,
        "notes": notes,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "tankName": nameValues.reverse[tankName],
      };
}

class Medicine {
  final String? id;
  final String? partyId;
  final TankId? tankId;
  final FarmId? farmId;
  final CreatedBy? userId;
  final DateTime? purchaseDate;
  final String? medicineName;
  final String? brand;
  final String? quantityPurchased;
  final String? pricePerUnits;
  final String? totalAmount;
  final String? invoiceReference;
  final String? paidBy;
  final String? medicineType;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? partyName;
  final Name? tankName;

  Medicine({
    this.id,
    this.partyId,
    this.tankId,
    this.farmId,
    this.userId,
    this.purchaseDate,
    this.medicineName,
    this.brand,
    this.quantityPurchased,
    this.pricePerUnits,
    this.totalAmount,
    this.invoiceReference,
    this.paidBy,
    this.medicineType,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.partyName,
    this.tankName,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json["_id"],
        partyId: json["partyId"],
        tankId: tankIdValues.map[json["tankId"]],
        farmId: farmIdValues.map[json["farmId"]],
        userId: createdByValues.map[json["userId"]],
        purchaseDate: _parseDate(json["purchaseDate"]),
        medicineName: json["medicineName"],
        brand: json["brand"],
        quantityPurchased: json["quantityPurchased"],
        pricePerUnits: json["pricePerUnits"],
        totalAmount: json["totalAmount"],
        invoiceReference: json["invoiceReference"],
        paidBy: json["paidBy"],
        medicineType: json["medicineType"],
        status: json["status"],
        logCreatedDate: _parseDate(json["logCreatedDate"]),
        logModifiedDate: _parseDate(json["logModifiedDate"]),
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
        v: json["__v"],
        partyName: json["partyName"],
        tankName: nameValues.map[json["tankName"]],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "partyId": partyId,
        "tankId": tankIdValues.reverse[tankId],
        "farmId": farmIdValues.reverse[farmId],
        "userId": createdByValues.reverse[userId],
        "purchaseDate": _formatDate(purchaseDate),
        "medicineName": medicineName,
        "brand": brand,
        "quantityPurchased": quantityPurchased,
        "pricePerUnits": pricePerUnits,
        "totalAmount": totalAmount,
        "invoiceReference": invoiceReference,
        "paidBy": paidBy,
        "medicineType": medicineType,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "partyName": partyName,
        "tankName": nameValues.reverse[tankName],
      };
}

class Overview {
  final TankId? id;
  final CreatedBy? userId;
  final FarmId? farmId;
  final Name? name;
  final String? tankType;
  final String? pondSize;
  final String? address;
  final Location? location;
  final dynamic staffId;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;
  final String? staffName;
  final List<Stock>? stocks;

  Overview({
    this.id,
    this.userId,
    this.farmId,
    this.name,
    this.tankType,
    this.pondSize,
    this.address,
    this.location,
    this.staffId,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    this.staffName,
    this.stocks,
  });

  factory Overview.fromJson(Map<String, dynamic> json) => Overview(
        id: tankIdValues.map[json["_id"]],
        userId: createdByValues.map[json["userId"]],
        farmId: farmIdValues.map[json["farmId"]],
        name: nameValues.map[json["name"]],
        tankType: json["tankType"],
        pondSize: json["pondSize"],
        address: json["address"],
        location: json["location"] == null
            ? null
            : Location.fromJson(json["location"]),
        staffId: json["staffId"],
        status: json["status"],
        logCreatedDate: _parseDate(json["logCreatedDate"]),
        logModifiedDate: _parseDate(json["logModifiedDate"]),
        v: json["__v"],
        staffName: json["staffName"],
        stocks: json["stocks"] == null
            ? []
            : List<Stock>.from(
                json["stocks"]!.map((x) => Stock.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_id": tankIdValues.reverse[id],
        "userId": createdByValues.reverse[userId],
        "farmId": farmIdValues.reverse[farmId],
        "name": nameValues.reverse[name],
        "tankType": tankType,
        "pondSize": pondSize,
        "address": address,
        "location": location?.toJson(),
        "staffId": staffId,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "staffName": staffName,
        "stocks": stocks == null
            ? []
            : List<dynamic>.from(stocks!.map((x) => x.toJson())),
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
                List<List<double>>.from(x.map(
                    (x) => List<double>.from(x.map((x) => x?.toDouble())))))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => List<dynamic>.from(
                x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
      };
}

class Stock {
  final String? id;
  final TankId? tankId;
  final CreatedBy? userId;
  final DateTime? date;
  final FarmId? farmId;
  final String? speciesName;
  final String? cropName;
  final String? quantityStocked;
  final String? averageWeightAtStocking;
  final String? stockingCostPerUnit;
  final String? supplier;
  final String? notes;
  final String? totalAmount;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Stock({
    this.id,
    this.tankId,
    this.userId,
    this.date,
    this.farmId,
    this.speciesName,
    this.cropName,
    this.quantityStocked,
    this.averageWeightAtStocking,
    this.stockingCostPerUnit,
    this.supplier,
    this.notes,
    this.totalAmount,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        id: json["_id"],
        tankId: tankIdValues.map[json["tankId"]],
        userId: createdByValues.map[json["userId"]],
        date: _parseDate(json["date"]),
        farmId: farmIdValues.map[json["farmId"]],
        speciesName: json["speciesName"],
        cropName: json["cropName"],
        quantityStocked: json["quantityStocked"],
        averageWeightAtStocking: json["averageWeightAtStocking"],
        stockingCostPerUnit: json["stockingCostPerUnit"],
        supplier: json["supplier"],
        notes: json["notes"],
        totalAmount: json["totalAmount"],
        status: json["status"],
        logCreatedDate: _parseDate(json["logCreatedDate"]),
        logModifiedDate: _parseDate(json["logModifiedDate"]),
        createdAt: _parseDate(json["createdAt"]),
        updatedAt: _parseDate(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankIdValues.reverse[tankId],
        "userId": createdByValues.reverse[userId],
        "date": _formatDate(date),
        "farmId": farmIdValues.reverse[farmId],
        "speciesName": speciesName,
        "cropName": cropName,
        "quantityStocked": quantityStocked,
        "averageWeightAtStocking": averageWeightAtStocking,
        "stockingCostPerUnit": stockingCostPerUnit,
        "supplier": supplier,
        "notes": notes,
        "totalAmount": totalAmount,
        "status": status,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Purchase {
  final String? id;
  final TankId? tankId;
  final CreatedBy? userId;
  final String? partyId;
  final FarmId? farmId;
  final DateTime? date;
  final String? feedName;
  final String? brand;
  final String? quantityPurchased;
  final String? pricePerKg;
  final String? supplierName;
  final String? invoiceReference;
  final String? paymentMethod;
  final String? status;
  final String? totalAmount;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;
  final String? partyName;
  final Name? tankName;

  Purchase({
    this.id,
    this.tankId,
    this.userId,
    this.partyId,
    this.farmId,
    this.date,
    this.feedName,
    this.brand,
    this.quantityPurchased,
    this.pricePerKg,
    this.supplierName,
    this.invoiceReference,
    this.paymentMethod,
    this.status,
    this.totalAmount,
    this.logCreatedDate,
    this.logModifiedDate,
    this.v,
    this.partyName,
    this.tankName,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json["_id"],
        tankId: tankIdValues.map[json["tankId"]],
        userId: createdByValues.map[json["userId"]],
        partyId: json["partyId"],
        farmId: farmIdValues.map[json["farmId"]],
        date: _parseDate(json["date"]),
        feedName: json["feedName"],
        brand: json["brand"],
        quantityPurchased: json["quantityPurchased"],
        pricePerKg: json["pricePerKg"],
        supplierName: json["supplierName"],
        invoiceReference: json["invoiceReference"],
        paymentMethod: json["paymentMethod"],
        status: json["status"],
        totalAmount: json["totalAmount"],
        logCreatedDate: _parseDate(json["logCreatedDate"]),
        logModifiedDate: _parseDate(json["logModifiedDate"]),
        v: json["__v"],
        partyName: json["partyName"],
        tankName: nameValues.map[json["tankName"]],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "tankId": tankIdValues.reverse[tankId],
        "userId": createdByValues.reverse[userId],
        "partyId": partyId,
        "farmId": farmIdValues.reverse[farmId],
        "date": _formatDate(date),
        "feedName": feedName,
        "brand": brand,
        "quantityPurchased": quantityPurchased,
        "pricePerKg": pricePerKg,
        "supplierName": supplierName,
        "invoiceReference": invoiceReference,
        "paymentMethod": paymentMethod,
        "status": status,
        "totalAmount": totalAmount,
        "logCreatedDate": logCreatedDate?.toIso8601String(),
        "logModifiedDate": logModifiedDate?.toIso8601String(),
        "__v": v,
        "partyName": partyName,
        "tankName": nameValues.reverse[tankName],
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
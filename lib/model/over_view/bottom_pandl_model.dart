// To parse this JSON data, do
//
//     final bottompandldata = bottompandldataFromJson(jsonString);

import 'dart:convert';

Bottompandldata bottompandldataFromJson(String str) =>
    Bottompandldata.fromJson(json.decode(str));

String bottompandldataToJson(Bottompandldata data) =>
    json.encode(data.toJson());

class Bottompandldata {
  final bool? success;
  final String? message;
  final List<Overview>? overview;
  final List<Purchase>? purchases;
  final List<Medicine>? medicines;
  final List<Harvest>? harvests;
  final List<Expense>? expenses;

  Bottompandldata({
    this.success,
    this.message,
    this.overview,
    this.purchases,
    this.medicines,
    this.harvests,
    this.expenses,
  });

  factory Bottompandldata.fromJson(Map<String, dynamic> json) =>
      Bottompandldata(
        success: json["success"],
        message: json["message"],
        overview:
            json["overview"] == null
                ? []
                : List<Overview>.from(
                  json["overview"]!.map((x) => Overview.fromJson(x)),
                ),
        purchases:
            json["purchases"] == null
                ? []
                : List<Purchase>.from(
                  json["purchases"]!.map((x) => Purchase.fromJson(x)),
                ),
        medicines:
            json["medicines"] == null
                ? []
                : List<Medicine>.from(
                  json["medicines"]!.map((x) => Medicine.fromJson(x)),
                ),
        harvests:
            json["harvests"] == null
                ? []
                : List<Harvest>.from(
                  json["harvests"]!.map((x) => Harvest.fromJson(x)),
                ),
        expenses:
            json["expenses"] == null
                ? []
                : List<Expense>.from(
                  json["expenses"]!.map((x) => Expense.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "overview":
        overview == null
            ? []
            : List<dynamic>.from(overview!.map((x) => x.toJson())),
    "purchases":
        purchases == null
            ? []
            : List<dynamic>.from(purchases!.map((x) => x.toJson())),
    "medicines":
        medicines == null
            ? []
            : List<dynamic>.from(medicines!.map((x) => x.toJson())),
    "harvests":
        harvests == null
            ? []
            : List<dynamic>.from(harvests!.map((x) => x.toJson())),
    "expenses":
        expenses == null
            ? []
            : List<dynamic>.from(expenses!.map((x) => x.toJson())),
  };
}

// ═══════════════════════════════════════════════════════════════
// PURCHASE  (was missing — purchases were List<dynamic>)
// ═══════════════════════════════════════════════════════════════
class Purchase {
  final String? id;
  final String? tankId;
  final String? userId;
  final String? partyId;
  final String? farmId;
  final String? date;
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
  final String? tankName;

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
    tankId: json["tankId"],
    userId: json["userId"],
    partyId: json["partyId"],
    farmId: json["farmId"],
    date: json["date"],
    feedName: json["feedName"],
    brand: json["brand"],
    quantityPurchased: json["quantityPurchased"],
    pricePerKg: json["pricePerKg"],
    supplierName: json["supplierName"],
    invoiceReference: json["invoiceReference"],
    paymentMethod: json["paymentMethod"],
    status: json["status"],
    totalAmount: json["totalAmount"],
    logCreatedDate:
        json["logCreatedDate"] == null
            ? null
            : DateTime.parse(json["logCreatedDate"]),
    logModifiedDate:
        json["logModifiedDate"] == null
            ? null
            : DateTime.parse(json["logModifiedDate"]),
    v: json["__v"],
    partyName: json["partyName"],
    tankName: json["tankName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "tankId": tankId,
    "userId": userId,
    "partyId": partyId,
    "farmId": farmId,
    "date": date,
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
    "tankName": tankName,
  };
}

// ═══════════════════════════════════════════════════════════════
// OVERVIEW  (fixed: ids are String, staffId/staffName are List<String>)
// ═══════════════════════════════════════════════════════════════
class Overview {
  final String? id;
  final String? userId;
  final String? farmId;
  final String? name;
  final String? tankType;
  final String? pondSize;
  final String? address;
  final Location? location;
  final List<String>? staffId;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final int? v;
  final List<String>? staffName;
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
    id: json["_id"],
    userId: json["userId"],
    farmId: json["farmId"],
    name: json["name"],
    tankType: json["tankType"],
    pondSize: json["pondSize"],
    address: json["address"],
    location:
        json["location"] == null ? null : Location.fromJson(json["location"]),
    staffId:
        json["staffId"] == null
            ? []
            : List<String>.from(json["staffId"]!.map((x) => x)),
    status: json["status"],
    logCreatedDate:
        json["logCreatedDate"] == null
            ? null
            : DateTime.parse(json["logCreatedDate"]),
    logModifiedDate:
        json["logModifiedDate"] == null
            ? null
            : DateTime.parse(json["logModifiedDate"]),
    v: json["__v"],
    staffName:
        json["staffName"] == null
            ? []
            : List<String>.from(json["staffName"]!.map((x) => x)),
    stocks:
        json["stocks"] == null
            ? []
            : List<Stock>.from(json["stocks"]!.map((x) => Stock.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "farmId": farmId,
    "name": name,
    "tankType": tankType,
    "pondSize": pondSize,
    "address": address,
    "location": location?.toJson(),
    "staffId":
        staffId == null ? [] : List<dynamic>.from(staffId!.map((x) => x)),
    "status": status,
    "logCreatedDate": logCreatedDate?.toIso8601String(),
    "logModifiedDate": logModifiedDate?.toIso8601String(),
    "__v": v,
    "staffName":
        staffName == null ? [] : List<dynamic>.from(staffName!.map((x) => x)),
    "stocks":
        stocks == null
            ? []
            : List<dynamic>.from(stocks!.map((x) => x.toJson())),
  };
}

class Location {
  final String? type;
  final List<List<List<double>>>? coordinates;

  Location({this.type, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"],
    coordinates:
        json["coordinates"] == null
            ? []
            : List<List<List<double>>>.from(
              json["coordinates"]!.map(
                (x) => List<List<double>>.from(
                  x.map((x) => List<double>.from(x.map((x) => x?.toDouble()))),
                ),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates":
        coordinates == null
            ? []
            : List<dynamic>.from(
              coordinates!.map(
                (x) => List<dynamic>.from(
                  x.map((x) => List<dynamic>.from(x.map((x) => x))),
                ),
              ),
            ),
  };
}

// ═══════════════════════════════════════════════════════════════
// STOCK
// ═══════════════════════════════════════════════════════════════
class Stock {
  final String? id;
  final String? tankId;
  final String? date;
  final String? speciesName;
  final String? cropName;
  final String? quantityStocked;
  final String? averageWeightAtStocking;
  final String? stockingCostPerUnit;
  final String? supplier;
  final String? notes;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? userId;
  final String? totalAmount;

  Stock({
    this.id,
    this.tankId,
    this.date,
    this.speciesName,
    this.cropName,
    this.quantityStocked,
    this.averageWeightAtStocking,
    this.stockingCostPerUnit,
    this.supplier,
    this.notes,
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.userId,
    this.totalAmount,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
    id: json["_id"],
    tankId: json["tankId"],
    date: json["date"],
    speciesName: json["speciesName"],
    cropName: json["cropName"],
    quantityStocked: json["quantityStocked"],
    averageWeightAtStocking: json["averageWeightAtStocking"],
    stockingCostPerUnit: json["stockingCostPerUnit"],
    supplier: json["supplier"],
    notes: json["notes"],
    status: json["status"],
    logCreatedDate:
        json["logCreatedDate"] == null
            ? null
            : DateTime.parse(json["logCreatedDate"]),
    logModifiedDate:
        json["logModifiedDate"] == null
            ? null
            : DateTime.parse(json["logModifiedDate"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    userId: json["userId"],
    totalAmount: json["totalAmount"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "tankId": tankId,
    "date": date,
    "speciesName": speciesName,
    "cropName": cropName,
    "quantityStocked": quantityStocked,
    "averageWeightAtStocking": averageWeightAtStocking,
    "stockingCostPerUnit": stockingCostPerUnit,
    "supplier": supplier,
    "notes": notes,
    "status": status,
    "logCreatedDate": logCreatedDate?.toIso8601String(),
    "logModifiedDate": logModifiedDate?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "userId": userId,
    "totalAmount": totalAmount,
  };
}

// ═══════════════════════════════════════════════════════════════
// MEDICINE  (fixed: ids/names are String, not enums)
// ═══════════════════════════════════════════════════════════════
class Medicine {
  final String? id;
  final String? partyId;
  final String? tankId;
  final String? farmId;
  final String? userId;
  final String? purchaseDate;
  final String? medicineName;
  final String? brand;
  final String? quantityPurchased;
  final String? pricePerUnits;
  final String? totalAmount;
  final String? invoiceReference;
  final String? paidBy;
  final String? status;
  final DateTime? logCreatedDate;
  final DateTime? logModifiedDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? medicineType;
  final String? partyName;
  final String? tankName;

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
    this.status,
    this.logCreatedDate,
    this.logModifiedDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.medicineType,
    this.partyName,
    this.tankName,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json["_id"],
    partyId: json["partyId"],
    tankId: json["tankId"],
    farmId: json["farmId"],
    userId: json["userId"],
    purchaseDate: json["purchaseDate"],
    medicineName: json["medicineName"],
    brand: json["brand"],
    quantityPurchased: json["quantityPurchased"],
    pricePerUnits: json["pricePerUnits"],
    totalAmount: json["totalAmount"],
    invoiceReference: json["invoiceReference"],
    paidBy: json["paidBy"],
    status: json["status"],
    logCreatedDate:
        json["logCreatedDate"] == null
            ? null
            : DateTime.parse(json["logCreatedDate"]),
    logModifiedDate:
        json["logModifiedDate"] == null
            ? null
            : DateTime.parse(json["logModifiedDate"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    medicineType: json["medicineType"],
    partyName: json["partyName"],
    tankName: json["tankName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "partyId": partyId,
    "tankId": tankId,
    "farmId": farmId,
    "userId": userId,
    "purchaseDate": purchaseDate,
    "medicineName": medicineName,
    "brand": brand,
    "quantityPurchased": quantityPurchased,
    "pricePerUnits": pricePerUnits,
    "totalAmount": totalAmount,
    "invoiceReference": invoiceReference,
    "paidBy": paidBy,
    "status": status,
    "logCreatedDate": logCreatedDate?.toIso8601String(),
    "logModifiedDate": logModifiedDate?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "medicineType": medicineType,
    "partyName": partyName,
    "tankName": tankName,
  };
}

// ═══════════════════════════════════════════════════════════════
// HARVEST
// ═══════════════════════════════════════════════════════════════
class Harvest {
  final String? id;
  final String? tankId;
  final String? date;
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
  final String? userId;
  final String? tankName;

  Harvest({
    this.id,
    this.tankId,
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
    this.userId,
    this.tankName,
  });

  factory Harvest.fromJson(Map<String, dynamic> json) => Harvest(
    id: json["_id"],
    tankId: json["tankId"],
    date: json["date"],
    harvestType: json["harvestType"],
    quantityHarvested: json["quantityHarvested"],
    averageSizeAtHarvest: json["averageSizeAtHarvest"],
    totalAmount: json["totalAmount"],
    marketName: json["marketName"],
    notes: json["notes"],
    status: json["status"],
    logCreatedDate:
        json["logCreatedDate"] == null
            ? null
            : DateTime.parse(json["logCreatedDate"]),
    logModifiedDate:
        json["logModifiedDate"] == null
            ? null
            : DateTime.parse(json["logModifiedDate"]),
    v: json["__v"],
    userId: json["userId"],
    tankName: json["tankName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "tankId": tankId,
    "date": date,
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
    "userId": userId,
    "tankName": tankName,
  };
}

// ═══════════════════════════════════════════════════════════════
// EXPENSE  (fixed: ids/names/enums → String)
// ═══════════════════════════════════════════════════════════════
class Expense {
  final String? id;
  final String? tankId;
  final String? createdBy;
  final DateTime? date;
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
  final String? tankName;

  Expense({
    this.id,
    this.tankId,
    this.createdBy,
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
    tankId: json["tankId"],
    createdBy: json["createdBy"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    category: json["category"],
    labour: json["labour"] == null ? null : Labour.fromJson(json["labour"]),
    salary: json["Salary"] == null ? null : Salary.fromJson(json["Salary"]),
    tiffinsMeals:
        json["TiffinsMeals"] == null
            ? null
            : ExpenseItem.fromJson(json["TiffinsMeals"]),
    petrol:
        json["Petrol"] == null ? null : ExpenseItem.fromJson(json["Petrol"]),
    diesel:
        json["Diesel"] == null ? null : ExpenseItem.fromJson(json["Diesel"]),
    electrical:
        json["Electrical"] == null
            ? null
            : Electrical.fromJson(json["Electrical"]),
    plumbing:
        json["Plumbing"] == null ? null : Plumbing.fromJson(json["Plumbing"]),
    transport:
        json["Transport"] == null
            ? null
            : ExpenseItem.fromJson(json["Transport"]),
    utilities:
        json["Utilities"] == null
            ? null
            : ExpenseItem.fromJson(json["Utilities"]),
    other: json["Other"] == null ? null : ExpenseItem.fromJson(json["Other"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    tankName: json["tankName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "tankId": tankId,
    "createdBy": createdBy,
    "date":
        date == null
            ? null
            : "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
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
    "tankName": tankName,
  };
}

// ═══════════════════════════════════════════════════════════════
// EXPENSE ITEM  (generic for Diesel/Petrol/TiffinsMeals/Transport/
//                Utilities/Other — same shape)
// ═══════════════════════════════════════════════════════════════
class ExpenseItem {
  final String? receiptImage;
  final String? description;
  final String? partyId;
  final int? amount;
  final int? amountCapital;

  ExpenseItem({
    this.receiptImage,
    this.description,
    this.partyId,
    this.amount,
    this.amountCapital,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
    receiptImage: json["receiptImage"],
    description: json["description"],
    partyId: json["partyId"],
    amount: json["amount"],
    amountCapital: json["Amount"],
  );

  Map<String, dynamic> toJson() => {
    "receiptImage": receiptImage,
    "description": description,
    "partyId": partyId,
    "amount": amount,
    "Amount": amountCapital,
  };
}

// ═══════════════════════════════════════════════════════════════
// ELECTRICAL
// ═══════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════
// LABOUR
// ═══════════════════════════════════════════════════════════════
class Labour {
  final String? noofpersonsWorked;
  final String? chargesPerPerson;
  final String? extras;
  final String? totalLabourCost;
  final String? notes;
  final String? partyId;
  final String? receiptImage;

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
    receiptImage: json["receiptImage"],
  );

  Map<String, dynamic> toJson() => {
    "noofpersonsWorked": noofpersonsWorked,
    "chargesPerPerson": chargesPerPerson,
    "Extras": extras,
    "TotalLabourCost": totalLabourCost,
    "Notes": notes,
    "partyId": partyId,
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

// ═══════════════════════════════════════════════════════════════
// SALARY
// ═══════════════════════════════════════════════════════════════
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
    persons:
        json["persons"] == null
            ? []
            : List<Person>.from(
              json["persons"]!.map((x) => Person.fromJson(x)),
            ),
    totalSalaries: json["TotalSalaries"],
    partyId: json["partyId"],
  );

  Map<String, dynamic> toJson() => {
    "notes": notes,
    "receiptImage": receiptImage,
    "persons":
        persons == null
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

  Person({this.staffId, this.joiningDate, this.salaryAmount, this.id});

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    staffId: json["staffId"],
    joiningDate:
        json["joiningDate"] == null
            ? null
            : DateTime.parse(json["joiningDate"]),
    salaryAmount: json["salaryAmount"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "staffId": staffId,
    "joiningDate":
        joiningDate == null
            ? null
            : "${joiningDate!.year.toString().padLeft(4, '0')}-${joiningDate!.month.toString().padLeft(2, '0')}-${joiningDate!.day.toString().padLeft(2, '0')}",
    "salaryAmount": salaryAmount,
    "_id": id,
  };
}

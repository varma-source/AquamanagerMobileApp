import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Don't forget to add intl package in pubspec.yaml

Future<String?> appDatePicker(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1700),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    // Format the picked date
    String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
    return formattedDate;
  }
  return null;
}

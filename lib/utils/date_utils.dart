import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Date_Utils {
  static Future<DateTime?> selectDate(BuildContext context, TextEditingController controller ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final formattedDate = DateFormat('MM/dd/yyyy').format(picked);
      controller.text = formattedDate;
      return picked;
    }
    return null;
  }
}
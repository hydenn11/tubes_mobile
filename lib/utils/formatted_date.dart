import 'package:intl/intl.dart';

String formatTanggal(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(date);
  } catch (e) {
    return dateString;
  }
}

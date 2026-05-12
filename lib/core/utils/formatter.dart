import 'package:intl/intl.dart';

class Formatter {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String currency(num value) => _currency.format(value);

  static String date(DateTime date) =>
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);

  static String shortDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);
}

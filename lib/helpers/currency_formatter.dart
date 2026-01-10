import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _euroFormat = NumberFormat.currency(
    locale: 'pt_PT',
    symbol: '€',
  );

  static String euro(num? value) {
    if (value == null) return '€0.00';
    return _euroFormat.format(value);
  }
}

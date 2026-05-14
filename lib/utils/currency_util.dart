import 'package:intl/intl.dart';

class CurrencyUtil {
  static final _rupiahFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(dynamic value) {
    if (value == null) return 'Rp 0';
    
    double? amount;
    if (value is String) {
      amount = double.tryParse(value);
    } else if (value is int) {
      amount = value.toDouble();
    } else if (value is double) {
      amount = value;
    }
    
    if (amount == null) return 'Rp 0';
    return _rupiahFormatter.format(amount);
  }
}

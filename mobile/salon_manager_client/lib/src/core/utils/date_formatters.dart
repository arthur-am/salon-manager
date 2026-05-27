import 'package:intl/intl.dart';

class DateFormatters {
  static final date = DateFormat('dd/MM/yyyy');
  static final dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final time = DateFormat('HH:mm');

  static String compact(DateTime value) => dateTime.format(value);
  static String day(DateTime value) => date.format(value);
  static String hour(DateTime value) => time.format(value);
}

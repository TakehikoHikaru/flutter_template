import 'package:intl/intl.dart';

class DateTimeUtil {
  static int formatDateToNumber(DateTime date, {Duration? subtract}) {
    if (subtract != null) {
      date = date.subtract(subtract);
    }

    String year = date.year.toString();
    String month = date.month < 10 ? "0${date.month}" : date.month.toString();
    String day = date.day < 10 ? "0${date.day}" : date.day.toString();
    String hour = date.hour < 10 ? "0${date.hour}" : date.hour.toString();
    String minutes = date.minute < 10 ? "0${date.minute}" : date.minute.toString();
    String seconds = date.second < 10 ? "0${date.second}" : date.second.toString();
    String miliSeconds = date.millisecond >= 100
        ? date.millisecond.toString()
        : date.millisecond >= 10
            ? '0${date.millisecond}'
            : '00${date.millisecond}';
    return int.parse("${year}${month}${day}${hour}${minutes}${seconds}${miliSeconds}");
  }

  static int formatDayToNumber(DateTime date, {Duration? subtract}) {
    if (subtract != null) {
      date = date.subtract(subtract);
    }

    String year = date.year.toString();
    String month = date.month < 10 ? "0${date.month}" : date.month.toString();
    String day = date.day < 10 ? "0${date.day}" : date.day.toString();
    String hour = "00";
    String minutes = "00";
    String seconds = "00";
    String miliSeconds = "000";
    return int.parse("${year}${month}${day}${hour}${minutes}${seconds}${miliSeconds}");
  }

  static String formatNumberToString(int number) {
    String string = number.toString();
    return "${string.substring(6, 8)}/${string.substring(4, 6)}/${string.substring(0, 4)}";
  }

  static DateTime formatAberturaComHora(String aberturaComHora) {
    DateFormat format = DateFormat("dd/MM/yyyy HH:mm");
    DateTime dateTime = format.parse(aberturaComHora);
    return dateTime;
  }
}

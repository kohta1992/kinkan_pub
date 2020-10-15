import "package:intl/intl.dart";
class DateFormatConst{
  static final DateFormat dateHyphen = DateFormat('yyyy-MM-dd', "ja_JP");
  static final DateFormat monthDayWeekday = DateFormat('MM/dd(E)', "ja_JP");
  static final DateFormat hourMinuet = DateFormat('HH:mm', "ja_JP");
  static final DateFormat weekday = DateFormat('E', "ja_JP");
}

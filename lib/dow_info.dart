import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:nholiday_jp/nholiday_jp.dart';

final List<String> workPlaceList = ["リモート", "出社", "休暇", "祝日"];

final DateFormat dateFormat = DateFormat('MM/dd(E)', "ja_JP");
final DateFormat timeFormat = DateFormat('HH:mm', "ja_JP");
final DateFormat weekdayFormat = DateFormat('E', "ja_JP");
final DateFormat parseDateFormat = DateFormat('yyyy-MM-dd', "ja_JP");
final DateFormat subjectDateFormat = DateFormat('hh:mm', "ja_JP");

final Duration plusDuration = Duration(minutes: 15);
final Duration minusDuration = Duration(minutes: -15);

class DOWInfo {
  DateTime startDateTime;

  DateTime endDateTime;

  String workPlace;

  TextEditingController startTimeController;
  TextEditingController endTimeController;

  DOWInfo({this.startDateTime, this.endDateTime, this.workPlace}) {
    startDateTime ??= DateTime.parse(
        '${parseDateFormat.format(DateTime.now())} 09:00:00.000');
    endDateTime ??=
        DateTime.parse('${parseDateFormat.format(startDateTime)} 17:30:00.000');

    workPlace ??= workPlaceList[0];

    startTimeController = TextEditingController(text: '${getStartTime()}');
    endTimeController = TextEditingController(text: '${getEndTime()}');
  }

  String toStringWithoutTime() {
    return '${getDate()} ${workPlace == workPlaceList[3] ? NHolidayJp.getName(startDateTime.year, startDateTime.month, startDateTime.day) ?? workPlace : workPlace}';
  }

  @override
  String toString() {
    if (workPlace == workPlaceList[2] || workPlace == workPlaceList[3]) {
      return toStringWithoutTime();
    }
    return '${getDate()} ${getStartTime()}-${getEndTime()} $workPlace';
  }

  String getDate() {
    return '${dateFormat.format(startDateTime)}';
  }

  String getDateForParse() {
    return '${parseDateFormat.format(startDateTime)}';
  }

  String getStartTime() {
    return '${timeFormat.format(startDateTime)}';
  }

  String getEndTime() {
    return '${timeFormat.format(endDateTime)}';
  }

  String getWeekday() {
    return '${weekdayFormat.format(endDateTime)}';
  }

  String getSubjectForOutlook(bool isSettingTime) {
    if (!isSettingTime || workPlace == workPlaceList[2] || workPlace == workPlaceList[3]) {
      return workPlace;
    }
    return '${getStartTime()}-${getEndTime()} $workPlace';
  }

  String getStartDateTimeForOutlook() {
    var dateTime = DateTime(startDateTime.year, startDateTime.month,
        startDateTime.day, 0, 0, 0, 0, 0);
    return dateTime.toString();
  }

  String getEndDateTimeForOutlook() {
    var dateTime = DateTime(startDateTime.year, startDateTime.month,
        startDateTime.day, 0, 0, 0, 0, 0);
    dateTime = dateTime.add(Duration(days: 1));
    return dateTime.toString();
  }

  double getWorkingTime() {
    return (DateTimeRange(start: startDateTime, end: endDateTime)
                .duration
                .inMinutes /
            Duration.minutesPerHour) -
        1;
  }

  void incrementStartTime() {
    var addedDateTime = startDateTime.add(plusDuration);
    if (startDateTime.day == addedDateTime.day) {
      startDateTime = addedDateTime;
      startTimeController.text = getStartTime();
    }
    return;
  }

  void decrementStartTime() {
    var addedDateTime = startDateTime.add(minusDuration);
    if (startDateTime.day == addedDateTime.day) {
      startDateTime = addedDateTime;
      startTimeController.text = getStartTime();
    }
    return;
  }

  void incrementEndTime() {
    var addedDateTime = endDateTime.add(plusDuration);
    if (endDateTime.day == addedDateTime.day) {
      endDateTime = addedDateTime;
      endTimeController.text = getEndTime();
    }
  }

  void decrementEndTime() {
    var addedDateTime = endDateTime.add(minusDuration);
    if (endDateTime.day == addedDateTime.day) {
      endDateTime = addedDateTime;
      endTimeController.text = getEndTime();
    }
  }
}

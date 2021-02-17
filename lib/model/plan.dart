import 'package:flutter/material.dart';
import 'package:nholiday_jp/nholiday_jp.dart';

import 'date_format_const.dart';

class PlanModel {
  /// 開始日時
  DateTime startDateTime;

  /// 終了日時.
  DateTime endDateTime;

  /// 勤務状態
  WorkState workState;

  String holidayName;

  Map<WorkState, String> workStateMap;

  PlanModel({this.startDateTime, this.endDateTime, this.workState}) {
    String today = DateFormatConst.dateHyphen.format(DateTime.now());
    startDateTime ??= DateTime.parse('$today 09:00:00.000');
    endDateTime ??= DateTime.parse('$today 17:30:00.000');

    holidayName = NHolidayJp.getName(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
    );

    workState ??= WorkState.REMOTE;
    if(holidayName != null){
      workState = WorkState.PUBLIC_HOLIDAY;
    }

    workStateMap = {};
    workStateMap.addAll(defaultWorkStateMap);

    if (holidayName != null) {
      workStateMap.addAll({WorkState.PUBLIC_HOLIDAY: "祝日"});
    }
  }

  String getDate() {
    return '${DateFormatConst.monthDayWeekday.format(startDateTime)}';
  }

  String getStartTime() {
    return '${DateFormatConst.hourMinuet.format(startDateTime)}';
  }

  String getEndTime() {
    return '${DateFormatConst.hourMinuet.format(endDateTime)}';
  }

  String getWorkStateString() {
    return workStateMap[workState];
  }

  addDate(int days, {WorkState defaultWorkState}) {
    var duration = Duration(days: days);
    startDateTime = startDateTime.add(duration);
    endDateTime = endDateTime.add(duration);

    // 祝日名を取得
    holidayName = NHolidayJp.getName(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
    );

    if(holidayName == null){
      workStateMap.remove(WorkState.PUBLIC_HOLIDAY);
    }else{
      workStateMap.addAll({WorkState.PUBLIC_HOLIDAY: holidayName});

    }

    if (workState != WorkState.PUBLIC_HOLIDAY) {
      if (holidayName != null) {
        workState = WorkState.PUBLIC_HOLIDAY;
      }
    } else {
      if (holidayName == null) {
        workState = defaultWorkState ?? WorkState.REMOTE;

      }
    }
  }

  //TODO durationで渡さないほうがいいかも
  addStartTime(Duration duration) {
    var addedDatetime = startDateTime.add(duration);
    if (addedDatetime.difference(startDateTime).inDays == 0 &&
        addedDatetime.day == startDateTime.day) {
      startDateTime = addedDatetime;
    } else {
      if (addedDatetime.isAfter(startDateTime)) {
        startDateTime = addedDatetime.add(Duration(days: -1));
      } else {
        startDateTime = addedDatetime.add(Duration(days: 1));
      }
    }
  }

  addEndTime(Duration duration) {
    var addedDatetime = endDateTime.add(duration);
    if (addedDatetime.difference(endDateTime).inDays == 0 &&
        addedDatetime.day == endDateTime.day) {
      endDateTime = addedDatetime;
    } else {
      if (addedDatetime.isAfter(endDateTime)) {
        endDateTime = addedDatetime.add(Duration(days: -1));
      } else {
        endDateTime = addedDatetime.add(Duration(days: 1));
      }
    }
  }

  setWorkingTime(Duration duration) {
    endDateTime = startDateTime.add(duration);
  }

  double getWorkingTime() {
    return (DateTimeRange(start: startDateTime, end: endDateTime)
                .duration
                .inMinutes /
            Duration.minutesPerHour) -
        1;
  }

  setDefaultTime() {
    String date = DateFormatConst.dateHyphen.format(startDateTime);
    startDateTime = DateTime.parse('$date 09:00:00.000');
    endDateTime = DateTime.parse('$date 17:30:00.000');
  }


  String getSubjectForOutlook(bool isTimeUnneeded) {
    if (isTimeUnneeded || workState == WorkState.PAID_VACATION || workState == WorkState.SEASON_VACATION) {
      return workStateMap[workState];
    }

    if(workState == WorkState.PUBLIC_HOLIDAY){
      return holidayName;
    }

    return '${getStartTime()}-${getEndTime()} ${workStateMap[workState]}';
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

}

enum WorkState {
  OFFICE,
  REMOTE,
  PAID_VACATION,
  PUBLIC_HOLIDAY,
  SEASON_VACATION,
}

final defaultWorkStateMap = {
  WorkState.OFFICE: "出社",
  WorkState.REMOTE: "リモート",
  WorkState.PAID_VACATION: "有給休暇",
  WorkState.SEASON_VACATION: "季節休暇",
};

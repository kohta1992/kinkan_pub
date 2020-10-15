import 'package:kinkanutilapp/model/date_format_const.dart';
import 'package:kinkanutilapp/model/plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  Future<String> getDefaultStartTimeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('defaultStartTime') ?? '09:00';
  }

  Future<String> getDefaultEndTimeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('defaultEndTime') ?? '17:30';
  }

  Future<void> setDefaultStartTimeValue(DateTime dateTime) async {
    var time = DateFormatConst.hourMinuet.format(dateTime);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('defaultStartTime', time);
  }

  Future<void> setDefaultEndTimeValue(DateTime dateTime) async {
    var time = DateFormatConst.hourMinuet.format(dateTime);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('defaultEndTime', time);
  }

  Future<WorkState> getDefaultWorkStateValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var workStateName = prefs.getString('defaultWorkState');
    var workState = WorkState.REMOTE;
    if (workStateName != null) {
      defaultWorkStateMap.forEach((key, value) {
        if (value == workStateName) {
          workState = key;
        }
      });
    }
    return workState;
  }

  Future<void> setDefaultWorkStateValue(WorkState workState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'defaultWorkState',
        defaultWorkStateMap[workState] ??
            defaultWorkStateMap[WorkState.REMOTE]);
  }

  Future<bool> getIsTimeUnneeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isTimeUnneeded') ?? true;
  }

  Future<void> setIsTimeUnneeded(bool isTimeUnneeded) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isTimeUnneeded', isTimeUnneeded);
  }
}

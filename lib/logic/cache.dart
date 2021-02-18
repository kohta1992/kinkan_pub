import 'package:kinkanutilapp/model/date_format_const.dart';
import 'package:kinkanutilapp/model/plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static SharedPreferences _prefs;

  Cache();

  static Future<String> getDefaultStartTimeValue() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs.getString('defaultStartTime') ?? '09:00';
  }

  static Future<String> getDefaultEndTimeValue() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs.getString('defaultEndTime') ?? '17:30';
  }

  static Future<void> setDefaultStartTimeValue(DateTime dateTime) async {
    var time = DateFormatConst.hourMinuet.format(dateTime);
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString('defaultStartTime', time);
  }

  static Future<void> setDefaultEndTimeValue(DateTime dateTime) async {
    var time = DateFormatConst.hourMinuet.format(dateTime);
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString('defaultEndTime', time);
  }

  static Future<WorkState> getDefaultWorkStateValue() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    var workStateName = _prefs.getString('defaultWorkState');
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

  static Future<void> setDefaultWorkStateValue(WorkState workState) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString(
        'defaultWorkState',
        defaultWorkStateMap[workState] ??
            defaultWorkStateMap[WorkState.REMOTE]);
  }

  static Future<String> getChannelMessageInfo() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs.getString('channelMessageInfo') ?? "";
  }

  static Future<void> setChannelMessageInfo(String channelMessageInfo) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString('channelMessageInfo', channelMessageInfo);
  }
  static Future<bool> getIsTimeUnneeded() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs.getBool('isTimeUnneeded') ?? true;
  }

  static Future<void> setIsTimeUnneeded(bool isTimeUnneeded) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setBool('isTimeUnneeded', isTimeUnneeded);
  }

  static Future<String> getChannelId() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs.getString('channelId') ?? "";
  }

  static Future<void> setChannelId(String channelId) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString('channelId', channelId);
  }

  static Future<String> getGroupId() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs.getString('groupId') ?? "";
  }

  static Future<void> setGroupId(String groupId) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    _prefs.setString('groupId', groupId);
  }


}

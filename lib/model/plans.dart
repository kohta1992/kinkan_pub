import 'package:flutter/material.dart';
import 'package:kinkanutilapp/logic/cache.dart';
import 'package:kinkanutilapp/model/plan.dart';

class PlansModel extends ChangeNotifier {
  PlanModel _defaultPlan;
  List<PlanModel> _plans = [];

  // bool _isNeedsTime;
  bool _isTimeUnneeded;

  // String _currentWeekMessageId;

  PlansModel(
      {DateTime startTime,
      DateTime endTime,
      WorkState workState,
      bool isTimeUnneeded,
      String currentWeekMessageId}) {
    _defaultPlan = PlanModel(
        startDateTime: startTime, endDateTime: endTime, workState: workState);

    int diff = DateTime.monday - DateTime.now().weekday;
    if (diff > 1) {
      diff -= 8;
    }
    diff += 7;

    for (int i = 0; i < 5; i++) {
      _plans.add(PlanModel(
          startDateTime: startTime,
          endDateTime: endTime,
          workState: workState));
    }

    _initDate();

    _isTimeUnneeded = isTimeUnneeded ?? false;

    // _currentWeekMessageId = currentWeekMessageId ?? "";
  }

  PlanModel get defaultPlan => _defaultPlan;

  set defaultPlan(PlanModel newPlan) {
    assert(newPlan != null);
    _defaultPlan = newPlan;
    notifyListeners();
  }

  List<PlanModel> get plans => _plans;

  PlanModel getPlan(int index) {
    assert(index < _plans.length);
    return _plans[index];
  }

  setPlan(int index, PlanModel newPlan) {
    assert(newPlan != null);
    assert(index < _plans.length);
    _plans[index] = newPlan;
    notifyListeners();
  }

  resetDate() {
    _initDate();
    notifyListeners();
  }

  addDate(int days) {
    _plans.forEach((plan) {
      plan.addDate(days, defaultWorkState: _defaultPlan.workState);
    });
    notifyListeners();
  }

  resetDefaultTime() {
    _defaultPlan.setDefaultTime();
    _plans.forEach((plan) {
      plan.setDefaultTime();
    });
    notifyListeners();
    Cache.setDefaultStartTimeValue(_defaultPlan.startDateTime);
    Cache.setDefaultEndTimeValue(_defaultPlan.endDateTime);
  }

  addDefaultStartTime(Duration duration) {
    assert(duration != null);

    _addStartTime(_defaultPlan, duration);
    _plans.forEach((plan) {
      _addStartTime(plan, duration);
    });

    Cache.setDefaultStartTimeValue(_defaultPlan.startDateTime);
  }

  addDefaultEndTime(Duration duration) {
    assert(duration != null);

    _addEndTime(_defaultPlan, duration);
    _plans.forEach((plan) {
      _addEndTime(plan, duration);
    });

    Cache.setDefaultEndTimeValue(_defaultPlan.endDateTime);
  }

  setDefaultWorkingTime(Duration duration) {
    assert(duration != null);
    _defaultPlan.setWorkingTime(duration);
    _plans.forEach((plan) {
      plan.setWorkingTime(duration);
    });
    notifyListeners();
    Cache.setDefaultEndTimeValue(_defaultPlan.endDateTime);
  }

  setDefaultWorkState(WorkState newWorkState) {
    assert(newWorkState != null);
    _defaultPlan.workState = newWorkState;
    _plans.forEach((plan) {
      plan.workState = newWorkState;
    });
    notifyListeners();
    Cache.setDefaultWorkStateValue(_defaultPlan.workState);
  }

  addStartTime(int index, Duration duration) {
    assert(index < _plans.length);
    _addStartTime(_plans[index], duration);
  }

  addEndTime(int index, Duration duration) {
    assert(index < _plans.length);
    _addEndTime(_plans[index], duration);
  }

  setWorkState(int index, WorkState newWorkState) {
    assert(index < _plans.length);
    assert(newWorkState != null);

    _plans[index].workState = newWorkState;
    notifyListeners();
  }

  _addStartTime(PlanModel plan, Duration duration) {
    assert(plan != null);
    plan.addStartTime(duration);
    notifyListeners();
  }

  _addEndTime(PlanModel plan, Duration duration) {
    assert(plan != null);
    plan.addEndTime(duration);
    notifyListeners();
  }

  bool get isTimeUnneeded => _isTimeUnneeded;

  setIsTimeUnneeded(bool isTimeUnneeded) {
    _isTimeUnneeded = isTimeUnneeded;
    notifyListeners();
    Cache.setIsTimeUnneeded(_isTimeUnneeded);
  }

  _initDate() {
    int diff = DateTime.monday - DateTime.now().weekday;
    if (diff > 1) {
      diff -= 8;
    }
    diff += 7;

    int i = 0;
    _plans.forEach((plan) {
      var addedDate = DateTime.now().add(new Duration(days: diff + i));

      plan.startDateTime = DateTime(
          addedDate.year,
          addedDate.month,
          addedDate.day,
          plan.startDateTime.hour,
          plan.startDateTime.minute,
          plan.startDateTime.second);
      plan.endDateTime = DateTime(
          addedDate.year,
          addedDate.month,
          addedDate.day,
          plan.endDateTime.hour,
          plan.endDateTime.minute,
          plan.endDateTime.second);
      i++;
    });
  }

  String getPlansSubject() {
    var subject = "";
    subject += _plans[0].getDate();
    subject += '-';
    subject += _plans[4].getDate();
    subject += ' 勤務予定 ()';
    return subject;
  }

  String getPlansBody() {
    var body = "";
    _plans.forEach((plan) {
      body += plan.getDate();
      body += ' ';
      if (!_isTimeUnneeded &&
          !(plan.workState == WorkState.PAID_VACATION ||
              plan.workState == WorkState.PUBLIC_HOLIDAY ||
              plan.workState == WorkState.SEASON_VACATION)) {
        body += plan.getStartTime();
        body += '-';
        body += plan.getEndTime();
        body += ' ';
      }
      if (plan.workState == WorkState.PUBLIC_HOLIDAY) {
        body += plan.holidayName;
      } else {
        body += plan.getWorkStateString();
      }

      if (plan.startDateTime.weekday != DateTime.friday) {
        body += '\n';
      }
    });
    return body;
  }

  String getPlansSubjectForTeams(String name) {
    var subject = "";
    subject += _plans[0].getDate();
    subject += '-';
    subject += _plans[4].getDate();
    subject += ' 勤務予定 ($name)';
    return subject;
  }

  String getPlansBodyForTeams() {
    var body = "";
    _plans.forEach((plan) {
      body += plan.getDate();
      body += ' ';
      if (!_isTimeUnneeded &&
          !(plan.workState == WorkState.PAID_VACATION ||
              plan.workState == WorkState.PUBLIC_HOLIDAY ||
              plan.workState == WorkState.SEASON_VACATION)) {
        body += plan.getStartTime();
        body += '-';
        body += plan.getEndTime();
        body += ' ';
      }
      if (plan.workState == WorkState.PUBLIC_HOLIDAY) {
        body += plan.holidayName;
      } else {
        body += plan.getWorkStateString();
      }

      if (plan.startDateTime.weekday != DateTime.friday) {
        body += '<br>';
      }
    });
    return body;
  }

  String getPlansText() {
    return '${getPlansSubject()}\n${getPlansBody()}';
  }
}

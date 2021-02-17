import 'package:flutter/material.dart';
import 'package:kinkanutilapp/model/plan.dart';
import 'package:kinkanutilapp/model/plans.dart';
import 'package:provider/provider.dart';

class DefaultPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return Center(
      child: Container(
        child: Column(
          children: [
            _DateArea(),
            plansModel.isTimeUnneeded ? Container() : _TimeArea(),
            plansModel.isTimeUnneeded ? Container() : _TimeIntervalArea(),
            _WorkStateArea(),
            _OptionArea(),
          ],
        ),
      ),
    );
  }
}

class _DateArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return SizedBox(
      height: 70,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.black54,
                    ),
                    Center(
                        child: const Text(
                      '日付',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    )),
                  ]),
            ),
            SizedBox(
              width: 360,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () => plansModel.addDate(-7),
                        color: Colors.blueGrey,
                        icon: Icon(
                          Icons.keyboard_arrow_left,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: Center(
                        child: Text(
                          '${plansModel.plans[0].getDate()} 〜 ${plansModel.plans[4].getDate()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () => plansModel.addDate(7),
                        color: Colors.blueGrey,
                        icon: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    Container(
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () => plansModel.resetDate(),
                        color: Colors.blueGrey,
                        icon: Icon(Icons.autorenew_rounded),
                      ),
                    ),
                  ]),
            ),
          ]),
    );
  }
}

class _OptionArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return SizedBox(
      height: 70,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apps,
                      size: 20,
                      color: Colors.black54,
                    ),
                    Center(
                        child: const Text(
                      'オプション',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    )),
                  ]),
            ),
            SizedBox(
              width: 360,
              child: CheckboxListTile(
                activeColor: Colors.blue,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  '時間を設定しない',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                value: plansModel.isTimeUnneeded,
                onChanged: (bool e) {
                  plansModel.setIsTimeUnneeded(e);
                },
              ),
            ),
          ]),
    );
  }
}

class _TimeArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: Colors.black54,
                  ),
                  Center(
                      child: const Text(
                    '勤務時刻',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )),
                ]),
          ),
          SizedBox(
            width: 360,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: IconButton(
                      iconSize: 20,
                      onPressed: () {
                        plansModel.addDefaultStartTime(Duration(minutes: -15));
                        plansModel.addDefaultEndTime(Duration(minutes: -15));
                      },
                      color: Colors.blueGrey,
                      icon: Icon(Icons.keyboard_arrow_left),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: Center(
                      child: Text(
                        '${plansModel.defaultPlan.getStartTime()} 〜 ${plansModel.defaultPlan.getEndTime()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      iconSize: 20,
                      onPressed: () {
                        plansModel.addDefaultStartTime(Duration(minutes: 15));
                        plansModel.addDefaultEndTime(Duration(minutes: 15));
                      },
                      color: Colors.blueGrey,
                      icon: Icon(Icons.keyboard_arrow_right),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      iconSize: 20,
                      onPressed: () => plansModel..resetDefaultTime(),
                      color: Colors.blueGrey,
                      icon: Icon(Icons.autorenew_rounded),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}

class _TimeIntervalArea extends StatelessWidget {
  _reset(PlansModel plansModel) {
    plansModel.setDefaultWorkingTime(Duration(hours: 8, minutes: 30));
  }

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);

    return SizedBox(
      height: 70,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timelapse,
                      size: 20,
                      color: Colors.black54,
                    ),
                    Center(
                        child: const Text(
                      '勤務時間',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    )),
                  ]),
            ),
            SizedBox(
              width: 360,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () => plansModel
                            .addDefaultEndTime(Duration(minutes: -15)),
                        color: Colors.blueGrey,
                        icon: Icon(Icons.keyboard_arrow_left),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: Center(
                        child: Text(
                          '${plansModel.defaultPlan.getWorkingTime()} 時間',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () =>
                            plansModel.addDefaultEndTime(Duration(minutes: 15)),
                        color: Colors.blueGrey,
                        icon: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    Container(
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () => _reset(plansModel),
                        color: Colors.blueGrey,
                        icon: Icon(Icons.autorenew_rounded),
                      ),
                    ),
                  ]),
            ),
          ]),
    );
  }
}

class _WorkStateArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);

    return SizedBox(
      height: 70,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.place,
                    size: 20,
                    color: Colors.black54,
                  ),
                  Center(
                      child: const Text(
                    '場所',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )),
                ],
              ),
            ),
            SizedBox(
              width: 360,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: RaisedButton(
                      child: const Text(
                        'リモート',
                        style: TextStyle(color: Colors.white),
                      ),
                      disabledColor: Colors.blue,
                      color: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      onPressed: plansModel.defaultPlan.workState ==
                              WorkState.REMOTE
                          ? null
                          : () =>
                              plansModel.setDefaultWorkState(WorkState.REMOTE),
                    ),
                  ),
                  Container(
                    child: RaisedButton(
                      child: const Text(
                        '出社',
                        style: TextStyle(color: Colors.white),
                      ),
                      disabledColor: Colors.blue,
                      color: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      onPressed: plansModel.defaultPlan.workState ==
                          WorkState.OFFICE
                          ? null
                          : () =>
                          plansModel.setDefaultWorkState(WorkState.OFFICE),
                    ),
                  ),
                ],
              ),
            ),
          ]),
    );
  }
}

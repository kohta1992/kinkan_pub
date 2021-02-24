import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kinkanutilapp/screen/users.dart';
import 'package:provider/provider.dart';

import 'logic/Cache.dart';
import 'model/date_format_const.dart';
import 'model/plan.dart';
import 'model/plans.dart';
import 'screen/home.dart';

void main() {
  initializeDateFormatting("ja_JP");
  runApp(MyApp());
}

final appTitle = 'Kinkan';

class MyApp extends StatelessWidget {
  Future<void> init(PlansModel plansModel) async {
    String today = DateFormatConst.dateHyphen.format(DateTime.now());
    String startTime;
    DateTime startDateTime;
    await Cache.getDefaultStartTimeValue().then((value) {
      startTime = value;
      startDateTime = DateTime.parse('$today $startTime:00.000');
    });

    String endTime;
    DateTime endDateTime;
    await Cache.getDefaultEndTimeValue().then((value) {
      endTime = value;
      endDateTime = DateTime.parse('$today $endTime:00.000');
    });

    WorkState workState;
    await Cache.getDefaultWorkStateValue().then((value) {
      workState = value;
    });

    plansModel.setIsTimeUnneeded(await Cache.getIsTimeUnneeded());

    var defaultPlan = PlanModel(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        workState: workState);

    plansModel.defaultPlan = defaultPlan;

    var index = 0;
    plansModel.plans.forEach((plan) {
      today = DateFormatConst.dateHyphen.format(plan.startDateTime);
      startDateTime = DateTime.parse('$today $startTime:00.000');
      endDateTime = DateTime.parse('$today $endTime:00.000');

      var newPlan = PlanModel(
          startDateTime: startDateTime,
          endDateTime: endDateTime,
          workState: workState);
      plansModel.setPlan(index, newPlan);
      index++;
    });

    Map newMap = {};
    String channelMessageInfo = await Cache.getChannelMessageInfo();
    try {
      if (channelMessageInfo.isEmpty) {
        return;
      }
      Map channelMessageInfoMap = jsonDecode(channelMessageInfo);
      List<Map> newList = [];

      channelMessageInfoMap["channelMessageInfo"].forEach((element) {
        if (element["endDate"] >= DateTime.now().millisecondsSinceEpoch) {
          newList.add(element);
        }
      });

      newMap.addAll({"channelMessageInfo": newList});

      await Cache.setChannelMessageInfo(jsonEncode(newMap));
    } catch (e) {
      debugPrint('channel message info save error.');
      debugPrint('channel message info=$channelMessageInfo');
    }

    return plansModel;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlansModel>(
        create: (context) {
          PlansModel plansModel = PlansModel();
          init(plansModel);
          return plansModel;
        },
        child: MaterialApp(
          title: appTitle,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routes: {
            '/users': (_) => UsersPage(),
          },
          home: Builder(builder: (BuildContext context) {
            return Scaffold(
                appBar: AppBar(
                  title: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          child: Image(
                              image: AssetImage('assets/kinkan.png'),
                              fit: BoxFit.cover),
                        ),
                        Text(appTitle,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  actions: [
                    FlatButton(
                      child: Text('勤務状況 (beta)',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/users');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.info),
                      color: Colors.white,
                      onPressed: () => showAboutDialog(
                        context: context,
                        applicationName: appTitle,
                        applicationVersion: '1.2.1',
                      ),
                    ),
                  ],
                  centerTitle: true,
                  backgroundColor: Colors.blueAccent,
                  toolbarHeight: 40,
                  elevation: 0,
                ),
                body: Home());
          }),
        ));
  }
}



import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'logic/cache.dart';
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
    var cache = Cache();

    String today = DateFormatConst.dateHyphen.format(DateTime.now());
    String startTime;
    DateTime startDateTime;
    await cache.getDefaultStartTimeValue().then((value) {
      startTime = value;
      startDateTime = DateTime.parse('$today $startTime:00.000');
    });

    String endTime;
    DateTime endDateTime;
    await cache.getDefaultEndTimeValue().then((value) {
      endTime = value;
      endDateTime = DateTime.parse('$today $endTime:00.000');
    });

    WorkState workState;
    await cache.getDefaultWorkStateValue().then((value) {
      workState = value;
    });

    plansModel.setIsTimeUnneeded(await cache.getIsTimeUnneeded());

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
                    IconButton(
                      icon: Icon(Icons.info),
                      color: Colors.blueGrey,
                      onPressed: () => showAboutDialog(
                        context: context,
                        applicationName: 'Kinkan',
                        applicationVersion: '1.1.0',
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

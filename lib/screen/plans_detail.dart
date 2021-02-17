import 'package:flutter/material.dart';
import 'package:kinkanutilapp/model/plan.dart';
import 'package:kinkanutilapp/model/plans.dart';
import 'package:provider/provider.dart';

class PlansDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int index = 0; index < 5; index++) _MyListItem(index)
          ],
        ),
      ),
    );
  }
}

class _MyListItem extends StatelessWidget {
  final int index;

  _MyListItem(this.index, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    var plan = plansModel.plans[index];
    var isTimeSettingEnabled = !plansModel.isTimeUnneeded &&
        (plan.workState == WorkState.OFFICE ||
            plan.workState == WorkState.REMOTE);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            plan.getDate(),
            style: TextStyle(
              color: plan.holidayName == null ? Colors.black87 : Colors.red,
            ),
          ),
          _WorkStateDropBox(
            index: index,
          ),
          isTimeSettingEnabled
              ? Row(children: [
                  _StartTimeText(
                    index: index,
                  ),
                  SizedBox(
                    width: 20,
                    child: Center(
                      child: Text('～'),
                    ),
                  ),
                  _EndTimeText(
                    index: index,
                  ),
                ])
              : SizedBox(
                  width: 180,
                ),
        ],
      ),
    );
  }
}

class _StartTimeText extends StatelessWidget {
  final int index;

  const _StartTimeText({Key key, @required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return Container(
      width: 80,
      height: 50,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        children: [
          Container(
              width: 50,
              child: Text(
                plansModel.plans[index].getStartTime(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                ),
              )),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    plansModel.addStartTime(index, (Duration(minutes: 15)));
                  },
                  splashColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.arrow_drop_up,
                    size: 15,
                    color: Colors.black54,
                  ),
                ),
                InkWell(
                  onTap: () {
                    plansModel.addStartTime(index, (Duration(minutes: -15)));
                  },
                  splashColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EndTimeText extends StatelessWidget {
  final int index;

  const _EndTimeText({Key key, @required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return Container(
      width: 80,
      height: 50,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        children: [
          Container(
              width: 50,
              child: Text(
                plansModel.plans[index].getEndTime(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                ),
              )),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    plansModel.addEndTime(index, (Duration(minutes: 15)));
                  },
                  splashColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.arrow_drop_up,
                    size: 15,
                    color: Colors.black54,
                  ),
                ),
                InkWell(
                  onTap: () {
                    plansModel.addEndTime(index, (Duration(minutes: -15)));
                  },
                  splashColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkStateDropBox extends StatelessWidget {
  final int index;

  const _WorkStateDropBox({Key key, @required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return Container(
      width: 150,
      height: 50,
      // padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<String>(
            icon: Icon(
              Icons.arrow_drop_down,
              size: 15,
              color: Colors.black54,
            ),
            value: plansModel.plans[index].getWorkStateString(),
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
            underline: Container(
              height: 0,
            ),
            onChanged: (String newValue) {
              plansModel.plans[index].workStateMap.forEach((key, value) {
                if (value == newValue) {
                  plansModel.setWorkState(index, key);
                }
              });
            },
            items:
                plansModel.plans[index].workStateMap.values.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: SizedBox(
                  width: 120.0,
                  child: Text(
                    item,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kinkanutilapp/screen/default_plan.dart';
import 'package:kinkanutilapp/screen/plans_detail.dart';

import 'sidebar.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      width: 550,
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          DefaultPlan(),
                          PlansDetail(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SideBar(),
                _InfoBox(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InfoBoxState();
}

class _InfoBoxState extends State<_InfoBox> {
  bool _isDisplay = false;

  @override
  void initState() {
    _isDisplay = DateTime.now().weekday == DateTime.thursday;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isDisplay
        ? Container(
            width: 250,
            height: 100,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xffF6C098),
              // border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1.0,
                  blurRadius: 10.0,
                  offset: Offset(5, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '今日は木曜日です！\n来週の予定を登録しましょう！',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                    ),
                    onPressed: () {
                      setState(() {
                        _isDisplay = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}

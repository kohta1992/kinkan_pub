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
            Align(alignment: Alignment.centerLeft, child: SideBar())
          ],
        ),
      ),
    );
  }
}

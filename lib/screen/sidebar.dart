import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kinkanutilapp/screen/setting_button.dart';

import 'attendance.dart';
import 'output_plans.dart';

class SideBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  ScrollController _scrollController = ScrollController();

  bool _isPreview = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: _isPreview ? 300 : 60,
      decoration: BoxDecoration(
        color: Color(0xfff0f0f0),
      ),
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Align(
                alignment:
                    _isPreview ? Alignment.topRight : Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutputPlans(
                      isSmall: !_isPreview,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Divider(
                        color: Colors.black26,
                        thickness: 2,
                      ),
                    ),
                    Attendance(
                      isSmall: !_isPreview,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Divider(
                        color: Colors.black26,
                        thickness: 2,
                      ),
                    ),
                    SettingsButton(isSmall: !_isPreview),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment:
                _isPreview ? Alignment.bottomRight : Alignment.bottomCenter,
            child: SizedBox(
              width: 40,
              height: 40,
              child: FlatButton(
                child: InkWell(
                  child: Icon(
                    _isPreview ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.black87,
                  ),
                  mouseCursor: MouseCursor.defer,
                ),
                onPressed: () => setState(() {
                  _isPreview = !_isPreview;
                }),
                color: Color(0xfff0f0f0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

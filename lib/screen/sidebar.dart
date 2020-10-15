
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'output_plans.dart';

class SideBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
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
      child: Stack(
        children: [
          Align(
            alignment: _isPreview ? Alignment.topRight : Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutputPlans(
                  isSmall: !_isPreview,
                ),
              ],
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
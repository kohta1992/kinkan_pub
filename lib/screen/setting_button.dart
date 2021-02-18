import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kinkanutilapp/model/plans.dart';
import 'package:kinkanutilapp/screen/setting_dialog.dart';
import 'package:provider/provider.dart';

class SettingsButton extends StatefulWidget {
  final bool isSmall;

  SettingsButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {

  Future _showDialog() async {
    String inputted = await showSettingDialog(
      context: context,
      title: "",
      body: "",
      input: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return SizedBox(
      width: widget.isSmall ? 40 : double.infinity,
      height: 40,
      child: FlatButton(
        child: widget.isSmall
            ? Tooltip(
          message: '設定',
          child: const InkWell(
            child: Icon(
              Icons.settings,
              color: Colors.black54,
              size: 20,
            ),
            mouseCursor: MouseCursor.defer,
          ),
        )
            : Row(children: [
          const InkWell(
            child: Icon(
              Icons.settings,
              color: Colors.black54,
              size: 20,
            ),
            mouseCursor: MouseCursor.defer,
          ),
          Text(
            '設定',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ]),
        onPressed: _showDialog,
        color: Color(0xfff0f0f0),
        textColor: Colors.black54,
      ),
    );
  }
}
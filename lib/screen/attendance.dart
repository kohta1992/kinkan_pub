import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kinkanutilapp/logic/cache.dart';
import 'package:kinkanutilapp/logic/ms_graph.dart';
import 'package:kinkanutilapp/model/plans.dart';
import 'package:kinkanutilapp/repository/user_repository.dart';
import 'package:kinkanutilapp/screen/input_dialog.dart';
import 'package:provider/provider.dart';

class Attendance extends StatelessWidget {
  final bool isSmall;

  Attendance({@required this.isSmall});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              isSmall ? Container() : _ChannelMessageUrlField(),
              _WorkStartedButton(isSmall: isSmall),
              _WorkEndedButton(isSmall: isSmall),
              _ReplyCurrentPlansButton(isSmall: isSmall),
            ],
          ),
        ),
      ],
    );
  }
}

_showErrorDialog({BuildContext context, String errorMessage}) async {
  MaterialLocalizations localizations = MaterialLocalizations.of(context);
  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text('エラー'),
      content: Text(errorMessage),
      actions: <Widget>[
        FlatButton(
          child: Text(localizations.okButtonLabel),
          onPressed: () {
            Navigator.pop<String>(context);
          },
        ),
      ],
    ),
  );
}

Future<bool> _replyMessage(
    {BuildContext context, PlansModel plansModel, String replyText}) async {
  String resultText = "";
  bool result = true;

  if (plansModel.currentWeekMessageId.isEmpty) {
    resultText = '今週の投稿IDがありません。';
    result = false;
  } else {
    replyText = replyText.replaceAll('\n', '<br>');

    if (await MsGraph()
        .replyChannelMessage(plansModel.currentWeekMessageId, replyText)) {
      resultText = 'Teamsに投稿しました。';
      String channelMessageInfo = await Cache.getChannelMessageInfo();
      try {
        Map channelMessageInfoMap = {};

        if (channelMessageInfo.isNotEmpty) {
          channelMessageInfoMap = json.decode(channelMessageInfo);
        }


        List infoList = channelMessageInfoMap["channelMessageInfo"] ?? [];

        bool existsId = false;

        for (int i = 0; i < infoList.length; i++) {
          if (infoList[i]["id"] == plansModel.currentWeekMessageId) {
            existsId = true;
            break;
          }
        }

        if (!existsId) {
          int diff = DateTime.monday - DateTime.now().weekday;
          if (diff > 1) {
            diff -= 8;
          }

          var monday = DateTime.now().add(new Duration(days: diff));
          var friday = monday.add(Duration(days: 4));

          var startDate = DateTime(
            monday.year,
            monday.month,
            monday.day,
            0,
            0,
            0,
          );

          var endDate = DateTime(
            friday.year,
            friday.month,
            friday.day,
            23,
            59,
            59,
          );

          List newInfoList = [
            {
              "startDate": startDate.millisecondsSinceEpoch,
              "endDate": endDate.millisecondsSinceEpoch,
              "id": plansModel.currentWeekMessageId,
            }
          ];

          if (channelMessageInfoMap.isNotEmpty) {
            List oldList = channelMessageInfoMap["channelMessageInfo"];
            oldList.forEach((element) {
              if (startDate.millisecondsSinceEpoch != element["startDate"]) {
                newInfoList.add(element);
              }
            });
          }
          channelMessageInfoMap = {"channelMessageInfo": newInfoList};
          print(newInfoList);
          await Cache.setChannelMessageInfo(jsonEncode(channelMessageInfoMap));
        }
      } catch (e) {
        debugPrint('channel message info save error.');
        debugPrint('channel message info=$channelMessageInfo');
        throw e;
      }
    } else {
      resultText = 'Teamsへの投稿に失敗しました。';
      result = false;
    }
  }

  final snackBar = SnackBar(
    content: Text(resultText),
    action: SnackBarAction(
      label: '閉じる',
      textColor: Colors.yellow,
      onPressed: () {
        Scaffold.of(context).hideCurrentSnackBar();
      },
    ),
  );
  Scaffold.of(context).showSnackBar(snackBar);

  return result;
}

class _ChannelMessageUrlField extends StatefulWidget {
  @override
  State createState() => _ChannelMessageUrlFieldState();
}

class _ChannelMessageUrlFieldState extends State<_ChannelMessageUrlField> {
  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    this.controller = TextEditingController(
      text: plansModel.currentWeekMessageId,
    );
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: TextFormField(
          decoration: InputDecoration(labelText: "今週の投稿ID"),
          controller: controller,
          onChanged: (newValue) {
            plansModel.currentWeekMessageId = controller.text;
          },
        ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _WorkStartedButton extends StatefulWidget {
  final bool isSmall;

  _WorkStartedButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _WorkStartedButtonState();
}

class _WorkStartedButtonState extends State<_WorkStartedButton> {
  bool _isPosting = false;

  Future _showDialog(PlansModel plansModel) async {
    if (plansModel.currentWeekMessageId.isEmpty) {
      _showErrorDialog(context: context, errorMessage: "今週の投稿IDがありません。");
      return;
    }

    setState(() {
      _isPosting = true;
    });

    String inputted = await showInputDialog(
      context: context,
      title: "業務を開始する",
      body: "以下のメッセージを送信します。よろしいですか？",
      input: "業務を開始します。",
    );

    if (inputted != null && inputted.isNotEmpty) {
      if (await _replyMessage(
          context: context, plansModel: plansModel, replyText: inputted)) {
        var currentUser =
            FirebaseAuth.instanceFor(app: Firebase.app()).currentUser;
        if (currentUser != null) {
          UserRepository().updateState(currentUser, true);
        }
      }
    }

    setState(() {
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return SizedBox(
      width: widget.isSmall ? 40 : double.infinity,
      height: 40,
      child: _isPosting
          ? Center(
              child: Container(
                  width: 20, height: 20, child: CircularProgressIndicator()))
          : FlatButton(
              child: widget.isSmall
                  ? Tooltip(
                      message: '業務を開始する',
                      child: const InkWell(
                        child: Icon(
                          Icons.wb_sunny,
                          color: Colors.black54,
                          size: 20,
                        ),
                        mouseCursor: MouseCursor.defer,
                      ),
                    )
                  : Row(children: [
                      const InkWell(
                        child: Icon(
                          Icons.wb_sunny,
                          color: Colors.black54,
                          size: 20,
                        ),
                        mouseCursor: MouseCursor.defer,
                      ),
                      Text(
                        '業務を開始する',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ]),
              onPressed: () => _showDialog(plansModel),
              color: Color(0xfff0f0f0),
              textColor: Colors.black54,
            ),
    );
  }
}

class _WorkEndedButton extends StatefulWidget {
  final bool isSmall;

  _WorkEndedButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _WorkEndedButtonState();
}

class _WorkEndedButtonState extends State<_WorkEndedButton> {
  bool _isPosting = false;

  Future _showDialog(PlansModel plansModel) async {
    if (plansModel.currentWeekMessageId.isEmpty) {
      _showErrorDialog(context: context, errorMessage: "今週の投稿IDがありません。");
      return;
    }

    setState(() {
      _isPosting = true;
    });

    String inputted = await showInputDialog(
      context: context,
      title: "業務を終了する",
      body: "以下のメッセージを送信します。よろしいですか？",
      input: "業務を終了します。",
    );

    if (inputted != null && inputted.isNotEmpty) {
      if (await _replyMessage(
          context: context, plansModel: plansModel, replyText: inputted)) {
        var currentUser =
            FirebaseAuth.instanceFor(app: Firebase.app()).currentUser;
        if (currentUser != null) {
          UserRepository().updateState(currentUser, false);
        }
      }
    }

    setState(() {
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return SizedBox(
      width: widget.isSmall ? 40 : double.infinity,
      height: 40,
      child: _isPosting
          ? Center(
              child: Container(
                  width: 20, height: 20, child: CircularProgressIndicator()))
          : FlatButton(
              child: widget.isSmall
                  ? Tooltip(
                      message: '業務を終了する',
                      child: const InkWell(
                        child: Icon(
                          Icons.nightlight_round,
                          color: Colors.black54,
                          size: 20,
                        ),
                        mouseCursor: MouseCursor.defer,
                      ),
                    )
                  : Row(children: [
                      const InkWell(
                        child: Icon(
                          Icons.nightlight_round,
                          color: Colors.black54,
                          size: 20,
                        ),
                        mouseCursor: MouseCursor.defer,
                      ),
                      Text(
                        '業務を終了する',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ]),
              onPressed: () => _showDialog(plansModel),
              color: Color(0xfff0f0f0),
              textColor: Colors.black54,
            ),
    );
  }
}

class _ReplyCurrentPlansButton extends StatefulWidget {
  final bool isSmall;

  _ReplyCurrentPlansButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _ReplyCurrentPlansButtonState();
}

class _ReplyCurrentPlansButtonState extends State<_ReplyCurrentPlansButton> {
  bool _isPosting = false;

  Future _showDialog(PlansModel plansModel) async {
    if (plansModel.currentWeekMessageId.isEmpty) {
      _showErrorDialog(context: context, errorMessage: "今週の投稿IDがありません。");
      return;
    }
    setState(() {
      _isPosting = true;
    });

    if (plansModel.currentWeekMessageId.isEmpty) {
      MaterialLocalizations localizations = MaterialLocalizations.of(context);
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('エラー'),
          content: Text('今週の投稿IDがありません。'),
          actions: <Widget>[
            FlatButton(
              child: Text(localizations.okButtonLabel),
              onPressed: () {
                Navigator.pop<String>(context);
              },
            ),
          ],
        ),
      );
      return false;
    }

    String inputted = await showInputDialog(
      context: context,
      title: "予定に返信する",
      body: "以下のメッセージを送信します。よろしいですか？",
      inputHint: "今週の予定に返信する内容を入力してください。",
    );

    if (inputted != null && inputted.isNotEmpty) {
      await _replyMessage(
          context: context, plansModel: plansModel, replyText: inputted);
    }

    setState(() {
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return SizedBox(
      width: widget.isSmall ? 40 : double.infinity,
      height: 40,
      child: _isPosting
          ? Center(
              child: Container(
                  width: 20, height: 20, child: CircularProgressIndicator()))
          : FlatButton(
              child: widget.isSmall
                  ? Tooltip(
                      message: '予定に返信する',
                      child: const InkWell(
                        child: Icon(
                          Icons.reply,
                          color: Colors.black54,
                          size: 20,
                        ),
                        mouseCursor: MouseCursor.defer,
                      ),
                    )
                  : Row(children: [
                      const InkWell(
                        child: Icon(
                          Icons.reply,
                          color: Colors.black54,
                          size: 20,
                        ),
                        mouseCursor: MouseCursor.defer,
                      ),
                      Text(
                        '予定に返信する',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ]),
              onPressed: () => _showDialog(plansModel),
              color: Color(0xfff0f0f0),
              textColor: Colors.black54,
            ),
    );
  }
}

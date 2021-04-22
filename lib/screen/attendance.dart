import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kinkanutilapp/logic/cache.dart';
import 'package:kinkanutilapp/logic/ms_graph.dart';
import 'package:kinkanutilapp/model/plans.dart';
import 'package:kinkanutilapp/repository/user_repository.dart';
import 'package:provider/provider.dart';

import 'dialog_utils.dart';

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
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // isSmall ? Container() : _ChannelMessageUrlField(),
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

Future<bool> _replyMessage(
    {BuildContext context,
    String currentWeekMessageId,
    String replyText}) async {
  bool result = true;

  replyText = replyText.replaceAll('\n', '<br>');

  if (await MsGraph().replyChannelMessage(currentWeekMessageId, replyText)) {
    String channelMessageInfo = await Cache.getChannelMessageInfo();
    try {
      Map channelMessageInfoMap = {};

      if (channelMessageInfo.isNotEmpty) {
        channelMessageInfoMap = json.decode(channelMessageInfo);
      }

      List infoList = channelMessageInfoMap["channelMessageInfo"] ?? [];

      bool existsId = false;

      for (int i = 0; i < infoList.length; i++) {
        if (infoList[i]["id"] == currentWeekMessageId) {
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
            "id": currentWeekMessageId,
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
      final snackBar = SnackBar(
        content: Text('Teamsに投稿しました。'),
        action: SnackBarAction(
          label: '閉じる',
          textColor: Colors.yellow,
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();
          },
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    } catch (e) {
      debugPrint('channel message info save error.');
      debugPrint('channel message info=$channelMessageInfo');
      throw e;
    }
  } else {
    await DialogUtils.showErrorDialog(
        context: context,
        errorMessage: 'Teamsへの投稿に失敗しました。\n設定・ネットワーク接続状況をご確認ください。');
    result = false;
  }

  return result;
}

class _WorkStartedButton extends StatefulWidget {
  final bool isSmall;

  _WorkStartedButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _WorkStartedButtonState();
}

class _WorkStartedButtonState extends State<_WorkStartedButton> {
  bool _isPosting = false;

  Future _showDialog() async {
    String currentWeekMessageId = "";
    await Cache.getChannelMessageInfo().then((value) {
      try {
        Map channelMessageInfoMap = {};

        if (value.isNotEmpty) {
          channelMessageInfoMap = json.decode(value);
        }

        List infoList = channelMessageInfoMap["channelMessageInfo"] ?? [];

        var now = DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < infoList.length; i++) {
          if (infoList[i]["startDate"] <= now &&
              now <= infoList[i]["endDate"]) {
            currentWeekMessageId = infoList[i]["id"];
            break;
          }
        }
      } catch (e) {
        debugPrint('channel message info save error.');
        debugPrint('channel message info=$value');
        debugPrint(e.toString());

        throw e;
      }
    });

    if (currentWeekMessageId.isEmpty) {
      await DialogUtils.showErrorDialog(
          context: context, errorMessage: "今週の投稿IDがありません。");
      return;
    }

    setState(() {
      _isPosting = true;
    });

    String inputted = await DialogUtils.showInputDialog(
      context: context,
      title: "業務を開始する",
      body: "以下のメッセージを送信します。よろしいですか？",
      input: "業務を開始します。",
    );

    if (inputted != null && inputted.isNotEmpty) {
      if (await _replyMessage(
          context: context,
          currentWeekMessageId: currentWeekMessageId,
          replyText: inputted)) {
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
              onPressed: () => _showDialog(),
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
    String currentWeekMessageId = "";
    await Cache.getChannelMessageInfo().then((value) {
      try {
        Map channelMessageInfoMap = {};

        if (value.isNotEmpty) {
          channelMessageInfoMap = json.decode(value);
        }

        List infoList = channelMessageInfoMap["channelMessageInfo"] ?? [];

        var now = DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < infoList.length; i++) {
          if (infoList[i]["startDate"] <= now &&
              now <= infoList[i]["endDate"]) {
            currentWeekMessageId = infoList[i]["id"];
            break;
          }
        }
      } catch (e) {
        debugPrint('channel message info save error.');
        debugPrint('channel message info=$value');
        debugPrint(e.toString());

        throw e;
      }
    });

    if (currentWeekMessageId.isEmpty) {
      await DialogUtils.showErrorDialog(
          context: context, errorMessage: "今週の投稿IDがありません。");
      return;
    }

    setState(() {
      _isPosting = true;
    });

    String inputted = await DialogUtils.showInputDialog(
      context: context,
      title: "業務を終了する",
      body: "以下のメッセージを送信します。よろしいですか？",
      input: "業務を終了します。",
    );

    if (inputted != null && inputted.isNotEmpty) {
      if (await _replyMessage(
          context: context,
          currentWeekMessageId: currentWeekMessageId,
          replyText: inputted)) {
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

  Future _showDialog() async {
    String currentWeekMessageId = "";
    await Cache.getChannelMessageInfo().then((value) {
      try {
        Map channelMessageInfoMap = {};

        if (value.isNotEmpty) {
          channelMessageInfoMap = json.decode(value);
        }

        List infoList = channelMessageInfoMap["channelMessageInfo"] ?? [];

        var now = DateTime.now().millisecondsSinceEpoch;
        for (int i = 0; i < infoList.length; i++) {
          if (infoList[i]["startDate"] <= now &&
              now <= infoList[i]["endDate"]) {
            currentWeekMessageId = infoList[i]["id"];
            break;
          }
        }
      } catch (e) {
        debugPrint('channel message info save error.');
        debugPrint('channel message info=$value');
        debugPrint(e.toString());

        throw e;
      }
    });

    if (currentWeekMessageId.isEmpty) {
      await DialogUtils.showErrorDialog(
          context: context, errorMessage: "今週の投稿IDがありません。");
      return;
    }

    setState(() {
      _isPosting = true;
    });

    String inputted = await DialogUtils.showInputDialog(
      context: context,
      title: "予定に返信する",
      body: "以下のメッセージを送信します。よろしいですか？",
      inputHint: "今週の予定に返信する内容を入力してください。",
    );

    if (inputted != null && inputted.isNotEmpty) {
      await _replyMessage(
          context: context,
          currentWeekMessageId: currentWeekMessageId,
          replyText: inputted);
    }

    setState(() {
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _showDialog(),
              color: Color(0xfff0f0f0),
              textColor: Colors.black54,
            ),
    );
  }
}

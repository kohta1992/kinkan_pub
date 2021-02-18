import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:kinkanutilapp/logic/cache.dart';

Future<String> showSettingDialog({
  @required BuildContext context,
  TransitionBuilder builder,
  bool useRootNavigator = true,
  String title,
  String body,
  String input,
  String inputHint,
}) {
  final Widget dialog = _SettingDialog(
    title: title ?? "",
    body: body ?? "",
    input: input ?? "",
    inputHint: inputHint ?? "",
  );
  return showDialog(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

class _SettingDialog extends StatefulWidget {
  final String title;
  final String body;
  final String input;
  final String inputHint;

  _SettingDialog({this.title, this.body, this.input, this.inputHint});

  @override
  State createState() => _SettingDialogState();
}

class _SettingDialogState extends State<_SettingDialog> {
  TextEditingController _planDestinationController;
  TextEditingController _startEndDestinationController;
  ScrollController _scrollController = ScrollController();

  var groupId = "";
  var channelId = "";
  var currentWeekMessageId = "";
  var errorMessage = "";

  @override
  Future<void> initState() {
    Cache.getGroupId().then((value) {
      setState(() {
        groupId = value;
      });
    });
    Cache.getChannelId().then((value) {
      setState(() {
        channelId = value;
      });
    });

    Cache.getChannelMessageInfo().then((value) {
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

    _planDestinationController = TextEditingController(text: "");
    _startEndDestinationController =
        TextEditingController(text: currentWeekMessageId);
    super.initState();
  }

  void loadIds() {
    String url = _planDestinationController.text.trim();

    if (url.isEmpty) {
      return;
    }

    List<String> list = url
        .replaceFirst("https://teams.microsoft.com/l/channel/", "")
        .split("/");

    setState(() {
      channelId = list[0];
    });
    debugPrint(channelId);

    List<String> paramList = list[1].split("?")[1].split("&");
    for (String param in paramList) {
      if (param.startsWith("groupId")) {
        setState(() {
          groupId = param.replaceFirst("groupId=", "");
        });
        debugPrint(groupId);
        break;
      }
    }
  }

  Future<void> loadChannelMessageId() async {
    String url = _startEndDestinationController.text.trim();

    if (url.isEmpty) {
      return;
    }

    List<String> list = url
        .replaceFirst("https://teams.microsoft.com/l/message/", "")
        .split("/");

    setState(() {
      currentWeekMessageId = list[1].split("?")[0];
    });
    debugPrint(currentWeekMessageId);
  }

  @override
  Widget build(BuildContext context) {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final Dialog dialog = Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(100),
        child: Stack(
          overflow: Overflow.visible,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 800,
              // height: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("設定",
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.left),
                  Divider(
                    color: Colors.black26,
                    thickness: 1,
                  ),
                  Expanded(
                    child: Scrollbar(
                      isAlwaysShown: true,
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "勤務予定投稿",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.black26,
                                        thickness: 1,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 100,
                                            child: Text("グループID"),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(groupId),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: Text("チャネルID"),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(channelId),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: TextFormField(
                                                controller:
                                                    _planDestinationController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "https://teams.microsoft.com/l/channel/{channel_id}/{channel_name}?groupId={group_id}&tenantId={tenant_id}",
                                                ),
                                                maxLines: 1,
                                                keyboardType: TextInputType.url,
                                              ),
                                            ),
                                          ),
                                          RaisedButton(
                                              child: Text("読み込む"),
                                              color: Colors.blue,
                                              textColor: Colors.white,
                                              onPressed: loadIds)
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Text(
                                              "勤務予定投稿先チャネルのリンクから投稿先グループID/チャネルIDを読み込む。",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "勤務開始/終了連絡",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.black26,
                                        thickness: 1,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: Text("今週の投稿ID"),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(currentWeekMessageId),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Text(
                                              "勤務予定投稿時に自動で設定されます。",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: TextFormField(
                                                controller:
                                                    _startEndDestinationController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "https://teams.microsoft.com/l/message/{channel_id}/{message_id}?tenantId={tenant_id}&groupId={group_id}&parentMessageId={parent_message_id}&teamName={team_name}&channelName={channel_name}&createdTime={created_time}",
                                                ),
                                                maxLines: 1,
                                                keyboardType: TextInputType.url,
                                              ),
                                            ),
                                          ),
                                          RaisedButton(
                                              child: Text("読み込む"),
                                              color: Colors.blue,
                                              textColor: Colors.white,
                                              onPressed: loadChannelMessageId)
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Text(
                                              "勤務開始/終了投稿先メッセージのリンクから投稿先メッセージIDを手動で読み込む。",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Text(
                        "$errorMessage",
                        style: TextStyle(color: Colors.redAccent),
                      )),
                      FlatButton(
                        textColor: Colors.blue,
                        child: Text("キャンセル"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: FlatButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text("保存"),
                          onPressed: () async {
                            if (groupId.isEmpty) {
                              setState(() {
                                errorMessage = "グループIDがありません。";
                              });
                              return;
                            }

                            if (channelId.isEmpty) {
                              setState(() {
                                errorMessage = "チャネルIDがありません。";
                              });
                              return;
                            }

                            await Cache.setChannelId(channelId);
                            await Cache.setGroupId(groupId);

                            String channelMessageInfo =
                                await Cache.getChannelMessageInfo();

                            try {
                              Map channelMessageInfoMap = {};

                              if (channelMessageInfo.isNotEmpty) {
                                channelMessageInfoMap =
                                    json.decode(channelMessageInfo);
                              }

                              List infoList =
                                  channelMessageInfoMap["channelMessageInfo"] ??
                                      [];

                              bool existsId = false;

                              for (int i = 0; i < infoList.length; i++) {
                                if (infoList[i]["id"] == currentWeekMessageId) {
                                  existsId = true;
                                  break;
                                }
                              }

                              if (!existsId) {
                                int diff =
                                    DateTime.monday - DateTime.now().weekday;
                                if (diff > 1) {
                                  diff -= 8;
                                }

                                var monday = DateTime.now()
                                    .add(new Duration(days: diff));
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
                                    "startDate":
                                        startDate.millisecondsSinceEpoch,
                                    "endDate": endDate.millisecondsSinceEpoch,
                                    "id": currentWeekMessageId,
                                  }
                                ];

                                if (channelMessageInfoMap.isNotEmpty) {
                                  List oldList = channelMessageInfoMap[
                                      "channelMessageInfo"];
                                  oldList.forEach((element) {
                                    if (startDate.millisecondsSinceEpoch !=
                                        element["startDate"]) {
                                      newInfoList.add(element);
                                    }
                                  });
                                }
                                channelMessageInfoMap = {
                                  "channelMessageInfo": newInfoList
                                };
                                print(newInfoList);
                                await Cache.setChannelMessageInfo(
                                    jsonEncode(channelMessageInfoMap));
                              }
                            } catch (e) {
                              debugPrint('channel message info save error.');
                              debugPrint(
                                  'channel message info=$channelMessageInfo');
                              throw e;
                            }
                            Navigator.pop<String>(
                                context, _planDestinationController.text ?? "");
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));

    return dialog;
  }

  @override
  void dispose() {
    _planDestinationController.dispose();
    super.dispose();
  }
}

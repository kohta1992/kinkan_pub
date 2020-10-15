import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kinkanutilapp/group_const.dart';
import 'package:kinkanutilapp/logic/ms_graph.dart';
import 'package:kinkanutilapp/model/plans.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OutputPlans extends StatelessWidget {
  final bool isSmall;

  OutputPlans({@required this.isSmall});

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
              _OutlookButton(
                isSmall: isSmall,
              ),
              _MailerOpenButton(
                isSmall: isSmall,
              ),
              _CopyResultButton(
                isSmall: isSmall,
              ),
              _TeamsOpenButton(
                isSmall: isSmall,
              ),
            ],
          ),
        ),
        isSmall ? Container() : _PlansPreview(),
      ],
    );
  }
}

class _OutlookButton extends StatefulWidget {
  final bool isSmall;

  _OutlookButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _OutlookButtonState();
}

class _OutlookButtonState extends State<_OutlookButton> {
  bool _isPosting = false;

  Future<void> _registerPlans(PlansModel plansModel) async {
    setState(() {
      _isPosting = true;
    });
    await MsGraph().registerEvent(plansModel);
    setState(() {
      _isPosting = false;
    });
    final snackBar = SnackBar(
      content: Text('Outlookの予定表に登録しました。'),
      action: SnackBarAction(
        label: '閉じる',
        textColor: Colors.yellow,
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
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
          : widget.isSmall
              ? Tooltip(
                  message: '予定表に登録する',
                  child: FlatButton(
                    child: const InkWell(
                      child: Icon(
                        Icons.event_note,
                        color: Colors.black54,
                        size: 20,
                      ),
                      mouseCursor: MouseCursor.defer,
                    ),
                    onPressed: () => _registerPlans(plansModel),
                  ),
                )
              : FlatButton(
                  child: Row(
                    children: [
                      const InkWell(
                        child: Icon(
                          Icons.event_note,
                          color: Colors.black54,
                          size: 20,
                        ),
                        mouseCursor: MouseCursor.defer,
                      ),
                      Text(
                        '予定表に登録する',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  onPressed: () => _registerPlans(plansModel),
                  color: Color(0xfff0f0f0),
                  textColor: Colors.black54,
                ),
    );
  }
}

class _PlansPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  '生成テキストプレビュー',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Divider(
                color: Colors.black26,
                height: 1,
              ),
            ),
            Text(
              plansModel.getPlansText(),
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _MailerOpenButton extends StatefulWidget {
  final bool isSmall;

  _MailerOpenButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _MailerOpenButtonState();
}

class _MailerOpenButtonState extends State<_MailerOpenButton> {
  Future<void> _openMailer(PlansModel plansModel) async {
    String subject = Uri.encodeComponent(plansModel.getPlansSubject());
    String body = Uri.encodeComponent(plansModel.getPlansBody());
    String url =
        "mailto:${GroupConst.teamsAddress}?subject=$subject&body=$body";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);

    return SizedBox(
      width: widget.isSmall ? 40 : double.infinity,
      height: 40,
      child: widget.isSmall
          ? Tooltip(
              message:
                  'メールで送信する\n<件名>\n${plansModel.getPlansSubject()}\n<本文>\n${plansModel.getPlansBody()}\n',
              child: FlatButton(
                child: const InkWell(
                  child: Icon(
                    Icons.mail,
                    color: Colors.black54,
                    size: 20,
                  ),
                  mouseCursor: MouseCursor.defer,
                ),
                onPressed: () => _openMailer(plansModel),
              ),
            )
          : FlatButton(
              child: Row(
                children: [
                  const InkWell(
                    child: Icon(
                      Icons.mail,
                      color: Colors.black54,
                      size: 20,
                    ),
                    mouseCursor: MouseCursor.defer,
                  ),
                  Text(
                    'メールで送信する',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              onPressed: () => _openMailer(plansModel),
              color: Color(0xfff0f0f0),
              textColor: Colors.black54,
            ),
    );
  }
}

class _CopyResultButton extends StatefulWidget {
  final bool isSmall;

  _CopyResultButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _CopyResultButtonState();
}

class _CopyResultButtonState extends State<_CopyResultButton> {
  Future<void> _copyToClipboard(String text) async {
    final data = ClipboardData(text: text);
    await Clipboard.setData(data);
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
                message:
                    'クリップボードにコピーする\n<プレビュー>\n${plansModel.getPlansText()}\n',
                child: const InkWell(
                  child: Icon(
                    Icons.copy,
                    color: Colors.black54,
                    size: 20,
                  ),
                  mouseCursor: MouseCursor.defer,
                ),
              )
            : Row(children: [
                const InkWell(
                  child: Icon(
                    Icons.copy,
                    color: Colors.black54,
                    size: 20,
                  ),
                  mouseCursor: MouseCursor.defer,
                ),
                Text(
                  'クリップボードにコピーする',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ]),
        onPressed: () async {
          await _copyToClipboard(plansModel.getPlansText());
          final snackBar = SnackBar(
            content: Text('クリップボードにコピーしました！'),
            action: SnackBarAction(
              label: '閉じる',
              textColor: Colors.yellow,
              onPressed: () {
                Scaffold.of(context).hideCurrentSnackBar();
              },
            ),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        },
        color: Color(0xfff0f0f0),
        textColor: Colors.black54,
      ),
    );
  }
}

class _TeamsOpenButton extends StatefulWidget {
  final bool isSmall;

  _TeamsOpenButton({@required this.isSmall});

  @override
  State<StatefulWidget> createState() => _TeamsOpenButtonState();
}

class _TeamsOpenButtonState extends State<_TeamsOpenButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isSmall ? 40 : double.infinity,
      height: 40,
      child: FlatButton(
        child: widget.isSmall
            ? Tooltip(
                message: 'Teamsを開く',
                child: const InkWell(
                  child: Icon(
                    Icons.open_in_new,
                    color: Colors.black54,
                    size: 20,
                  ),
                  mouseCursor: MouseCursor.defer,
                ),
              )
            : Row(
                children: [
                  const InkWell(
                    child: Icon(
                      Icons.open_in_new,
                      color: Colors.black54,
                      size: 20,
                    ),
                    mouseCursor: MouseCursor.defer,
                  ),
                  Text(
                    'Teamsを開く',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
        onPressed: () async {
          launch(GroupConst.teamsUrl);
        },
        color: Color(0xfff0f0f0),
        textColor: Colors.black54,
      ),
    );
  }
}

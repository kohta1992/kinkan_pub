import 'package:flutter/material.dart';
import 'package:kinkanutilapp/model/plans.dart';
import 'package:provider/provider.dart';

class PostEventConfirmDialog extends StatefulWidget {
  @override
  State createState() => _PostEventConfirmDialogState();
}

class _PostEventConfirmDialogState extends State<PostEventConfirmDialog> {
  TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final List<Widget> actions = [
      FlatButton(
        child: Text(localizations.cancelButtonLabel),
        onPressed: () => Navigator.pop<bool>(context, false),
      ),
      FlatButton(
        child: Text(localizations.okButtonLabel),
        onPressed: () => Navigator.pop<bool>(context, true),
      ),
    ];
    final AlertDialog dialog = AlertDialog(
      title: Text("Outlook登録確認"),
      content: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("以下の内容でOutlookに登録します。よろしいですか？"),
              ],
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  for (int index = 0; index < 5; index++)
                    _EventItem(
                      index: index,
                    )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: actions,
    );

    return dialog;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _EventItem extends StatelessWidget {
  final int index;

  _EventItem({
    Key key,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var plansModel = Provider.of<PlansModel>(context);
    var plan = plansModel.plans[index];
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('${plan.getDate()}'),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: Colors.blue)),
            margin: EdgeInsets.only(left: 5),
            child: Tooltip(
              message: '${plan.getSubjectForOutlook(plansModel.isTimeUnneeded)}',
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 300,
                    color: Colors.blue,
                    margin: EdgeInsets.only(left: 10),
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '${plan.getSubjectForOutlook(plansModel.isTimeUnneeded)}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

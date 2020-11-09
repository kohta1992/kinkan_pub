import 'package:flutter/material.dart';

Future<String> showPostTeamsDialog({
  @required BuildContext context,
  TransitionBuilder builder,
  bool useRootNavigator = true,
}) {
  final Widget dialog = _PostTeamsDialog();
  return showDialog(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

class _PostTeamsDialog extends StatefulWidget {
  @override
  State createState() => _PostTeamsDialogState();
}

class _PostTeamsDialogState extends State<_PostTeamsDialog> {
  final nameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final List<Widget> actions = [
      FlatButton(
        child: Text(localizations.cancelButtonLabel),
        onPressed: () => Navigator.pop(context),
      ),
      FlatButton(
        child: Text(localizations.okButtonLabel),
        onPressed: () {
          Navigator.pop<String>(context, nameTextController.text ?? "");
        },
      ),
    ];
    final AlertDialog dialog = AlertDialog(
      title: Text("Teamsに投稿する"),
      content: TextField(
        controller: nameTextController,
        decoration: InputDecoration(
          hintText: "件名の名前を入力してください",
        ),
        autofocus: true,
        keyboardType: TextInputType.name,
      ),
      actions: actions,
    );

    return dialog;
  }

  @override
  void dispose() {
    nameTextController.dispose();
    super.dispose();
  }
}

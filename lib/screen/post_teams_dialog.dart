import 'package:flutter/material.dart';

class PostTeamsDialog extends StatefulWidget {
  @override
  State createState() => _PostTeamsDialogState();
}

class _PostTeamsDialogState extends State<PostTeamsDialog> {
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

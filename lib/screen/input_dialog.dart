import 'package:flutter/material.dart';

class InputDialog extends StatefulWidget {
  final String title;
  final String body;
  final String input;
  final String inputHint;

  InputDialog({this.title, this.body, this.input, this.inputHint});

  @override
  State createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.input ?? "");
    super.initState();
  }

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
          Navigator.pop<String>(context, _controller.text ?? "");
        },
      ),
    ];
    final AlertDialog dialog = AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.body),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.inputHint,
            ),
            maxLines: null,
            autofocus: true,
            keyboardType: TextInputType.multiline,
          ),
        ],
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

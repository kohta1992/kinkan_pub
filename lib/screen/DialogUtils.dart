import 'package:flutter/material.dart';
import 'package:kinkanutilapp/screen/post_teams_dialog.dart';
import 'package:kinkanutilapp/screen/setting_dialog.dart';

import 'input_dialog.dart';

class DialogUtils {

  static Future<void> showErrorDialog(
      {BuildContext context, String errorMessage}) async {
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

  static Future<String> showInputDialog({
    @required BuildContext context,
    TransitionBuilder builder,
    bool useRootNavigator = true,
    String title,
    String body,
    String input,
    String inputHint,
  }) {
    final Widget dialog = InputDialog(
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

  static Future<String> showPostTeamsDialog({
    @required BuildContext context,
    TransitionBuilder builder,
    bool useRootNavigator = true,
  }) {
    final Widget dialog = PostTeamsDialog();
    return showDialog(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return builder == null ? dialog : builder(context, dialog);
      },
    );
  }

  static Future<String> showSettingDialog({
    @required BuildContext context,
    TransitionBuilder builder,
    bool useRootNavigator = true,
    String title,
    String body,
    String input,
    String inputHint,
  }) {
    final Widget dialog = SettingDialog(
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
}

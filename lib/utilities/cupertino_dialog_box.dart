import 'dart:async';
import 'package:flutter/cupertino.dart';

Future<bool> showCupertinoDialog(BuildContext context, String title, String content, String? lBtnLabel, String? rBtnLabel) async {
  Completer<bool> completer = Completer<bool>();

  showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: false, // prevents closing the ui by clicking outside of it
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates this action is the default,
          /// and turns the action's text to bold text.
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            completer.complete(true); // User chose the left option
          },
          child: lBtnLabel != null ? Text(lBtnLabel) : const Text("Yes"),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            completer.complete(false); // User chose the right option
          },
          child: rBtnLabel != null ? Text(rBtnLabel) : const Text("No"),
        ),
      ],
    ),
  );

  return completer.future;
}

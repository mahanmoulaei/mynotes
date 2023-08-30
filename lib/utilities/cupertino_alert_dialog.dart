import 'package:flutter/cupertino.dart';

Future<void> showAlertDialog(BuildContext context, String? title, String? content, String? btnLabel) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: title != null ? Text(title) : const Text("Alert"),
      content: content != null ? Text(content) : const Text(""),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates this action is the default,
          /// and turns the action's text to bold text.
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: btnLabel != null ? Text(btnLabel) : const Text("Ok"),
        )
      ],
    ),
  );
}

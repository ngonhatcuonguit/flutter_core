import 'package:flutter/material.dart';

void showDialogError(BuildContext context, String message) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Lỗi!!!"),
          content: Text(message),
          actions: <Widget>[
            MaterialButton(
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

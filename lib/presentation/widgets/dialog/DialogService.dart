import 'package:flutter/material.dart';

class DialogService {
  final BuildContext context;

  DialogService({required this.context});

  // Show a simple failure dialog
  void showDialogFailure({
    required String content,
    required BuildContext context,
    required String textConfirm,
    required VoidCallback confirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lỗi'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                confirm();
                Navigator.of(context).pop();
              },
              child: Text(textConfirm),
            ),
          ],
        );
      },
    );
  }

  // Optional: You can add more methods to show different kinds of dialogs (success, warning, etc.)
  void showDialogSuccess({
    required String content,
    required String textConfirm,
    required VoidCallback confirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thành công'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                confirm();
                Navigator.of(context).pop();
              },
              child: Text(textConfirm),
            ),
          ],
        );
      },
    );
  }
}

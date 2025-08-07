// lib/widgets/confirmation_dialog.dart
import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog({required BuildContext context, required String title, required String content, String confirmText = 'Confirm', Color confirmColor = Colors.red}) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText, style: TextStyle(color: confirmColor)),
        ),
      ],
    ),
  );
}

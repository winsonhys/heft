import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Shows a confirmation dialog and returns true if confirmed, false otherwise.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  bool isDestructive = false,
}) async {
  final result = await showFDialog<bool>(
    context: context,
    builder: (context, style, animation) => FDialog(
      style: style, // ignore: implicit_call_tearoffs
      animation: animation,
      direction: Axis.horizontal,
      title: Text(title),
      body: Text(message),
      actions: [
        FButton(
          style: FButtonStyle.ghost(),
          onPress: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FButton(
          style: isDestructive ? FButtonStyle.destructive() : FButtonStyle.primary(),
          onPress: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

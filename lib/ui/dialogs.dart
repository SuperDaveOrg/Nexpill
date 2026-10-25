import 'package:flutter/material.dart';

import 'package:nexpill/services/document_service.dart';
import 'package:nexpill/ui/language.dart';

/// Asks before doing something: [title] and [message], with [cancel] and
/// [action] to choose between. True only if [action] was chosen.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
  String? cancel,
}) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel ?? context.l.cancel)),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action)),
      ],
    ),
  );
  return answer ?? false;
}

/// Offers [text] to be saved as [name] through Android's Save picker, and
/// says [done] once it is, or that it couldn't be. Says nothing if the
/// caregiver backs out.
Future<void> saveToFile(
  BuildContext context, {
  required String name,
  required String text,
  required String mimeType,
  required String done,
}) async {
  String? message;
  try {
    if (await DocumentService().save(name, text, mimeType: mimeType)) {
      message = done;
    }
  } catch (_) {
    if (context.mounted) message = context.l.couldNotSave;
  }
  if (message == null || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

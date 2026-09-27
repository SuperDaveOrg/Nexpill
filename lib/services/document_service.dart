import 'dart:convert';

import 'package:flutter/services.dart';

/// Android's own Save and Open pickers, via MainActivity.
///
/// The user picks the location every time. Nexpill never writes a file on
/// its own and never learns where the file went beyond the one document
/// chosen.
class DocumentService {
  static const _channel = MethodChannel('nexpill/documents');

  /// Offers to save [text] as [suggestedName]. False if the user backed out.
  Future<bool> save(
    String suggestedName,
    String text, {
    String mimeType = 'application/json',
  }) async {
    final saved = await _channel.invokeMethod<bool>('save', {
      'name': suggestedName,
      'bytes': Uint8List.fromList(utf8.encode(text)),
      'mimeType': mimeType,
    });
    return saved ?? false;
  }

  /// The chosen file's text, or null if the user backed out.
  Future<String?> open() async {
    final bytes = await _channel.invokeMethod<Uint8List>('open');
    return bytes == null ? null : utf8.decode(bytes, allowMalformed: true);
  }
}

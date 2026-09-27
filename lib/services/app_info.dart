import 'package:flutter/services.dart';

/// The installed version as "0.1.0 (100)", read from Android via
/// MainActivity. Null where there's no Android side (tests, desktop).
Future<String?> installedVersion() async {
  try {
    final info = await const MethodChannel('nexpill/app')
        .invokeMapMethod<String, Object?>('version');
    if (info == null) return null;
    return '${info['name']} (${info['code']})';
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

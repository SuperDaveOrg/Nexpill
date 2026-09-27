// Writes a backup file of fictional sample data, for restoring onto a test
// phone or emulator.
//
// Usage: dart run tool/sample_history.dart out.json

import 'dart:io';

import 'package:nexpill/data/backup.dart';
import 'package:nexpill/data/sample_data.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: dart run tool/sample_history.dart <out.json>');
    exit(64);
  }
  final now = DateTime.now();
  File(args.single).writeAsStringSync(
      encodeBackup(sampleCare(now), exportedAt: now));
  stdout.writeln('Wrote ${args.single}: fictional sample data relative to now.');
}

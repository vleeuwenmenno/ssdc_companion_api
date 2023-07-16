import 'dart:io';

import 'package:ssdc_companion_ui/utils/debug.dart';

Future<int> parsePortFromBatFile(String filePath) async {
  final RegExp portRegexp = RegExp(r'--port\s+(\d+)');
  const int defaultPort = 7860;

  try {
    final file = File(filePath);
    final lines = await file.readAsLines();

    for (final line in lines) {
      final match = portRegexp.firstMatch(line);
      if (match != null && match.groupCount >= 1) {
        return int.parse(match.group(1)!);
      }
    }
  } catch (e) {
    log('Failed to open or read file: $e');
  }

  return defaultPort;
}

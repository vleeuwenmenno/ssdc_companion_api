import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

class Settings {
  String? path;
  bool autoStart;
  bool forceGitDownload;
  bool useSystemPython;

  Settings({
    this.path,
    this.autoStart = false,
    this.useSystemPython = true,
    this.forceGitDownload = false,
  });

  bool get a1111Ok => path != null && path!.isNotEmpty && Directory(dirname(path ?? '')).existsSync();

  // Convert a Settings object into a Map
  Map<String, dynamic> toJson() => {
        'path': path,
        'autoStart': autoStart,
        'forceGitDownload': forceGitDownload,
        'useSystemPython': useSystemPython,
      };

  // Convert a Map into a Settings object
  static Settings fromJson(Map<String, dynamic> json) => Settings(
        path: json['path'],
        autoStart: json['autoStart'] ?? false,
        forceGitDownload: json['forceGitDownload'] ?? false,
        useSystemPython: json['useSystemPython'] ?? false,
      );

  // Load Settings from a file
  static Future<Settings> load() async {
    final file = File('settings.json');

    if (await file.exists()) {
      final json = jsonDecode(await file.readAsString());
      return fromJson(json);
    } else {
      Settings s = Settings(path: '', autoStart: false);
      s.save();
      return s;
    }
  }

  // Save Settings to a file
  Future<void> save() async {
    final file = File('settings.json');
    await file.writeAsString(jsonEncode(toJson()));
  }
}

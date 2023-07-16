// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:ssdc_companion_ui/utils/debug.dart';

const String NO_GIT = "NO_GIT";
const String NO_PYTHON = "NO_PYTHON";
const String INCOMPAT_PYTHON = "INCOMPAT_PYTHON";

Future<String> checkPythonVersion([String cwd = '.']) async {
  List<String> commands = ['python3.10', 'python3', 'python'];
  for (var command in commands) {
    try {
      final result = await Process.run(command, ['--version'], workingDirectory: cwd);
      if (result.exitCode == 0) {
        var version = result.stdout.toString().split(' ')[1].trim();
        if (version.startsWith('3.10.')) {
          log('Python v$version');
          return command;
        } else if (version.startsWith('3.')) {
          return INCOMPAT_PYTHON;
        }
      }
    } catch (e) {/* Ignore */}
  }
  return NO_PYTHON;
}

Future<String> checkGit([String cwd = '.']) async {
  List<String> commands = ['git'];
  for (var command in commands) {
    try {
      final result = await Process.run(command, ['--version'], workingDirectory: cwd);
      if (result.exitCode == 0) {
        var version = result.stdout.toString().split(' ')[2].trim();
        log('Git v$version');
        return command;
      }
    } catch (e) {/* Ignore */}
  }
  return NO_GIT;
}

Future<bool> isCompatiblePython([String cwd = '.']) async {
  final python = await checkPythonVersion(cwd);
  return ['python3.10', 'python3', 'python'].any((element) => element == python);
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

final sessionId = const Uuid().v4();
final date = DateTime.now();
final dateString = '${date.day}-${date.month}-${date.year}';
final applicationLogs = <AppLog>[];

bool firstLog = true;

List<String> get applicationLogsLines {
  applicationLogs.sort((a, b) {
    return b.time.compareTo(a.time);
  });

  return applicationLogs
      .map(
        (log) =>
            '[${log.time.toIso8601String()}]: [${log.event}] [${log.job}]: ${log.message} ${log.repeatCount > 1 ? '(${log.repeatCount})' : ''}',
      )
      .toList();
}

class AppLog {
  AppLog({
    required this.message,
    required this.event,
    required this.job,
    required this.time,
    this.repeatCount = 1,
  });

  final DateTime time;
  String job;
  String message;
  String event;
  int repeatCount;
}

void logObject(
  Object object, [
  String job = 'NEW-JOB',
  String event = 'IMAGE-JOB',
  DateTime? time,
]) {
  _print(const JsonEncoder.withIndent('    ').convert(object));
}

void log(
  String message, [
  String job = 'CONSOLE',
  String event = 'MSG',
  DateTime? time,
]) {
  _print(message, job, event, time);
}

Future<void> _print(
  String message, [
  String job = 'CONSOLE',
  String event = 'MSG',
  DateTime? time,
]) async {
  final appLog = AppLog(
    message: message,
    time: time ??= DateTime.now(),
    job: job,
    event: event,
  );

  if (applicationLogs.isNotEmpty && applicationLogs.last.message == message) {
    appLog.repeatCount = applicationLogs.last.repeatCount + 1;
    applicationLogs.last.repeatCount = appLog.repeatCount;
  }

  if (applicationLogs.isEmpty || applicationLogs.last.message != message) {
    applicationLogs.add(appLog);
  }

  if (applicationLogs.last.repeatCount > 1) {
    debugPrint(
      '[${time.toIso8601String()}]: [${appLog.event}] [${appLog.job}]: ${appLog.message} (${appLog.repeatCount})',
    );
  } else {
    debugPrint(
      '[${time.toIso8601String()}]: [${appLog.event}] [${appLog.job}]: ${appLog.message}',
    );
  }

  final logsDir = Directory(p.join('.', 'logs'));
  if (!logsDir.existsSync()) {
    await logsDir.create();
  }

  final logFile = File(p.join(logsDir.path, '$sessionId-$dateString.json'));

  if (!logFile.existsSync()) {
    await logFile.create();
  }
  if (firstLog) {
    firstLog = false;
    log('Log file is ${logsDir.path}/$logFile', 'INITIALIZED', 'LOGGER');
  }

  final logEntry = {
    'time': time.toIso8601String(),
    'job': job,
    'event': event,
    'message': message,
    'repeatCount': appLog.repeatCount,
  };

  await logFile.writeAsString(
    '${const JsonEncoder.withIndent('    ').convert(logEntry)},\n',
    mode: FileMode.append,
  );
}

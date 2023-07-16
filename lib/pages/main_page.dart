import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path/path.dart';
import 'package:ssdc_companion_ui/settings.dart';
import 'package:ssdc_companion_ui/utils/bat_parser.dart';
import 'package:ssdc_companion_ui/utils/debug.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  Process? process;
  List<String> lines = [];
  ScrollController scrollController = ScrollController();
  bool isUpdating = false;
  bool showConsole = false;
  String? externalIp;
  Timer? _timer;
  bool _serverStatus = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final settings = await Settings.load();
        final localIps = await getLocalIPs();
        final port = await parsePortFromBatFile(settings.path ?? '');
        var response = await http.get(Uri.parse('http://${localIps.first}:$port')).timeout(const Duration(seconds: 3));
        final status = response.statusCode >= 200 && response.statusCode < 300;
        if (status != _serverStatus) {
          setState(() {
            _serverStatus = status;
          });
        }
      } catch (e) {
        setState(() {
          _serverStatus = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FlutterI18n.translate(context, "title"))),
      body: FutureBuilder(
          future: Settings.load(),
          builder: (context, settingsSnapshot) {
            final settings = settingsSnapshot.data;

            if (settings == null) {
              return const CircularProgressIndicator();
            }

            if (settings.autoStart && settings.path != null) {
              startSdProcess(settings);
            }

            return FutureBuilder(
              future: parsePortFromBatFile(settings.path ?? ''),
              builder: (context, snapshot) {
                final port = snapshot.data ?? 7860;

                return Builder(
                  builder: (BuildContext context) => StreamBuilder<bool>(
                    initialData: true,
                    stream: FlutterI18n.retrieveLoadedStream(context),
                    builder: (BuildContext context, _) => Center(
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    _serverStatus
                                        ? Icons.check_circle
                                        : _started
                                            ? Icons.refresh_outlined
                                            : Icons.error,
                                    color: _serverStatus
                                        ? Colors.green
                                        : _started
                                            ? Colors.blueGrey
                                            : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  I18nText(
                                    _serverStatus
                                        ? FlutterI18n.translate(context, "server_is_running")
                                        : _started
                                            ? FlutterI18n.translate(context, "server_is_booting")
                                            : FlutterI18n.translate(context, "server_is_not_running"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (showConsole) console(),
                          Container(
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                externalIps(port),
                                const SizedBox(height: 16),
                                internalIps(port),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                if (process != null)
                                  MaterialButton(
                                    onPressed: () async {
                                      await abortSdProcess();
                                      setState(() {});
                                    },
                                    child: I18nText('kill_process'),
                                  ),
                                if (process == null)
                                  MaterialButton(
                                    onPressed: () async {
                                      await startSdProcess(settings);
                                      setState(() {});
                                    },
                                    child: I18nText('start_a1111'),
                                  ),
                                const Spacer(),
                                MaterialButton(
                                  onPressed: () {},
                                  child: I18nText('add_resource'),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    showConsole = !showConsole;
                                    setState(() {});
                                  },
                                  child: !showConsole ? I18nText('show_console') : I18nText('hide_console'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  Widget externalIps(int port) {
    return FutureBuilder(
      future: getExternalIP(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return Column(
            children: [
              I18nText(
                'external_ip',
                child: const Text(
                  '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  await launchInBrowser(Uri.parse('http://${snapshot.data!}:$port'));
                },
                child: Text(
                  '${snapshot.data!}:$port',
                  style: const TextStyle(color: CupertinoColors.link),
                ),
              ),
            ],
          );
        }

        return const CircularProgressIndicator();
      },
    );
  }

  Widget internalIps(int port) {
    return FutureBuilder(
      future: getLocalIPs(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final widgets = <Widget>[];

          for (final ip in snapshot.data!) {
            widgets.add(
              MaterialButton(
                onPressed: () async {
                  await launchInBrowser(Uri.parse('http://$ip:$port'));
                },
                child: Text(
                  '$ip:$port',
                  style: const TextStyle(color: CupertinoColors.link),
                ),
              ),
            );
          }
          return Column(children: [
            I18nText(
              'internal_ips',
              child: const Text(
                '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...widgets
          ]);
        }

        return const CircularProgressIndicator();
      },
    );
  }

  Widget console() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 600,
      height: 272,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade600,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
          color: Colors.black,
        ),
        child: ListView.builder(
          controller: scrollController,
          itemCount: lines.where((e) => e.trim().isNotEmpty).toList().length,
          itemBuilder: (BuildContext context, int index) {
            return Text(lines.where((e) => e.trim().isNotEmpty).toList()[index]);
          },
        ),
      ),
    );
  }

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<String?> getExternalIP() async {
    if (externalIp != null) {
      return externalIp;
    }

    var response = await http.get(Uri.parse('https://ifconfig.co/ip'));
    if (response.statusCode == 200) {
      externalIp = response.body.trim();
      return externalIp;
    }
    return null;
  }

  Future<List<String>> getLocalIPs() async {
    List<String> ips = [];

    for (var interface in await NetworkInterface.list(
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    )) {
      for (var addr in interface.addresses) {
        ips.add(addr.address);
      }
    }

    return ips;
  }

  Future<void> startSdProcess(Settings settings) async {
    if (process != null) {
      // Wait for the current process to end
      await process!.exitCode;
    }

    _started = true;
    startProcess(settings);
  }

  void startProcess(Settings settings) async {
    if (settings.path == null) {
      return;
    }

    // Replace the path with the path to your test .bat file
    process = await Process.start(
      'cmd',
      ['/c', settings.path!],
      workingDirectory: dirname(settings.path!),
    );

    // Listen to the output
    process!.stdout.transform(utf8.decoder).listen((event) {
      lines.add(event);
      if (!isUpdating) {
        isUpdating = true;
        Future.delayed(const Duration(milliseconds: 100), updateState);
      }
    });

    // Also listen to errors
    process!.stderr.transform(utf8.decoder).listen((event) {
      lines.add(event);
      if (!isUpdating) {
        isUpdating = true;
        Future.delayed(const Duration(milliseconds: 100), updateState);
      }
    });

    process!.exitCode.then((_) {
      process = null;
      setState(() {});
    });
  }

  void updateState() {
    if (lines.isNotEmpty) {
      setState(() {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
        isUpdating = false;
      });
    }
  }

  Future<void> abortSdProcess() async {
    if (process == null) {
      return;
    }

    _started = false;
    _serverStatus = false;
    killProcessAndChildren(process!);
  }

  void killProcessAndChildren(Process process) async {
    int pid = process.pid;
    ProcessResult results = await Process.run('WMIC', ['process', 'where', '(ParentProcessId=$pid)', 'get', 'ProcessId']);

    var lines = results.stdout.toString().split('\n').map((e) => e.trim()).toList();
    // Remove empty strings from the list
    lines.removeWhere((pid) => pid.trim().isEmpty);
    // The first line is a header, so we remove it
    if (lines.isNotEmpty) {
      lines.removeAt(0);
    }

    for (var childPid in lines) {
      log('Kill process $childPid');
      await Process.run('taskkill', ['/PID', childPid, '/F', '/T']);
    }

    log('Kill parent process $pid');
    process.kill();
    setState(() {});
  }
}

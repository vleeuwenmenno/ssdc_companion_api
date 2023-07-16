import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:ssdc_companion_ui/settings.dart';
import 'package:ssdc_companion_ui/utils/debug.dart';
import 'package:ssdc_companion_ui/utils/installation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'main_page.dart';

// ignore: constant_identifier_names
const String PYTHON_310_URL = 'https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip';

// ignore: constant_identifier_names
const String A1111_UI_URL = 'https://github.com/AUTOMATIC1111/stable-diffusion-webui.git';

// ignore: constant_identifier_names
const String GIT_URL = 'https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.1/Git-2.41.0-64-bit.exe';

class InstallPage extends StatefulWidget {
  const InstallPage({Key? key}) : super(key: key);

  @override
  InstallPageState createState() => InstallPageState();
}

class InstallPageState extends State<InstallPage> {
  bool busyGitInstall = false;
  bool busyA1111Install = false;
  bool busyPythonInstall = false;

  Future<void> downloadAndExtractZip(String url, String path) async {
    // Validate that the URL is a .zip file
    if (!url.toLowerCase().endsWith('.zip')) {
      log('URL must be a .zip file');
      return;
    }

    // Check if tmp directory exists, and remember if we created it
    final tmpDir = Directory('./tmp');
    final bool createdTmp = !await tmpDir.exists();
    if (createdTmp) {
      tmpDir.createSync();
    }

    // Download the file to tmp directory
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      log('Failed to download the file: ${response.statusCode}');
      return;
    }

    // Write the downloaded file to disk
    final zipFile = File('${tmpDir.path}/file.zip');
    await zipFile.writeAsBytes(response.bodyBytes);

    // Decode the zip file
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the zip file
    for (final file in archive) {
      final filename = p.join(path, file.name);
      if (file.isFile) {
        final data = file.content as List<int>;
        File(filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(filename).createSync(recursive: true);
      }
    }

    // Delete the downloaded zip file
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    // Delete the tmp directory if we created it
    if (createdTmp && await tmpDir.exists()) {
      await tmpDir.delete();
    }

    log('File downloaded, extracted, and cleaned up successfully');
  }

  Future<void> cloneRepo() async {
    // Clone the repo
    final cloneProcessResult = await Process.run('git', ['clone', A1111_UI_URL, './a1111']);
    if (cloneProcessResult.exitCode != 0) {
      log('Failed to clone the repository: ${cloneProcessResult.stderr}');
      return;
    }

    // Confirm it's there
    final tmpDir = Directory('./tmp');
    if (!await tmpDir.exists()) {
      log('Failed to clone the repository: directory does not exist');
      return;
    }
    log('Repository successfully cloned and moved to ./a1111');
    setState(() {});
  }

  Future<void> downloadAndExtractGit() async {
    // Download the file
    HttpClient client = HttpClient();
    final fileName = GIT_URL.split('/').last;
    var downloadData = <int>[];
    var request = await client.getUrl(Uri.parse(GIT_URL));
    var response = await request.close();
    await for (var bytes in response) {
      downloadData.addAll(bytes);
    }
    await File('./tmp/$fileName').writeAsBytes(downloadData);

    // Run the file
    var process = await Process.run('./tmp/$fileName', ['/SILENT']);
    log('Git installed, exit code: ${process.exitCode}');
    setState(() {});
  }

  Future<void> adjustScript(String path, Settings settings) async {
    String os = Platform.operatingSystem;
    String filename = os == 'windows' ? 'webui-user.bat' : 'webui-user.sh';
    String filePath = '$path\\$filename';
    List<String> lines = await File(filePath).readAsLines();

    int index;
    if (os == 'windows') {
      index = lines.indexWhere((line) => line.startsWith('set COMMANDLINE_ARGS='));
      lines[index] = 'set COMMANDLINE_ARGS=--listen --api --xformers';
    } else {
      index = lines.indexWhere((line) => line.startsWith('#export COMMANDLINE_ARGS=""'));
      lines[index] = 'export COMMANDLINE_ARGS="--listen --api"';
    }

    if (!settings.useSystemPython) {
      index = lines.indexWhere((line) => line.startsWith('set PYTHON='));
      lines[index] = 'set PYTHON="${Directory('python').absolute.path}\\python.exe"';
    }

    await File(filePath).writeAsString(lines.join('\n'));
  }

  Future<bool> runInstallation(Settings settings) async {
    var pythonOk = await isCompatiblePython(settings.useSystemPython ? '.' : './python');
    var gitOk = (await checkGit(!settings.forceGitDownload ? '.' : './git/bin')) != NO_GIT;
    var a1111Ok = settings.a1111Ok;

    if (pythonOk && a1111Ok && gitOk) {
      return true;
    }

    if (!pythonOk || !gitOk) {
      await Directory('./tmp').create();
    }

    if (!gitOk && !busyGitInstall) {
      busyGitInstall = true;
      settings.forceGitDownload = false;
      settings.save();

      await downloadAndExtractGit();
      busyGitInstall = false;
    }

    if (!a1111Ok && !busyA1111Install) {
      busyA1111Install = true;
      await cloneRepo();
      await adjustScript(Directory('a1111').absolute.path, settings);

      settings.path = '${Directory('a1111').absolute.path}\\webui-user.bat';
      settings.save();

      busyA1111Install = false;
    }

    if (!pythonOk && !busyPythonInstall) {
      busyPythonInstall = true;
      settings.useSystemPython = false;
      settings.save();

      await downloadAndExtractZip(PYTHON_310_URL, './python');
      await adjustScript(Directory('a1111').absolute.path, settings);
      busyPythonInstall = false;
      setState(() {});
    }

    pythonOk = await isCompatiblePython(settings.useSystemPython ? '.' : './python');
    gitOk = (await checkGit(!settings.forceGitDownload ? '.' : './git/bin')) != NO_GIT;
    a1111Ok = settings.a1111Ok;

    if (Directory('./tmp').existsSync() && !busyGitInstall && !busyPythonInstall) {
      await Directory('./tmp').delete(recursive: true);
    }

    if (!busyGitInstall && !busyPythonInstall && !busyA1111Install && pythonOk && gitOk && a1111Ok) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const MainPage();
          },
        ),
      );
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "install_title"),
        ),
      ),
      body: FutureBuilder(
        future: Settings.load(),
        builder: (context, settingsSnapshot) {
          final settings = settingsSnapshot.data;

          if (settings == null) {
            return const CircularProgressIndicator();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: checkGit(!settings.forceGitDownload ? '.' : './git/bin'),
                builder: (context, gitSnapshot) {
                  if (gitSnapshot.data == null) {
                    return const CircularProgressIndicator();
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gitSnapshot.data! != NO_GIT ? Icons.check_circle : Icons.error,
                        color: gitSnapshot.data! != NO_GIT ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      I18nText(
                        gitSnapshot.data! != NO_GIT
                            ? FlutterI18n.translate(context, "git_detected")
                            : FlutterI18n.translate(context, "git_not_detected"),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder(
                future: isCompatiblePython(settings.useSystemPython ? '.' : './python'),
                builder: (context, isCompatiblePythonSnapshot) {
                  if (isCompatiblePythonSnapshot.data == null) {
                    return const CircularProgressIndicator();
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCompatiblePythonSnapshot.data! ? Icons.check_circle : Icons.error,
                        color: isCompatiblePythonSnapshot.data! ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      I18nText(
                        isCompatiblePythonSnapshot.data!
                            ? FlutterI18n.translate(context, "python_version_compatible")
                            : FlutterI18n.translate(context, "python_version_incompatible"),
                      ),
                    ],
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    settings.a1111Ok ? Icons.check_circle : Icons.error,
                    color: settings.a1111Ok ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  I18nText(
                    settings.a1111Ok
                        ? FlutterI18n.translate(context, "a1111_detected")
                        : FlutterI18n.translate(context, "a1111_not_detected"),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FutureBuilder(
                  future: runInstallation(settings),
                  builder: (context, snapshot) {
                    return Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        I18nText('download_install_text')
                      ],
                    );
                  }),
            ],
          );
        },
      ),
    );
  }
}

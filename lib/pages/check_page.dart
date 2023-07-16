import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:ssdc_companion_ui/pages/install_page.dart';
import 'package:ssdc_companion_ui/pages/main_page.dart';
import 'package:ssdc_companion_ui/settings.dart';
import 'package:ssdc_companion_ui/utils/installation.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({Key? key}) : super(key: key);

  @override
  CheckPageState createState() => CheckPageState();
}

class CheckPageState extends State<CheckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "title"),
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
              MaterialButton(
                onPressed: () async {
                  final pythonOk = await isCompatiblePython(settings.useSystemPython ? '.' : './python');
                  final gitOk = await checkGit(!settings.forceGitDownload ? '.' : './git/bin');
                  final a1111Ok = settings.a1111Ok;

                  if (gitOk == NO_GIT || !pythonOk || !a1111Ok) {
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const InstallPage();
                        },
                      ),
                    );
                  } else {
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
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_circle_right_outlined),
                    const SizedBox(width: 8),
                    I18nText('continue'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dotenv/dotenv.dart';
import 'package:isar/isar.dart';
import 'package:http/http.dart' as http;
import 'package:ssdc_companion_api/helpers/user/user.helpers.dart';
import 'package:ssdc_companion_api/models/login/session.dart';
import 'package:ssdc_companion_api/models/user/user.dart';
import 'package:ssdc_companion_api/models/user/user_trait.dart';
import 'package:ssdc_companion_api/models/user/user_viewed_by.dart';
import 'package:ssdc_companion_api/routes/models/register_request.dart';
import 'package:ssdc_companion_api/sd-api/a1111_api.dart';
import 'package:ssdc_companion_api/services/api_service.dart';
import 'package:ssdc_companion_api/utilities/utilities.dart';

final _schemas = List<CollectionSchema<dynamic>>.empty(growable: true);
final _apiController = ApiService();

void main(List<String> args) async {
  String os = Platform.operatingSystem;
  if (os != 'windows') {
    print('This app is designed for use on Windows, $os might work but no guarantee.');
  }

  // Define schemas
  _schemas.addAll([UserSchema, UserTraitSchema, LoginSessionSchema, UserViewsSchema]);

  final env = DotEnv(includePlatformEnvironment: true)..load();
  String ip = await printIps();
  String path = File('.env').existsSync() ? env['STABLE_DIFFUSION_PATH'] as String : '';
  String host = 'http://$ip:7860';
  String python = await checkPythonVersion();
  String sdwuiv = args.isNotEmpty ? args.first : '1.4.0';

  if (!path.endsWith('\\')) {
    path = '$path\\';
  }

  if (File('.env').existsSync() && Directory(path).existsSync()) {
    if (!['python3.10', 'python3', 'python'].any((element) => element == python)) {
      print(python);
      return;
    }
    print('Stable Diffusion WebUI v$sdwuiv');

    startSd(path, host);
    await startApp();
  } else {
    print('Welcome to Diffu Companion App');

    if (ask('Do you already have A1111 Stable Diffusion running?', yesNoQuestion: true)) {
      if (ask('Is your A1111 Stable Diffusion host running on this PC?', yesNoQuestion: true, defaultAnswer: YesNoAnswer.yes)) {
        path = ask("What's your A1111 Stable Diffusion WebUI directory?", directoryQuestion: true);
      } else {
        host = ask(
            'What\'s your A1111 Stable Diffusion host? (For example: http://x.x.x.x:7860 or https://stablediffusion.example.com)',
            hostIpQuestion: true);
      }

      if (path.isNotEmpty && ask('Is A1111 Stable Diffusion running right now?', yesNoQuestion: true)) {
        print('Please close it and restart this app.');
        return;
      } else {
        print('We will save the following settings now:');
        print('Host is: $host');
        print('Stable Diffusion path: $path');

        writeEnvFile(host, path);

        startSd(path, host);
        await startApp();
      }
    } else {
      if (['python3.10', 'python3', 'python'].any((element) => element == python)) {
        bool proceed = ask('Looks like you\'re ready to install, should we install A1111 Stable Diffusion for you now?',
            yesNoQuestion: true, defaultAnswer: YesNoAnswer.yes);

        if (!proceed) {
          return;
        }

        print('Downloading A1111 Stable Diffusion WebUI ...');
        await downloadFile(
            'https://github.com/AUTOMATIC1111/stable-diffusion-webui/archive/refs/tags/v$sdwuiv.zip', '$sdwuiv.zip');

        print('Creating folders and unzipping ...');
        await Directory('stable-diffusion-webui-$sdwuiv').create(recursive: true);
        await File('$sdwuiv.zip').rename('stable-diffusion-webui-$sdwuiv/$sdwuiv.zip');
        await extractZip('stable-diffusion-webui-$sdwuiv/$sdwuiv.zip', '.');
        await File('stable-diffusion-webui-$sdwuiv/$sdwuiv.zip').delete();

        print('Creating .env file ...');
        writeEnvFile(host, Directory('stable-diffusion-webui-$sdwuiv/').path);

        print('Adjusting A1111 Stable Diffusion WebUI start script to allow API usage ...');
        await adjustScript('stable-diffusion-webui-$sdwuiv');
        startSd('${Directory.current.path}/stable-diffusion-webui-$sdwuiv', host);
        await startApp();
      } else {
        print(python);
        ask('Press to continue ...');
      }
    }
    ask('Press to continue  ...');
  }
}

Future<void> downloadFile(String url, String filename) async {
  var request = await http.Client().get(Uri.parse(url));
  var bytes = request.bodyBytes;
  await File(filename).writeAsBytes(bytes);
}

Future<void> extractZip(String zipPath, String outputPath) async {
  final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());
  for (final file in archive) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      final f = File('$outputPath/$filename');
      await f.create(recursive: true);
      await f.writeAsBytes(data);
    } else {
      Directory('$outputPath/$filename').createSync(recursive: true);
    }
  }
}

void writeEnvFile(String host, String path) {
  var envFile = File('.env.example').readAsStringSync();
  envFile = envFile.replaceAll('STABLE_DIFFUSION_HOST=""', 'STABLE_DIFFUSION_HOST="$host"');
  envFile = envFile.replaceAll('STABLE_DIFFUSION_PATH=""', 'STABLE_DIFFUSION_PATH="$path"');
  File('.env').writeAsStringSync(envFile);
}

Future<void> adjustScript(String path) async {
  String os = Platform.operatingSystem;
  String filename = os == 'windows' ? 'webui-user.bat' : 'webui-user.sh';
  String filePath = '$path/$filename';
  String content = await File(filePath).readAsString();

  if (os == 'windows') {
    content = content.replaceFirst('set COMMANDLINE_ARGS=', 'set COMMANDLINE_ARGS=--listen --api --xformers');
  } else {
    content = content.replaceFirst('#export COMMANDLINE_ARGS=""', 'export COMMANDLINE_ARGS="--listen --api"');
  }

  await File(filePath).writeAsString(content);
}

void startSd(String path, String host) async {
  String os = Platform.operatingSystem;
  String filename = os == 'windows' ? 'webui-user.bat' : 'webui.sh';
  String filePath = '$path$filename';

  print('$path -> $filePath\n');

  if (os != 'windows') {
    var result = await Process.run('ls', ['-l', filePath]);
    if (!result.stdout.toString().contains('x')) {
      await Process.run('chmod', ['+x', filePath]);
    }
  }

  print('!!! BOTH TERMINAL WINDOWS NEED TO STAY OPEN, DON\'T CLOSE THEM !!!\n');

  print('Once the A1111 Stable Diffusion WebUI is running, you can access it at ${host.replaceAll(':7860', '')}:8080');
  print('Want to access from outside your home? You could setup Tailscale/ZeroTier/Hamachi to access it remotely.');

  print('To quit, close both windows.\n');

  if (os == 'windows') {
    await Process.start('cmd.exe', ['/C', 'start', 'cmd.exe', '/K', filename], workingDirectory: path.replaceAll('/', '\\'));
  } else if (os == 'macos') {
    Process.start(
        'osascript', ['-e', 'tell application "Terminal" to do script "$filePath; echo Press any key to exit...; read"']);
  } else if (os == 'linux') {
    Process.start('gnome-terminal', ['--', '/bin/sh', '-c', '$filePath; echo Press any key to exit...; read']);
  } else {
    print('Unsupported OS: $os');
    return;
  }
}

Future<String> checkPythonVersion() async {
  List<String> commands = ['python3.10', 'python3', 'python'];
  for (var command in commands) {
    try {
      final result = await Process.run(command, ['--version']);
      if (result.exitCode == 0) {
        var version = result.stdout.toString().split(' ')[1].trim();
        if (version.startsWith('3.10.')) {
          print('Python v$version');
          return command;
        } else if (version.startsWith('3.')) {
          return '\nPython appears to be installed (Version $version) but the wrong version, please remove it and install version 3.10.x\n\nFor Windows: download and install Python 3.10.x from https://www.python.org/downloads/\n(Make sure when you install it to check the mark to add python to all users on the PC and to add it the PATH.)\n\nFor MacOS: you can install it with Homebrew in a Terminal, open a Terminal and type: brew install python3 (If you don\'t have homebrew please install it from https://brew.sh/)';
        }
      }
    } catch (e) {
      // Ignore
    }
  }
  return '\nPython appears to be installed but the wrong version, please remove it and install version 3.10.x\n\nFor Windows: download and install Python 3.10.x from https://www.python.org/downloads/\n(Make sure when you install it to check the mark to add python to all users on the PC and to add it the PATH.)\n\nFor MacOS: you can install it with Homebrew in a Terminal, open a Terminal and type: brew install python3 (If you don\'t have homebrew please install it from https://brew.sh/)';
}

Future<String> printIps() async {
  for (var interface in await NetworkInterface.list()) {
    for (var addr in interface.addresses) {
      return addr.address.toString();
    }
  }
  return '';
}

enum YesNoAnswer {
  yes,
  no,
}

dynamic ask(String message,
    {bool yesNoQuestion = false,
    bool hostIpQuestion = false,
    bool directoryQuestion = false,
    YesNoAnswer defaultAnswer = YesNoAnswer.no}) {
  stdout.write('$message ${yesNoQuestion ? (defaultAnswer == YesNoAnswer.yes ? '(Y/n)' : '(y/N)') : ': '}');
  var result = stdin.readLineSync()!.trim();

  if (yesNoQuestion) {
    if (result.isEmpty) {
      return defaultAnswer == YesNoAnswer.yes;
    }

    if (result.toLowerCase() != 'y' && result.toLowerCase() != 'n') {
      return ask('Invalid answer $result, ${(defaultAnswer == YesNoAnswer.yes ? '(Y/n)' : '(y/N)')}',
          defaultAnswer: defaultAnswer);
    }

    return result.toLowerCase() == 'y';
  } else {
    if (directoryQuestion) {
      if (!Directory(result).existsSync()) {
        return ask('The given directory does not exist. Please try again.', directoryQuestion: true);
      }
    }
    if (hostIpQuestion) {
      if (Uri.tryParse(result) == null) {
        return ask('The given host/ip does not work. Please try again.', hostIpQuestion: true);
      }
    }
    return result;
  }
}

Future<void> startApp() async {
  // Initialize services
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final api = A1111Api(env.getOrElse('STABLE_DIFFUSION_HOST', () => Directory.current.path));

  serviceCollection.addAll([api, env]);

  final isar = await Isar.open(_schemas, directory: env.getOrElse('ISAR_DIRECTORY', () => Directory.current.path));
  serviceCollection.addAll([isar]);

  if (await isar.users.count() == 0) {
    final user = Utilities.generateRandomString(8);
    final pass = Utilities.generateRandomString(8);
    await User_.fromRegisterRequest(RegisterRequest(password: pass, username: user));

    print('!!! WARNING THIS WILL ONLY SHOW ONCE !!!');
    print('User created: $user');
    print('With password: $pass');
    print('Please store this password somewhere safe.\n');
    print('!!! WARNING THIS WILL ONLY SHOW ONCE !!!');
  }

  // Start api server
  await _apiController.startApi();
}

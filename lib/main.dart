import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:ssdc_companion_ui/diffu_companion.dart';
import 'package:ssdc_companion_ui/utils/debug.dart';

void main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(useCountryCode: false, fallbackFile: 'en', basePath: 'assets/i18n'),
  );
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    log('Error From INSIDE FRAMEWORK', 'FLUTTER_ERROR', 'EXCEPTION');
    log('----------------------', 'FLUTTER_ERROR', 'EXCEPTION');
    log('Error :  ${details.exception}', 'FLUTTER_ERROR', 'EXCEPTION');
    log('StackTrace :  ${details.stack}', 'FLUTTER_ERROR', 'EXCEPTION');
  };
  runApp(DiffuCompanion(flutterI18nDelegate));
}

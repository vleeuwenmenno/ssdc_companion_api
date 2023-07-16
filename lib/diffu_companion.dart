import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ssdc_companion_ui/pages/check_page.dart';
import 'package:ssdc_companion_ui/utils/color.dart';

class DiffuCompanion extends StatefulWidget {
  const DiffuCompanion(this.flutterI18nDelegate, {Key? key}) : super(key: key);

  final FlutterI18nDelegate flutterI18nDelegate;

  @override
  DiffuCompanionState createState() => DiffuCompanionState();
}

class DiffuCompanionState extends State<DiffuCompanion> {
  ThemeMode themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    brightness.value = MediaQuery.platformBrightnessOf(context);
    themeMode = MediaQuery.of(context).platformBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    final materialLightTheme = ThemeData.light().copyWith(
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: getPrimaryColor(),
        unselectedItemColor: getInactiveColor(),
      ),
    );
    final materialDarkTheme = ThemeData.dark().copyWith(
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: getPrimaryColor(),
        unselectedItemColor: getInactiveColor(),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: materialLightTheme,
      darkTheme: materialDarkTheme,
      localizationsDelegates: [
        widget.flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: FlutterI18n.rootAppBuilder(),
      home: const CheckPage(),
    );
  }
}

import 'package:flutter/cupertino.dart';

final brightness = ValueNotifier<Brightness>(Brightness.dark);

Color getBackgroundColor() {
  return brightness.value == Brightness.dark ? CupertinoColors.darkBackgroundGray : const Color.fromARGB(255, 242, 242, 242);
}

Color getPageBackgroundColor() {
  return brightness.value == Brightness.dark ? CupertinoColors.black : CupertinoColors.white;
}

Color getMenuColor() {
  return brightness.value == Brightness.dark
      ? CupertinoColors.darkBackgroundGray.withOpacity(0.5)
      : CupertinoColors.extraLightBackgroundGray.withOpacity(0.75);
}

Color getOpacityColor() {
  return brightness.value == Brightness.dark
      ? CupertinoColors.darkBackgroundGray.withAlpha(190)
      : CupertinoColors.extraLightBackgroundGray.withAlpha(190);
}

Color getInputBackgroundColor() {
  return brightness.value == Brightness.dark ? CupertinoColors.black : CupertinoColors.white;
}

Color getForegroundColor() {
  return brightness.value == Brightness.dark ? const Color.fromARGB(255, 200, 200, 200) : CupertinoColors.black;
}

Color getPrimaryColor() {
  return brightness.value == Brightness.dark ? getStaticPrimaryColor() : const Color.fromARGB(255, 5, 5, 5);
}

Color getInactiveColor() {
  return brightness.value == Brightness.dark ? const Color.fromARGB(255, 50, 50, 50) : const Color.fromARGB(255, 90, 90, 90);
}

Color getStaticPrimaryColor() {
  return const Color.fromARGB(255, 245, 245, 245);
}

Color invertColor(Color color) {
  return Color.fromRGBO(
    255 - color.red,
    255 - color.green,
    255 - color.blue,
    color.opacity,
  );
}

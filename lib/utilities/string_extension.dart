extension StringEx on String {
  String get convertCamelCaseToReadable {
    String output = '';
    for (int i = 0; i < length; i++) {
      if (i == 0) {
        output += this[i].toUpperCase();
      } else if (this[i].toUpperCase() == this[i]) {
        output += ' ${this[i]}';
      } else {
        output += this[i];
      }
    }
    return output;
  }
}

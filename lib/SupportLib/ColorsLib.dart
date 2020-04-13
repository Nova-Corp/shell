import 'package:flutter/painting.dart';

Color colorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  return Color(int.parse('FF' + hexColor, radix: 16));
}

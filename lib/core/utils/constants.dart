import 'package:flutter/material.dart';

class Constants {
  static const BorderRadiusGeometry topOnlyBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(12),
    topRight: Radius.circular(12),
  );

  static const Duration duration = Duration(milliseconds: 500);

  static String exconFontFamily = 'Excon';
  static String generalSansFontFamily = 'GeneralSans';
}

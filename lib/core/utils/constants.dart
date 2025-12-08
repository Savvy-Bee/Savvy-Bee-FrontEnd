import 'package:flutter/material.dart';

class Constants {
  static const BorderRadiusGeometry topOnlyBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(12),
    topRight: Radius.circular(12),
  );

  // Collapsed Icon button style
  static ButtonStyle collapsedButtonStyle = IconButton.styleFrom(
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static const Duration duration = Duration(milliseconds: 500);

  static String exconFontFamily = 'Excon';
  static String generalSansFontFamily = 'GeneralSans';
  static String neulisNeueFontFamily = 'Nuelis Neue';
  static String fredokaFontFamily = 'Fredoka';

  // Environment Variables
  static String encryptionKey = 'ENCRYPTION_KEY';

  static String monoSecret = 'MONO_SECRET';
  static String monoPublic = 'MONO_PUBLIC';
}

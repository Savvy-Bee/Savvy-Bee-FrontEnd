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

  static const String exconFontFamily = 'Excon';
  static const String generalSansFontFamily = 'GeneralSans';
  static const String neulisNeueFontFamily = 'Nuelis Neue';
  static const String fredokaFontFamily = 'Fredoka';

  // Environment Variables
  static const String encryptionKey = 'ENCRYPTION_KEY';

  static const String monoSecret = 'MONO_SECRET';
  static const String monoPublic = 'MONO_PUBLIC';
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppIcons {
  static const String _basePath = 'assets/images/icons';
  static const String sparklesIcon = '$_basePath/sparkles.svg';
  static const String zapIcon = '$_basePath/zap.svg';
  static const String shareIcon = '$_basePath/share.svg';
  static const String editIcon = '$_basePath/edit.svg';
  static const String lockIcon = '$_basePath/lock.svg';
  static const String sendIcon = '$_basePath/send.svg';
  static const String infoIcon = '$_basePath/info.svg';
  static const String bankIcon = '$_basePath/bank.svg';
}

class AppIcon extends StatelessWidget {
  final String iconPath;
  final double size;
  final Color? color;

  const AppIcon(this.iconPath, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(
        color ?? Theme.of(context).iconTheme.color!,
        BlendMode.srcIn,
      ),
    );
  }
}

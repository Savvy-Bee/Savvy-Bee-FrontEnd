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
  static const String arrowRightIcon = '$_basePath/arrow-right.svg';
  static const String copyIcon = '$_basePath/copy.svg';
  static const String goalIcon = '$_basePath/goal.svg';
  static const String lifeBuoyIcon = '$_basePath/life-buoy.svg';
  static const String lineChartIcon = '$_basePath/line-chart.svg';
  static const String pieChartIcon = '$_basePath/pie-chart.svg';
  static const String walletIcon = '$_basePath/wallet.svg';
  static const String chartSquareIcon = '$_basePath/chart-square.svg';
  static const String externalLinkIcon = '$_basePath/external-link.svg';
  static const String progressIcon = '$_basePath/progress.svg';
  static const String openBookIcon = '$_basePath/open-book.svg';
  static const String chartIncreasingIcon = '$_basePath/chart-increasing.svg';
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

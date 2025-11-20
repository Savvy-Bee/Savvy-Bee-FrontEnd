import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppIcons {
  // Base Path
  static const String _basePath = 'assets/icons';

  // Nav Bar Icons
  static const String homeIcon = '$_basePath/home.svg';
  static const String budgetIcon = '$_basePath/budget.svg';
  static const String crownIcon = '$_basePath/crown.svg';
  static const String spendIcon = '$_basePath/spend.svg';
  static const String toolsIcon = '$_basePath/tools.svg';
  static const String hiveIcon = '$_basePath/hive.svg';

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
  static const String scanFaceIcon = '$_basePath/scan-face.svg';
  static const String gripIcon = '$_basePath/grip.svg';
  static const String scoreIcon = '$_basePath/score.svg';
  static const String checkIcon = '$_basePath/check.svg';
  static const String freezeIcon = '$_basePath/freeze.svg';
  static const String appIconIcon = '$_basePath/app-icon.svg';
  static const String bankNoteIcon = '$_basePath/bank-note.svg';
  static const String chatboxIcon = '$_basePath/chatbox.svg';
  static const String creditCardIcon = '$_basePath/credit-card.svg';
  static const String documentIcon = '$_basePath/document.svg';
  static const String healthIcon = '$_basePath/health.svg';
  static const String homeSecureIcon = '$_basePath/home-secure.svg';
  static const String libraryIcon = '$_basePath/library.svg';
  static const String logOutIcon = '$_basePath/log-out.svg';
  static const String moonIcon = '$_basePath/moon.svg';
  static const String personIcon = '$_basePath/person.svg';
  static const String verifiedUserIcon = '$_basePath/verified-user.svg';
  static const String questionIcon = '$_basePath/question.svg';
  static const String videoIcon = '$_basePath/video.svg';
  static const String emailIcon = '$_basePath/email.svg';
  static const String whatsAppIcon = '$_basePath/whatsapp.svg';
  static const String twitterIcon = '$_basePath/twitter.svg';
  static const String instagramIcon = '$_basePath/instagram.svg';
  static const String tiktokIcon = '$_basePath/tiktok.svg';
  static const String linkedinIcon = '$_basePath/linkedin.svg';
  static const String telegramIcon = '$_basePath/telegram.svg';
}

class AppIcon extends StatelessWidget {
  final String iconPath;
  final double? size;
  final Color? color;
  final bool useOriginal; // Use the original asset withou color filter and size

  const AppIcon(
    this.iconPath, {
    super.key,
    this.size,
    this.color,
    this.useOriginal = false,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      height: useOriginal ? null : (size ?? 16),
      width: useOriginal ? null : (size ?? 16),
      colorFilter: useOriginal
          ? null
          : ColorFilter.mode(
              color ?? Theme.of(context).iconTheme.color!,
              BlendMode.srcIn,
            ),
    );
  }
}

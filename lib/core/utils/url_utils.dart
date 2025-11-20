import 'package:url_launcher/url_launcher.dart';

class UrlUtils {
  UrlUtils._();

  static Future<void> openPhone(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static Future<void> openEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(launchUri);
  }

  static Future<void> openBrowser(String url) async {
    final Uri launchUri = Uri.parse(url);
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('whatsapp://send?phone=$phoneNumber');
    await launchUrl(launchUri);
  }

  static Future<void> openTwitter(String username) async {
    final Uri launchUri = Uri.parse('twitter://user?screen_name=$username');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      await openBrowser('https://twitter.com/$username');
    }
  }

  static Future<void> openInstagram(String username) async {
    final Uri launchUri = Uri.parse('instagram://user?username=$username');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      await openBrowser('https://www.instagram.com/$username');
    }
  }

  static Future<void> openTikTok(String username) async {
    final Uri launchUri = Uri.parse('tiktok://user/@$username');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      await openBrowser('https://www.tiktok.com/@$username');
    }
  }

  static Future<void> openLinkedIn(String profileUrl) async {
    final Uri launchUri = Uri.parse(profileUrl);
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openTelegram(String username) async {
    final Uri launchUri = Uri.parse('https://t.me/$username');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      await openBrowser('https://t.me/$username');
    }
  }
}

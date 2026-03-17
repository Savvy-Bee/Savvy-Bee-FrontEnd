import Firebase
import Flutter
import UIKit
import UserNotifications

// Unity setup - TEMPORARILY DISABLED
// import flutter_unity_widget

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Unity setup - TEMPORARILY DISABLED
    // InitUnityIntegrationWithOptions(argc: CommandLine.argc, argv: CommandLine.unsafeArgv, launchOptions)

    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.badge, .banner, .list, .sound])
  }
}

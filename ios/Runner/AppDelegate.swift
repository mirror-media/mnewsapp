import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 讓 firebase_messaging 能透過 FlutterAppDelegate 的 plugin 轉發機制
    // 收到 UNUserNotificationCenter 的 callback（前景顯示、點擊通知等）。
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // 主動向 APNs 註冊，避免在某些情況下（特別是 iOS Simulator）APNs token
    // 取得延遲，導致 FCM 的 getInitialMessage / token 流程卡住。
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

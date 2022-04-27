import UIKit
import Flutter
import HealthKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let healthKitChannel = FlutterMethodChannel(name: "mitre.org/rosie/healthkit", binaryMessenger: controller.binaryMessenger)
      healthKitChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if (call.method == "isHealthDataAvailable") {
              result(HKHealthStore.isHealthDataAvailable())
          } else {
              result(FlutterMethodNotImplemented)
          }
      })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

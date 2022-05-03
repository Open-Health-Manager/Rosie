import UIKit
import Flutter
import HealthKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    lazy var healthStore = HKHealthStore()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let healthKitChannel = FlutterMethodChannel(name: "mitre.org/rosie/healthkit", binaryMessenger: controller.binaryMessenger)
        healthKitChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch (call.method) {
            case "isHealthDataAvailable":
                result(HKHealthStore.isHealthDataAvailable())
            case "requestAccess":
                self?.requestHealthKitAccess(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func requestHealthKitAccess(result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            // Create the sample types if possible
            var types = Set<HKObjectType>()
            for type in [
                HKClinicalTypeIdentifier.allergyRecord,
                HKClinicalTypeIdentifier.conditionRecord,
                HKClinicalTypeIdentifier.immunizationRecord,
                HKClinicalTypeIdentifier.labResultRecord,
                HKClinicalTypeIdentifier.medicationRecord,
                HKClinicalTypeIdentifier.procedureRecord,
                HKClinicalTypeIdentifier.vitalSignRecord
            ] {
                if let clinicalType = HKObjectType.clinicalType(forIdentifier: type) {
                    types.insert(clinicalType)
                }
            }
            healthStore.requestAuthorization(toShare: nil, read: types, completion: { success, error in
                // The result happens in a background thread, but we want to invoke Flutter only from the main thread, so:
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "HealthKitError", message: error.localizedDescription, details: error))
                    } else {
                        result(success)
                    }
                }
            })
        } else {
            result(FlutterError(code: "HealthKitUnavailable", message: "HealthKit not available", details: nil))
        }
    }
}

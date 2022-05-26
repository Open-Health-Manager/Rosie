import UIKit
import Flutter
import HealthKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    @available(iOS 12.0, *)
    static let supportedTypes = [
//        // For now, only request access to vital sign records
//        HKClinicalTypeIdentifier.allergyRecord,
//        HKClinicalTypeIdentifier.conditionRecord,
//        HKClinicalTypeIdentifier.immunizationRecord,
//        HKClinicalTypeIdentifier.labResultRecord,
//        HKClinicalTypeIdentifier.medicationRecord,
//        HKClinicalTypeIdentifier.procedureRecord,
        HKClinicalTypeIdentifier.vitalSignRecord
    ];
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
            case "supportedClinicalTypes":
                self?.supportedClinicalTypes(result: result)
            case "queryClinicalRecords":
                self?.queryClinicalRecords(call: call, result: result)
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
            for type in AppDelegate.supportedTypes {
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
            result(healthKitNotSupported())
        }
    }

    func supportedClinicalTypes(result: FlutterResult) {
        // For this, just create a list of strings
        if #available(iOS 12.0, *) {
            print("Building supported clinical types")
            result(AppDelegate.supportedTypes.map { $0.rawValue })
        } else {
            result([])
        }
    }

    func queryClinicalRecords(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            // Create the query. For this method we expect an argument that's a string
            guard let typeString = call.arguments as? String else {
                result(FlutterError(code: "MissingArgumentsError", message: "Missing required argument type", details: nil))
                return
            }
            // This may be invalid but we won't know until...
            let typeIdentifier = HKClinicalTypeIdentifier(rawValue: typeString)
            // ...we try and create an HKObjectType from it
            guard let type = HKObjectType.clinicalType(forIdentifier: typeIdentifier) else {
                result(FlutterError(code: "HealthKitError", message: "Unsupported type", details: typeString))
                return
            }
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
                guard let actualSamples = samples else {
                    result(FlutterError(code: "HealthKitError", message: error?.localizedDescription ?? "No error given", details: error))
                    return
                }
                // And now that we have the query, export them as JSON strings (they're not decoded here, the Dart side can do that)
                var records: [[String: String?]] = []
                for sample in actualSamples {
                    let jsonData = createResponse(fromClinicalRecord: sample)
                    if let json = jsonData {
                        records.append(json)
                    }
                }
                result(records)
            }
            healthStore.execute(query)
        } else {
            result(healthKitNotSupported())
        }
    }
}

// MARK: Utility functions

func healthKitNotSupported() -> FlutterError {
    return FlutterError(code: "HealthKitUnavailable", message: "HealthKit not available", details: nil)
}

@available(iOS 12.0, *)
func createResponse(fromClinicalRecord sample: HKSample) -> [String: String?]? {
    guard let record = sample as? HKClinicalRecord else { return nil }
    guard let fhirResource = record.fhirResource else { return nil }
    guard let jsonData = String(data: fhirResource.data, encoding: .utf8) else { return nil }
    return [
        "fhirVersion": escapeFhirVersion(fromFhirResource: fhirResource),
        "sourceUrl": fhirResource.sourceURL?.absoluteString,
        "resource": jsonData
    ];
}

@available(iOS 12.0, *)
func escapeFhirVersion(fromFhirResource resource: HKFHIRResource) -> String {
    if #available(iOS 14.0, *) {
        // Rather than attempt to encode the entire thing, use the "release"
        switch (resource.fhirVersion.fhirRelease) {
        case .dstu2:
            return "dstu2"
        case .r4:
            return "r4"
        default:
            return "unknown"
        }
    } else {
        return "dstu2";
    }
}

@available(iOS 12.0, *)
func extractJSON(fromClinicalRecord record: HKClinicalRecord) -> String? {
    guard let fhirResource = record.fhirResource else { return nil }
    // This call is an optional constructor: if it fails, it returns nil.
    // Fortunately if it fails, it should return nil.
    return String(data: fhirResource.data, encoding: .utf8)
}

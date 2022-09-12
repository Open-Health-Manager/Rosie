import UIKit
import Flutter
import HealthKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    @available(iOS 12.0, *)
    /// Supported clinical types. This is the list of types that are requested when approval is requested.
    static let supportedClinicalTypes: [HKClinicalTypeIdentifier] = [
        .allergyRecord,
        .conditionRecord,
        .immunizationRecord,
        .labResultRecord,
        .medicationRecord,
        .procedureRecord,
        .vitalSignRecord
        // .coverage - skip, required ios 15
    ];
    /// Supported characteristic types. This is the list of types that are requested when approval is requested.
    static let supportedCharacteristicTypes: [HKCharacteristicTypeIdentifier] = [
        .dateOfBirth,
        .biologicalSex
    ];
    @available(iOS 14.3, *)
    /// Supported category types. This is the list of types that are requested when approval is requested.
    static let supportedCategoryTypes: [HKCategoryTypeIdentifier] = [
        .pregnancy
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
            case "supportedCategoryTypes":
                self?.supportedCategoryTypes(result: result)                
            case "queryClinicalRecords":
                self?.queryClinicalRecords(call: call, result: result)
            case "getPatientCharacteristicData":
                self?.getPatientCharacteristicData(call: call, result: result)
            case "queryCategoryData":
                self?.queryCategoryData(call: call, result: result)                
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func requestHealthKitAccess(result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            // Create the sample types
            // Failures are only really possible if forIdentifier is given an invalid identifier, which is only really possible when created via deserialization (as they're ultimately just strings)
            var types = Set<HKObjectType>()
            for type in AppDelegate.supportedClinicalTypes {
                if let clinicalType = HKObjectType.clinicalType(forIdentifier: type) {
                    types.insert(clinicalType)
                }
            }
            // Add characteristic types
            for identifier in AppDelegate.supportedCharacteristicTypes {
                if let characteristicType = HKObjectType.characteristicType(forIdentifier: identifier) {
                    types.insert(characteristicType)
                }
            }

            if #available(iOS 14.3, *) {
                // Add category types
                for identifier in AppDelegate.supportedCategoryTypes {
                    if let categoryType = HKObjectType.categoryType(forIdentifier: identifier) {
                        types.insert(categoryType)
                    }
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
        // Wait, doesn't this collide with "supportedClinicalTypes"? Nope! This is "supportedClinicalTypes:result:", of course. Swift being based on Objective-C is fun.
        // For this, just create a list of strings
        if #available(iOS 12.0, *) {
            print("Building supported clinical types")
            result(AppDelegate.supportedClinicalTypes.map { $0.rawValue })
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

    func getPatientCharacteristicData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            let birthdayComponents = getDateOfBirthComponents()
            let biologicalSex =  getBiologicalSex()
            result([
                "gender": getGenderCodeString(fromBiologicalSex: biologicalSex),
                "dateOfBirth" : getFHIRDateString(fromDateComponents: birthdayComponents)
            ])
        } else {
            result(healthKitNotSupported())
        }
    }

    @available(iOS 12.0, *)
    func getDateOfBirthComponents() -> DateComponents? {
        do {
            return try healthStore.dateOfBirthComponents()
        } catch {
            return nil
        }
    }

    @available(iOS 12.0, *)
    func getBiologicalSex() -> HKBiologicalSexObject? {
        do {
            return try healthStore.biologicalSex()
        } catch {
            return nil
        }
    }

    func supportedCategoryTypes(result: FlutterResult) {
        if #available(iOS 14.3, *) {
            print("Building supported category types")
            result(AppDelegate.supportedCategoryTypes.map { $0.rawValue })
        } else {
            result([])
        }
    }

    func queryCategoryData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 14.3, *) {
            // Create the query. For this method we expect an argument that's a string
            guard let typeString = call.arguments as? String else {
                result(FlutterError(code: "MissingArgumentsError", message: "Missing required argument type", details: nil))
                return
            }

            let typeIdentifier = HKCategoryTypeIdentifier(rawValue: typeString)
            // ...we try and create an HKObjectType from it
            guard let type = HKObjectType.categoryType(forIdentifier: typeIdentifier) else {
                result(FlutterError(code: "HealthKitError", message: "Unsupported type", details: typeString))
                return
            }

            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
                guard let actualSamples = samples else {
                    result(FlutterError(code: "HealthKitError", message: error?.localizedDescription ?? "No error given", details: error))
                    return
                }
                
                var records: [[String: String?]] = []
                for sample in actualSamples {
                    let response = createCategoryValueResponse(fromCategory: sample)
                    if let record = response {
                        records.append(record)  
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

@available(iOS 12.0, *)
func getGenderCodeString(fromBiologicalSex biologicalSex: HKBiologicalSexObject?) -> String {
    guard let biologicalSexEnum = biologicalSex?.biologicalSex else { return "" }
    switch (biologicalSexEnum) {
        case HKBiologicalSex.notSet: return ""
        case HKBiologicalSex.female: return "female"
        case HKBiologicalSex.male: return "male"
        case HKBiologicalSex.other: return "other"
        default: return ""
    }
}

@available(iOS 12.0, *)
func getFHIRDateString(fromDateComponents dateComponents: DateComponents?) -> String {
    guard let dateYear = dateComponents?.year else { return "" }
    guard let dateMonth = dateComponents?.month else { return "" }
    guard let dateDay = dateComponents?.day else { return "" }
    let dateMonthString = dateMonth > 9 ? "\(dateMonth)" : "0\(dateMonth)"
    let dateDayString = dateDay > 9 ? "\(dateDay)" : "0\(dateDay)"
    
    return "\(dateYear)-\(dateMonthString)-\(dateDayString)"
}

@available(iOS 12.0, *)
func createCategoryValueResponse(fromCategory sample: HKSample) -> [String: String?]? {
    guard let record = sample as? HKCategorySample else { return nil }
    var value: String = "unknown"
    if #available(iOS 14.3, *) {
        if(type(of: record.sampleType.identifier) == type(of: HKCategoryTypeIdentifier.pregnancy.rawValue)){
            switch (record.value) {
                case HKCategoryValue.notApplicable.rawValue: value = "notApplicable"
                default: value = "unknown"
            }
        }
    }

    let startDate = getFHIRDateString(fromDateComponents: Calendar.current.dateComponents([.year, .month, .day], from: record.startDate))
    let endDate = getFHIRDateString(fromDateComponents: Calendar.current.dateComponents([.year, .month, .day], from: record.endDate))
     
    return [
        "uuid": record.uuid.uuidString,
        "sampleType": record.sampleType.identifier,
        "value": value,
        "startDate": startDate,
        "endDate": endDate
    ];
}

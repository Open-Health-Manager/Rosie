import 'dart:io';

import 'package:flutter/services.dart';

// HealthKit class. This represents the HKHealthStore class in Objective-C.
// Note that while you can construct this, it requires
class HealthKit {
  // Channel through which HealthKit requests are sent
  static const platform = MethodChannel('mitre.org/rosie/healthkit');

  HealthKit();

  // Check if HealthKit is supported on this device. Can only return true on
  // iOS devices, and specifically iPhones. If this method returns false, then
  // all other function calls will return null!
  static Future<bool> isHealthDataAvailable() async {
    // Only possibly available on iOS
    if (Platform.isIOS) {
      final available = await platform.invokeMethod("isHealthDataAvailable");
      return available as bool;
    } else {
      return false;
    }
  }

  static Future<bool> supportsHealthRecords() async {
    if (Platform.isIOS) {
      final available = await platform.invokeMethod("supportsHealthRecords");
      return available as bool;
    } else {
      return false;
    }
  }
}
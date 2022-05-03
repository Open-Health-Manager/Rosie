import 'dart:io';

import 'package:flutter/services.dart';

/// HealthKit interface: provides methods for accessing HealthKit data.
class HealthKit {
  // Channel through which HealthKit requests are sent
  static const platform = MethodChannel('mitre.org/rosie/healthkit');

  HealthKit();

  /// Check if HealthKit is supported on this device. Can only return true on
  /// iOS devices, and specifically iPhones. If this method returns false, then
  /// all other function calls will return null!
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

  /// Attempts to request access to HealthKit data. The exact fields that access is requested to are defined in the iOS
  /// portion of the app, this simply tells the iOS code to invoke them. The returned bool indicates whether this
  /// operation was successful.
  static Future<bool> requestAccess() async {
    return await platform.invokeMethod('requestAccess');
  }
}
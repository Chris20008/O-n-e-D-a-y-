import 'package:flutter/services.dart';

class ICloudService {
  static const MethodChannel _channel = MethodChannel('com.onedayapp/icloud_storage');

  static Future<String?> readFromICloud(String fileName) async {
    final String? result = await _channel.invokeMethod('readFromICloud', {'fileName': fileName});
    return result;
  }

  static Future<bool> isICloudAvailable() async {
    final bool result = await _channel.invokeMethod('isICloudAvailable');
    return result;
  }
}
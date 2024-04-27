import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CustomCacheManager {
  CustomCacheManager();

  Future<File> saveData(Map<String, dynamic> data, String fileName) async {
    final file = await getLocalFile(fileName);
    final jsonData = jsonEncode(data);
    return file.writeAsString(jsonData);
  }

  Future<Map<String, dynamic>?> readData({
    required String fileName,
    String? pathName
  }) async {
    try {
      final file = pathName == null
        ? await getLocalFile(fileName)
        : File('$pathName/$fileName.json');

      /// Read the file
      final resultString = await file.readAsString();
      final dataMap = jsonDecode(resultString);
      return dataMap;
    } catch (e) {
      /// If encountering an error, return null
      return null;
    }
  }

  /// Get File with given filename from ApplicationDocumentsDirectory
  /// If the File does not exist it will be created instead
  Future<File> getLocalFile(String fileName) async {
    final rootPath = await getLocalPath();
    return File('$rootPath/$fileName.json');
  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
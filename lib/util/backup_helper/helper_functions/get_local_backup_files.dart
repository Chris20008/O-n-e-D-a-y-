import 'dart:io';

import 'get_local_path.dart';

Future<List<FileSystemEntity>> getLocalBackupFiles({int delay = 0}) async{
  if(delay > 0){
    await Future.delayed(Duration(milliseconds: delay));
  }

  final path = await getLocalPath();

  List<FileSystemEntity> localFiles = await Directory("$path/").list().where((element) => element.path.contains("_Backup")).toList();

  /// Sort [fileList] by modification times, from oldest to newest.
  localFiles.sort((a, b) => b.path.split("_").last.compareTo(a.path.split("_").last));
  return localFiles;
}
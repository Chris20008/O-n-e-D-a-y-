import 'dart:io';
import '../../../main.dart';
import 'load_backup_from_string.dart';

Future<bool> loadBackupFromFile(File file, {CnHomepage? cnHomepage}) async{
  final content = await file.readAsString();
  return await loadBackupFromString(content: content, cnHomepage: cnHomepage);
}
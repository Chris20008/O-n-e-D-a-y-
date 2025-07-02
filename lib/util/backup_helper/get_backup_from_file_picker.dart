import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../main.dart';

Future<File?> getFileFromFilePicker({CnHomepage? cnHomepage}) async{
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    initialDirectory: "/storage/emulated/0/Android/data/christian.range.fitnessapp.fitness_app/files",
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    return file;
  } else {
    return null;
  }
}
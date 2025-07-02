import 'dart:convert';

import 'package:crypto/crypto.dart';

mixin Checksum {
  String get checksumString;

  String get currentChecksum => sha256.convert(utf8.encode(checksumString)).toString();

}
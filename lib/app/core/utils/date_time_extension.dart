import 'dart:io';

import 'package:intl/intl.dart';
class DateTimePattern{
  DateTimePattern._();
  static const String yyyyMMddHHmmA="yyyy-MM-dd hh:mm a";
  static const String yyyMMddHHmmSS="yyyy-MM-dd hh:mm:ss";
  static const String yyyyMMdd="yyyy-MM-dd";
  static const String hhMMss="hh:mm:ss";
}
extension DateFormatter on DateTime {
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }
}

extension FileExtention on FileSystemEntity{
  String? get lastName {
    return path.split(Platform.pathSeparator).last;
  }
}
extension FileUtils on File {
 double get size {
    int sizeInBytes = lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }
}
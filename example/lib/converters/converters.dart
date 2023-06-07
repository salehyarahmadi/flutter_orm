import 'package:flutter/material.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';

class Converters {
  @TypeConverter()
  static TimeOfDay? function1(String? val) {
    return TimeOfDay.now();
  }

  @TypeConverter()
  static String? function2(TimeOfDay? dateTime) {
    return '';
  }
}

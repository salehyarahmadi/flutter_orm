import 'package:flutter_orm/converter/base_converter.dart';

class DateTimeConverter implements BaseConverter<DateTime, String> {
  @override
  String from(DateTime value) {
    return value.toIso8601String();
  }

  @override
  DateTime to(String value) {
    return DateTime.parse(value);
  }
}

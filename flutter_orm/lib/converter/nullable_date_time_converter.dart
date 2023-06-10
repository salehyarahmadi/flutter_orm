import 'package:flutter_orm/converter/base_converter.dart';

class NullableDateTimeConverter implements BaseConverter<DateTime?, String?> {
  @override
  String? from(DateTime? value) {
    if (value == null) return null;
    return value.toIso8601String();
  }

  @override
  DateTime? to(String? value) {
    if (value == null) return null;
    return DateTime.parse(value);
  }
}

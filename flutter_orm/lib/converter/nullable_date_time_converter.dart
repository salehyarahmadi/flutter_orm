import 'package:flutter_orm/converter/base_converter.dart';

/// This class is a converter for nullable [DateTime] (DateTime?) type.
/// it converts to nullable [String] (String?) that is a sqlite supported type.
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

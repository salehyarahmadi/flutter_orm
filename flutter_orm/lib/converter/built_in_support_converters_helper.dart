import 'package:flutter_orm/converter/base_converter.dart';
import 'package:flutter_orm/converter/bool_converter.dart';
import 'package:flutter_orm/converter/date_time_converter.dart';
import 'package:flutter_orm/converter/double_converter.dart';
import 'package:flutter_orm/converter/nullable_bool_converter.dart';
import 'package:flutter_orm/converter/nullable_date_time_converter.dart';
import 'package:flutter_orm/converter/nullable_double_converter.dart';

/// Helper class for convert build-in support types to
/// proper sqlite database type dynamically.
class PredefinedConvertersHelper {
  static final Map<String, String> _predefinedConverterTypes = {
    'bool': 'INTEGER NOT NULL',
    'bool?': 'INTEGER',
    'DateTime': 'TEXT NOT NULL',
    'DateTime?': 'TEXT',
    'double': 'REAL NOT NULL',
    'double?': 'REAL',
  };

  static final Map<String, BaseConverter> _predefinedConverters = {
    'bool': BoolConverter(),
    'bool?': NullableBoolConverter(),
    'DateTime': DateTimeConverter(),
    'DateTime?': NullableDateTimeConverter(),
    'double': DoubleConverter(),
    'double?': NullableDoubleConverter(),
  };

  static bool isPredefinedConverterType(String dartType) {
    return _predefinedConverters.keys.contains(dartType);
  }

  static String? getProperSqliteType(String dartType) {
    return _predefinedConverterTypes[dartType];
  }

  static dynamic to(String type, value) {
    return _predefinedConverters[type]?.to(value);
  }

  static dynamic from(String type, value) {
    return _predefinedConverters[type]?.from(value);
  }
}

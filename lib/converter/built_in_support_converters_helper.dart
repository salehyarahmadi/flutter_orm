import 'package:flutter_orm/converter/base_converter.dart';
import 'package:flutter_orm/converter/bool_converter.dart';
import 'package:flutter_orm/converter/date_time_converter.dart';
import 'package:flutter_orm/converter/double_converter.dart';
import 'package:flutter_orm/converter/nullable_bool_converter.dart';
import 'package:flutter_orm/converter/nullable_date_time_converter.dart';
import 'package:flutter_orm/converter/nullable_double_converter.dart';

class BuiltInSupportConvertersHelper {
  static final Map<String, String> _builtInSupportSqliteType = {
    'bool': 'INTEGER NOT NULL',
    'bool?': 'INTEGER',
    'DateTime': 'TEXT NOT NULL',
    'DateTime?': 'TEXT',
    'double': 'REAL NOT NULL',
    'double?': 'REAL',
  };

  static final Map<String, BaseConverter> _builtInSupportConverters = {
    'bool': BoolConverter(),
    'bool?': NullableBoolConverter(),
    'DateTime': DateTimeConverter(),
    'DateTime?': NullableDateTimeConverter(),
    'double': DoubleConverter(),
    'double?': NullableDoubleConverter(),
  };

  static bool isBuiltInSupport(String dartType) {
    return _builtInSupportConverters.keys.contains(dartType);
  }

  static String? getProperSqliteType(String dartType) {
    return _builtInSupportSqliteType[dartType];
  }

  static dynamic to(String type, value) {
    return _builtInSupportConverters[type]?.to(value);
  }

  static dynamic from(String type, value) {
    return _builtInSupportConverters[type]?.from(value);
  }
}

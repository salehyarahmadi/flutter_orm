import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/converter/bool_converter.dart';
import 'package:flutter_orm/converter/built_in_support_converters_helper.dart';
import 'package:flutter_orm/converter/date_time_converter.dart';
import 'package:flutter_orm/converter/double_converter.dart';
import 'package:flutter_orm/converter/nullable_bool_converter.dart';
import 'package:flutter_orm/converter/nullable_date_time_converter.dart';
import 'package:flutter_orm/converter/nullable_double_converter.dart';

/// Base class for defining a new type converter.
/// This class is only for define built-in type support.
/// Users also can define their desired converter by [TypeConverter]
/// annotation.
/// You have to convert types that don't support in sqlite internally
/// like bool, double, DateTime and etc.
/// [TO] must be a type that is supported by sqlite like int, String and etc.
/// After implement class, you have to add your converter in
/// [_builtInSupportSqliteType] and [_builtInSupportConverters] variables
/// in [PredefinedConvertersHelper] class.
/// Example:
/// ```dart
/// class BoolConverter implements BaseConverter<bool, int> {
///   @override
///   int from(bool value) {
///     return value ? 1 : 0;
///   }
///
///   @override
///   bool to(int value) {
///     return value == 1;
///   }
/// }
/// ```
/// Pre defined converters:
/// [BoolConverter], [NullableBoolConverter],
/// [DoubleConverter], [NullableDoubleConverter],
/// [DateTimeConverter], [NullableDateTimeConverter].
/// You can define [bool], [double] and [DateTime] fields
/// in your entities directly.
abstract class BaseConverter<FROM, TO> {
  FROM to(TO value);

  TO from(FROM value);
}

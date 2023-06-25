import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/converter/built_in_support_converters_helper.dart';
import 'package:flutter_orm_generator/extensions/general_extensions.dart';
import 'package:flutter_orm_generator/utils/constants.dart';
import 'package:source_gen/source_gen.dart';

const _entityChecker = TypeChecker.fromRuntime(Entity);

extension DartTypeExtension on DartType {
  bool isBuiltInType() {
    return builtInTypes.keys.contains(toString());
  }

  bool isNotBuiltInType() {
    return !isBuiltInType();
  }

  bool isPredefinedConverterType() {
    return PredefinedConvertersHelper.isPredefinedConverterType(toString());
  }

  bool isNullable() {
    return getDisplayString(withNullability: true).contains('?');
  }

  bool isNotNullable() {
    return !isNullable();
  }

  bool isFutureNullableInt() {
    return getDisplayString(withNullability: true) == 'Future<int?>';
  }

  bool isFutureVoid() {
    return getDisplayString(withNullability: true) == 'Future<void>';
  }

  bool isFutureRawData() {
    return getDisplayString(withNullability: true) == 'Future<RawData>' ||
        getDisplayString(withNullability: true) == 'Future<RawData?>';
  }

  String nameWithNullable() {
    return getDisplayString(withNullability: true);
  }

  String nameWithoutNullable() {
    return getDisplayString(withNullability: false);
  }

  bool isNotFuture() {
    return !(getDisplayString(withNullability: true).startsWith('Future'));
  }

  bool containList() {
    return getDisplayString(withNullability: true).contains('List');
  }

  bool containVoid() {
    return getDisplayString(withNullability: true).contains('void');
  }

  bool containMap() {
    return getDisplayString(withNullability: true).contains('Map');
  }

  String futureType() {
    String displayName = getDisplayString(withNullability: true);
    String returnType = displayName.substring(
        displayName.indexOf('Future<') + 7, displayName.lastIndexOf('>'));
    return returnType;
  }

  bool isEntity(ClassElement dbClass) {
    if (element == null) return false;
    if (!_entityChecker.hasAnnotationOfExact(element!)) {
      return false;
    }
    return toString().isEntity(dbClass);
  }

  bool isListOfEntity(ClassElement dbClass) {
    if (element == null) return false;
    return toString().isListOfEntity(dbClass);
  }

  bool isSqfliteDatabase() {
    return this.nameWithNullable() == 'Database';
  }

  String getNullable() {
    if (this.isNullable()) return this.nameWithNullable();
    return this.nameWithoutNullable() + '?';
  }
}

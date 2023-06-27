import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/extensions/string_extensions.dart';
import 'package:flutter_orm_generator/utils/common.dart';
import 'package:flutter_orm_generator/utils/constants.dart';
import 'package:source_gen/source_gen.dart';
import 'extensions.dart';

const _primaryKeyChecker = TypeChecker.fromRuntime(PrimaryKey);
const _columnChecker = TypeChecker.fromRuntime(Column);
const _embeddedChecker = TypeChecker.fromRuntime(Embedded);

extension FieldElementExtension on FieldElement {
  String getColumnName() {
    if (_primaryKeyChecker.hasAnnotationOfExact(this)) {
      return getStringFieldFromAnnotation(PrimaryKey, PrimaryKey.fields.name) ??
          name;
    }
    if (_columnChecker.hasAnnotationOfExact(this)) {
      return getStringFieldFromAnnotation(Column, Column.fields.name) ?? name;
    }
    return name;
  }

  bool isEmbeddedField() {
    return _embeddedChecker.hasAnnotationOfExact(this);
  }

  String getEmbeddedColumnName(ClassElement entityClass, {String prefix = ''}) {
    for (var f in entityClass.fields) {
      String name = prefix.appendUnderscoreIfNotEmpty() + f.getColumnName();
      if (f.id == this.id) {
        return name;
      } else {
        if (f.isEmbeddedField()) {
          String temp = getEmbeddedColumnName(
            f.type.element as ClassElement,
            prefix: prefix.appendUnderscoreIfNotEmpty() +
                (f.getStringFieldFromAnnotation(
                        Embedded, Embedded.fields.prefix) ??
                    f.name),
          );
          if (temp.isNotEmpty) return temp;
        }
      }
    }
    return '';
  }

  String getLocationInObj(
    ClassElement entityClass,
    String entityParameterName,
  ) {
    return entityParameterName + '.' + _getLocationInObj(entityClass, this);
  }

  String _getLocationInObj(
    ClassElement clazz,
    FieldElement field, {
    String prevLocation = '',
  }) {
    for (var f in clazz.fields) {
      if (f.id == field.id) {
        return prevLocation + f.name;
      }
      if (f.isEmbeddedField()) {
        String temp = _getLocationInObj(
          f.type.element as ClassElement,
          field,
          prevLocation:
              prevLocation + f.name + (f.type.isNullable() ? '?.' : '.'),
        );
        if (temp.isNotEmpty) return temp;
      }
    }
    return '';
  }

  String toJsonPair(ClassElement entityClass, String entityParameterName) {
    String fieldLocation =
        this.getLocationInObj(entityClass, entityParameterName);

    String fieldType = this.type.toString() +
        ((!this.type.isNullable() && fieldLocation.contains('?')) ? '?' : '');

    String columnName = this.getEmbeddedColumnName(entityClass);

    String value = '';
    if (this.type.isBuiltInType()) {
      value = fieldLocation;
    } else if (this.type.isPredefinedConverterType()) {
      value =
          "$predefinedConvertersHelperClassName.from('$fieldType', $fieldLocation)";
    } else {
      bool isNullable = this.type.isNullable() || fieldLocation.contains('?');
      String fieldTypeName = this.type.getDisplayString(withNullability: false);
      value =
          '$convertersHelperClassName.from${isNullable ? 'Nullable' : ''}$fieldTypeName($fieldLocation)';
    }
    return jsonPair(key: columnName, value: value);
  }

  String toObjPair(
    ClassElement entityClass, {
    String jsonParameterName = 'data',
  }) {
    String name = this.getEmbeddedColumnName(entityClass);

    String value = '';
    if (this.type.isBuiltInType()) {
      value = '$jsonParameterName[\'$name\'] as ${this.type.toString()}';
    } else if (this.type.isPredefinedConverterType()) {
      value =
          "$predefinedConvertersHelperClassName.to('${this.type.toString()}', $jsonParameterName['$name'])";
    } else {
      bool isNullable = this.type.isNullable();
      String fieldTypeName = this.type.nameWithoutNullable();
      value =
          '$convertersHelperClassName.to${isNullable ? 'Nullable' : ''}$fieldTypeName($jsonParameterName[\'$name\'])';
    }

    return objPair(
      key: this.name,
      value: value,
    );
  }

  bool hasAnyNullablePrefix(ClassElement entityClass) =>
      getLocationInObj(entityClass, '').contains('?');
}

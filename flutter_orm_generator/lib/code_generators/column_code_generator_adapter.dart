import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/field/is_eligible_for_embedded_validator.dart';

class ColumnCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  late ClassElement entityClass;

  ColumnCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    entityClass = element as ClassElement;
    return _generate(entityClass);
  }

  String _generate(ClassElement clazz) {
    List<FieldElement> fields = clazz.getInsertableFields();
    List<String> queries = [];
    for (var field in fields) {
      if (field.isEmbeddedField()) {
        _validation(field);
        queries.add(_generate(field.type.element as ClassElement));
        continue;
      }
      String name = field.getEmbeddedColumnName(entityClass);
      bool isNullable = field.hasAnyNullablePrefix(entityClass);
      String columnType =
          isNullable ? field.type.getNullable() : field.type.toString();
      String sqliteType = dbClass.getProperSqliteType(columnType);
      String defaultValue = _defaultValueQuery(field);
      queries.add("$name $sqliteType $defaultValue");
    }

    return queries.join(",\n\t");
  }

  _validation(FieldElement embeddedField) {
    IsEligibleForEmbeddedValidator(dbClass).check(embeddedField);
  }

  String _defaultValueQuery(FieldElement field) {
    const _DEFAULT = 'DEFAULT';
    String? defaultValue =
        field.getStringFieldFromAnnotation(Column, Column.fields.defaultValue);

    if (defaultValue == null) return '';

    if (field.type.isDartCoreString)
      return "$_DEFAULT '$defaultValue'";
    else
      return "$_DEFAULT $defaultValue";
  }
}

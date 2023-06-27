import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/utils/common.dart';
import 'package:flutter_orm_generator/validation/class/has_valid_primary_key_validator.dart';
import 'package:flutter_orm_generator/validation/class/is_entity_validator.dart';
import 'package:flutter_orm_generator/validation/element/is_class_validator.dart';
import 'package:flutter_orm_generator/validation/element/null_check_validator.dart';

class EntityToJsonCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  late ClassElement entityClass;
  static const _entityParameterName = 'entity';

  EntityToJsonCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    _validation(element);
    entityClass = element as ClassElement;
    String entityClassName = entityClass.displayName;

    String jsonFields = '';
    jsonFields += _pkField();
    jsonFields += _columnFields(entityClass);

    return '''
static Map<String, Object?> toJson($entityClassName $_entityParameterName) {
  return {
    $jsonFields
  };
}
''';
  }

  _validation(Element? element) {
    NullCheckValidator()
        .then(IsClassValidator())
        .then(IsEntityValidator(dbClass))
        .then(HasValidPrimaryKeyValidator())
        .check(element);
  }

  String _pkField() {
    String result = '';
    FieldElement pkField = entityClass.findPrimaryKey();
    bool pkIsAutoIncrement = pkField.getBoolFieldFromAnnotation(
            PrimaryKey, PrimaryKey.fields.autoGenerate) ??
        false;
    if (!pkIsAutoIncrement) {
      String pkColumnName = pkField.getColumnName();
      result += jsonPair(
        key: pkColumnName,
        value: '$_entityParameterName.${pkField.name}',
      );
    }
    return result;
  }

  String _columnFields(ClassElement clazz) {
    String result = '';
    List<FieldElement> columns = clazz.getInsertableFields();
    for (var field in columns) {
      if (field.isEmbeddedField()) {
        result += _columnFields(field.type.element as ClassElement);
        continue;
      }
      result += field.toJsonPair(entityClass, _entityParameterName);
    }
    return result;
  }
}

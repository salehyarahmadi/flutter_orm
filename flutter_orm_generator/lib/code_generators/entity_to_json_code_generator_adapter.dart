import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/utils/constants.dart';
import 'package:flutter_orm_generator/validation/class/has_valid_primary_key_validator.dart';

class EntityToJsonCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  EntityToJsonCodeGeneratorAdapter(this.dbClass);

  static const _entityParameterName = 'entity';

  @override
  String generate(Element? element) {
    ClassElement entityClass = element as ClassElement;
    String entityClassName = entityClass.displayName;

    String jsonFields = '';
    jsonFields += _pkField(entityClass);
    jsonFields += _columnFields(entityClass);

    return '''
static Map<String, Object?> toJson($entityClassName $_entityParameterName) {
  return {
    $jsonFields
  };
}
''';
  }

  String _pkField(ClassElement entityClass) {
    String result = '';
    HasValidPrimaryKeyValidator().check(entityClass);
    FieldElement pkField = entityClass.findPrimaryKey();
    bool pkIsAutoIncrement = pkField.getBoolFieldFromAnnotation(
            PrimaryKey, PrimaryKey.fields.autoGenerate) ??
        false;
    if (!pkIsAutoIncrement) {
      String pkColumnName = pkField.getColumnName();
      result += '\'$pkColumnName\' : $_entityParameterName.${pkField.name},\n';
    }
    return result;
  }

  String _columnFields(
    ClassElement entityClass, {
    bool entityCheck = true,
    String prevFieldName = '',
    String prevPrefix = '',
  }) {
    String result = '';
    List<FieldElement> columns =
        entityClass.getColumnsForTable(entityCheck: entityCheck);
    for (var field in columns) {
      String columnName = prevPrefix +
          (prevPrefix.isNotEmpty ? '_' : '') +
          field.getColumnName();

      if (field.isEmbeddedField()) {
        result += _columnFields(field.type.element as ClassElement,
            entityCheck: false,
            prevFieldName: prevFieldName +
                (prevFieldName.isNotEmpty ? '.' : '') +
                field.name +
                (field.type.isNullable() ? '?' : ''),
            prevPrefix: prevPrefix +
                (prevPrefix.isNotEmpty ? '_' : '') +
                (field.getStringFieldFromAnnotation(
                        Embedded, Embedded.fields.prefix) ??
                    field.name));
        continue;
      }

      String fieldLocation = _entityParameterName +
          '.' +
          prevFieldName +
          (prevFieldName.isNotEmpty ? '.' : '') +
          field.name;

      String fieldType = field.type.toString() +
          ((!field.type.isNullable() && fieldLocation.contains('?'))
              ? '?'
              : '');

      if (field.type.isBuiltInType()) {
        result += '\'$columnName\' : $fieldLocation,\n';
      } else if (field.type.isPredefinedConverterType()) {
        result +=
            "'$columnName' : $predefinedConvertersHelperClassName.from('$fieldType', $fieldLocation),\n";
      } else {
        bool isNullable =
            field.type.isNullable() || fieldLocation.contains('?');
        String fieldTypeName =
            field.type.getDisplayString(withNullability: false);
        result +=
            '\'$columnName\' : $convertersHelperClassName.from${isNullable ? 'Nullable' : ''}$fieldTypeName($fieldLocation),\n';
      }
    }
    return result;
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/utils/constants.dart';
import 'package:flutter_orm/validation/class/has_valid_primary_key_validator.dart';

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

  String _columnFields(ClassElement entityClass) {
    String result = '';
    List<FieldElement> columns = entityClass.getColumnsForTable();
    for (var field in columns) {
      String columnName = field.getColumnName();
      if (field.type.isBuiltIn()) {
        result += '\'$columnName\' : $_entityParameterName.${field.name},\n';
      } else if (field.type.isBuiltInSupport()) {
        result +=
            "'$columnName' : $builtInSupportConvertersHelperClassName.from('${field.type.toString()}', $_entityParameterName.${field.name}),\n";
      } else {
        bool isNullable = field.type.toString().contains('?');
        String fieldTypeName =
            field.type.getDisplayString(withNullability: false);
        result +=
            '\'$columnName\' : $convertersHelperClassName.from${isNullable ? 'Nullable' : ''}$fieldTypeName($_entityParameterName.${field.name}),\n';
      }
    }
    return result;
  }
}

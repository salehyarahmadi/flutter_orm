import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/utils/constants.dart';

class EntityFromJsonCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  EntityFromJsonCodeGeneratorAdapter(this.dbClass);

  static const _jsonParameterName = 'data';

  @override
  String generate(Element? element) {
    ClassElement entityClass = element as ClassElement;
    String entityClassName = entityClass.displayName;

    return '''
static $entityClassName fromJson(Map<String, Object?> $_jsonParameterName) {
  return $entityClassName(
    ${_generateJsonFromEntity(entityClass)}
  );
}
''';
  }

  String _generateJsonFromEntity(ClassElement entityClass) {
    String result = '';
    for (var field in entityClass.getColumnsForTable(includePrimaryKey: true)) {
      String name = field.getColumnName();

      if (field.type.isBuiltIn()) {
        result +=
            '${field.name}: $_jsonParameterName[\'$name\'] as ${field.type.toString()},\n';
      } else if (field.type.isBuiltInSupport()) {
        result +=
            "${field.name}: $builtInSupportConvertersHelperClassName.to('${field.type.toString()}', $_jsonParameterName['$name']),\n";
      } else {
        bool isNullable = field.type.isNullable();
        String fieldTypeName = field.type.nameWithoutNullable();
        result +=
            '${field.name}: $convertersHelperClassName.to${isNullable ? 'Nullable' : ''}$fieldTypeName($_jsonParameterName[\'$name\']),\n';
      }
    }
    return result;
  }
}

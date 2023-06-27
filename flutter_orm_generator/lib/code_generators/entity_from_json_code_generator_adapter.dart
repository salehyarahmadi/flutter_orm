import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/utils/common.dart';

class EntityFromJsonCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  late ClassElement entityClass;
  static const _jsonParameterName = 'data';
  List<String> _embeddedFieldsFromJsonMethods = [];

  EntityFromJsonCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    entityClass = element as ClassElement;
    String entityClassName = entityClass.displayName;

    return '''
static $entityClassName fromJson(Map<String, Object?> $_jsonParameterName) {
  return $entityClassName(
    ${_generateEntityFromJson(entityClass)}
  );
}

${_embeddedFieldsFromJsonMethods.join('\n')}

''';
  }

  String _generateEntityFromJson(ClassElement clazz) {
    List<FieldElement> fields = clazz.getFields();

    String result = '';
    for (var field in fields) {
      if (field.isEmbeddedField()) {
        result += objPair(
          key: field.name,
          value:
              '${field.name}FromJson($_jsonParameterName)${field.type.isNullable() ? '' : '!'}',
        );
        _embeddedFieldsFromJsonMethods
            .add(_generateMethodForEmbeddedField(field));
      } else {
        result += field.toObjPair(
          entityClass,
          jsonParameterName: _jsonParameterName,
        );
      }
    }

    return result;
  }

  String _generateMethodForEmbeddedField(FieldElement embeddedField) {
    return '''
static ${embeddedField.type.nameWithoutNullable()}? ${embeddedField.name}FromJson(Map<String, Object?> $_jsonParameterName) {
${(embeddedField.type.element as ClassElement).fields.map((f) {
      if (f.type.isNullable()) return '';
      if (f.isEmbeddedField())
        return 'if (${f.name}FromJson($_jsonParameterName) == null) return null;';
      else
        return 'if ($_jsonParameterName[\'${f.getEmbeddedColumnName(entityClass)}\'] == null) return null;';
    }).join('\n')}

  
  return ${embeddedField.type.nameWithoutNullable()}(
    ${_generateEntityFromJson(embeddedField.type.element as ClassElement)}
  );
}
''';
  }
}

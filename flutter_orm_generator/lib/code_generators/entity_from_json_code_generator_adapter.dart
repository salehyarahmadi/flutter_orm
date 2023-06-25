import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/utils/constants.dart';

class EntityFromJsonCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  EntityFromJsonCodeGeneratorAdapter(this.dbClass);

  static const _jsonParameterName = 'data';

  List<String> _methods = [];

  @override
  String generate(Element? element) {
    ClassElement entityClass = element as ClassElement;
    String entityClassName = entityClass.displayName;

    return '''
static $entityClassName fromJson(Map<String, Object?> $_jsonParameterName) {
  return $entityClassName(
    ${_structure(entityClass)}
  );
}

${_methods.join('\n')}

''';
  }

  String _structure(ClassElement clazz, {String prefix = ''}) {
    List<FieldElement> fields = clazz.getColumnsForTable(
      includePrimaryKey: true,
      entityCheck: false,
    );

    String result = '';
    for (var field in fields) {
      if (field.isEmbeddedField()) {
        result +=
            '${field.name}: ${field.name}FromJson($_jsonParameterName)${field.type.isNullable() ? '' : '!'},\n';
        _methods
            .add(_generateMethodForEmbeddedField(field, prevPrefix: prefix));
      } else {
        result += _generateConvertForField(field, prefix);
      }
    }

    return result;
  }

  String _generateConvertForField(FieldElement field, String prefix) {
    String name =
        prefix + (prefix.isNotEmpty ? '_' : '') + field.getColumnName();

    if (field.type.isBuiltInType()) {
      return '${field.name}: $_jsonParameterName[\'$name\'] as ${field.type.toString()},\n';
    } else if (field.type.isPredefinedConverterType()) {
      return "${field.name}: $predefinedConvertersHelperClassName.to('${field.type.toString()}', $_jsonParameterName['$name']),\n";
    } else {
      bool isNullable = field.type.isNullable();
      String fieldTypeName = field.type.nameWithoutNullable();
      return '${field.name}: $convertersHelperClassName.to${isNullable ? 'Nullable' : ''}$fieldTypeName($_jsonParameterName[\'$name\']),\n';
    }
  }

  String _generateMethodForEmbeddedField(FieldElement embeddedField,
      {String prevPrefix = ''}) {
    String prefix = prevPrefix +
        (prevPrefix.isNotEmpty ? '_' : '') +
        (embeddedField.getStringFieldFromAnnotation(
                Embedded, Embedded.fields.prefix) ??
            embeddedField.name);

    return '''
static ${embeddedField.type.nameWithoutNullable()}? ${embeddedField.name}FromJson(Map<String, Object?> $_jsonParameterName) {
${(embeddedField.type.element as ClassElement).fields.map((f) {
      if (f.type.isNullable()) return '';
      if (f.isEmbeddedField())
        return 'if (${f.name}FromJson($_jsonParameterName) == null) return null;';
      else
        return 'if (data[\'${prefix}${prefix.isNotEmpty ? '_' : ''}${f.getColumnName()}\'] == null) return null;';
    }).join('\n')}

  
  return ${embeddedField.type.nameWithoutNullable()}(
    ${_structure(embeddedField.type.element as ClassElement, prefix: prefix)}
  );
}
''';
  }
}

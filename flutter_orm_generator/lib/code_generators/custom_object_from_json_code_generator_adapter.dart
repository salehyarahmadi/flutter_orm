import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/utils/constants.dart';

class CustomObjectFromJsonCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final String jsonParameterName;

  CustomObjectFromJsonCodeGeneratorAdapter(this.jsonParameterName);

  @override
  String generate(Element? element) {
    ClassElement customObjectClass = element as ClassElement;
    String customObjectClassName = customObjectClass.displayName;

    return '''
  $customObjectClassName(
    ${_generateCustomObject(customObjectClass)}
  )
''';
  }

  String _generateCustomObject(ClassElement customObjectClass) {
    String result = '';
    for (var field in customObjectClass.getCustomObjectFields()) {
      String name = field.getColumnName();

      if (field.type.isBuiltInType()) {
        result +=
            '${field.name}: $jsonParameterName[\'$name\'] as ${field.type.toString()},\n';
      } else if (field.type.isPredefinedConverterType()) {
        result +=
            "${field.name}: $predefinedConvertersHelperClassName.to('${field.type.toString()}', $jsonParameterName['$name']),\n";
      } else {
        bool isNullable = field.type.isNullable();
        String fieldTypeName = field.type.nameWithoutNullable();
        result +=
            '${field.name}: $convertersHelperClassName.to${isNullable ? 'Nullable' : ''}$fieldTypeName($jsonParameterName[\'$name\']),\n';
      }
    }
    return result;
  }
}

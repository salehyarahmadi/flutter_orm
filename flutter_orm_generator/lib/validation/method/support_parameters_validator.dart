import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class SupportParametersValidator extends ElementValidator<MethodElement> {
  final ClassElement dbClass;
  String? message;

  SupportParametersValidator(this.dbClass, {this.message});

  @override
  check(MethodElement element) {
    for (var parameter in element.parameters) {
      String typeName = parameter.type.isDartCoreList
          ? parameter.type
              .toString()
              .substring(5, parameter.type.toString().lastIndexOf('>'))
          : parameter.type.toString();
      if (typeName.isBuiltInType()) continue;

      if (typeName.isPredefinedConverterType()) continue;

      if (dbClass.getUserDefinedConvertibleTypes().keys.contains(typeName)) {
        continue;
      }

      throw Exception("${element.name}: "
          "${parameter.type.toString()} type doesn't support");
    }
    checkNext(element);
  }
}

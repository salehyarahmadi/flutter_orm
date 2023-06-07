import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/validator.dart';


class RawQueryMethodParametersValidator extends ElementValidator<MethodElement> {
  final ClassElement dbClass;
  String? message;

  RawQueryMethodParametersValidator(this.dbClass, {this.message});

  @override
  check(MethodElement element) {
    for (var parameter in element.parameters) {
      String typeName = parameter.type.isDartCoreList
          ? parameter.type
              .toString()
              .substring(5, parameter.type.toString().lastIndexOf('>'))
          : parameter.type.toString();
      if (typeName.isBuiltIn()) continue;

      if (typeName.isBuiltInSupport()) continue;

      if (dbClass.getUserDefinedConvertibleTypes().keys.contains(typeName)) {
        continue;
      }

      throw Exception("${element.name}: "
          "${parameter.type.toString()} type doesn't support");
    }
    checkNext(element);
  }
}

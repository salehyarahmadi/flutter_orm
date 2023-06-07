import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/validator.dart';

class BuiltInParametersValidator extends ElementValidator<MethodElement> {
  String? message;

  BuiltInParametersValidator({this.message});

  @override
  check(MethodElement element) {
    for (var parameter in element.parameters) {
      if (parameter.type.isNotBuiltIn()) {
        throw Exception(message ??
            '${element.name}: raw query method parameters must be built-in type');
      }
    }
    checkNext(element);
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/validation/validator.dart';

class IsAllParametersPositionalValidator
    extends ElementValidator<MethodElement> {
  String? message;

  IsAllParametersPositionalValidator({this.message});

  @override
  check(MethodElement element) {
    for (var parameter in element.parameters) {
      if (parameter.isNamed || parameter.isOptionalNamed) {
        throw Exception(
            'method: `${element.name}` parameter: `${parameter.name}`, '
            '${element.name} method cannot have named parameter');
      }
    }
    checkNext(element);
  }
}

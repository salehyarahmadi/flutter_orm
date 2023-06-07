import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_orm/validation/validator.dart';

class MethodParameterValidator extends ElementValidator<MethodElement> {
  final int index;
  final bool Function(DartType type) validator;
  final String message;

  MethodParameterValidator(this.index, this.validator, this.message);

  @override
  check(MethodElement element) {
    if (element.parameters.length <= index || index < 0) {
      throw Exception(
          'index $index is out of range in parameters of ${element.name} method');
    }
    if (!(validator.call(element.parameters[index].type))) {
      throw Exception(message);
    }
    checkNext(element);
  }
}

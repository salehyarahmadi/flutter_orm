import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class MethodReturnTypeValidator extends ElementValidator<MethodElement> {
  final bool Function(DartType type) validator;
  final String message;

  MethodReturnTypeValidator(this.validator, this.message);

  @override
  check(MethodElement element) {
    if (!(validator.call(element.returnType))) {
      throw Exception(message);
    }
    checkNext(element);
  }
}

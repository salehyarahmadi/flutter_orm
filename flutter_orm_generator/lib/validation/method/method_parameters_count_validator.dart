import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class MethodParametersCountValidator extends ElementValidator<MethodElement> {
  final int count;
  String? message;

  MethodParametersCountValidator(this.count, {this.message});

  @override
  check(MethodElement element) {
    if (element.parameters.length != count) {
      throw Exception(
          message ?? '${element.name} method must has $count parameter(s)');
    }
    checkNext(element);
  }
}

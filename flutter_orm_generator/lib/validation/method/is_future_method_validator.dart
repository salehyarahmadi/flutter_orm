import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class IsFutureMethodValidator extends ElementValidator<MethodElement> {
  String? message;

  IsFutureMethodValidator({this.message});

  @override
  check(MethodElement element) {
    if (!element.returnType.isDartAsyncFuture) {
      throw Exception(message ?? '${element.name} return type must be future');
    }
    checkNext(element);
  }
}

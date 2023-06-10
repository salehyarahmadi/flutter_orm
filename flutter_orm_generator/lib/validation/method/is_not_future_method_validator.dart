import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class IsNotFutureMethodValidator extends ElementValidator<MethodElement> {
  String? message;

  IsNotFutureMethodValidator({this.message});

  @override
  check(MethodElement element) {
    if (element.returnType.isDartAsyncFuture ||
        element.returnType.isDartAsyncFutureOr) {
      throw Exception(
          message ?? '${element.name} return type cannot be future');
    }
    checkNext(element);
  }
}

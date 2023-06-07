import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/validation/validator.dart';

class IsStaticMethodValidator extends ElementValidator<MethodElement> {
  String? message;

  IsStaticMethodValidator({this.message});

  @override
  check(MethodElement element) {
    if (!element.isStatic) {
      throw Exception(message ?? '${element.name} method must be static');
    }
    checkNext(element);
  }
}

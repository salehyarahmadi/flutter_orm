import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/validation/validator.dart';

class IsAbstractClassValidator extends ElementValidator<ClassElement> {
  String? message;

  IsAbstractClassValidator({this.message});

  @override
  check(ClassElement element) {
    if (!element.isAbstract) {
      throw Exception(message ?? '${element.name} must be abstract class');
    }
    checkNext(element);
  }
}

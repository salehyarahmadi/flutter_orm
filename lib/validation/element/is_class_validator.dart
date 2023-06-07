import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/validation/validator.dart';

class IsClassValidator extends ElementValidator<Element> {
  String? message;

  IsClassValidator({this.message});

  @override
  check(Element element) {
    if (element is! ClassElement) {
      throw Exception(message ?? '${element.name} must be class');
    }
    checkNext(element);
  }
}

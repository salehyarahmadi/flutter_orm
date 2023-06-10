import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class NullCheckValidator extends ElementValidator {
  String? message;

  NullCheckValidator({this.message});

  @override
  check(Element? element) {
    if (element == null) {
      throw Exception(message ?? 'element cannot be null');
    }
    checkNext(element);
  }
}

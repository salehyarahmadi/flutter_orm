import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/validation/validator.dart';

class HasNamedParametersDefaultConstructorValidator
    extends ElementValidator<ClassElement> {
  String? message;

  HasNamedParametersDefaultConstructorValidator({this.message});

  @override
  check(ClassElement element) {
    bool isConstructorWithNamedParametersFound = false;
    for (var constructor in (element.constructors)) {
      if (constructor.name.isNotEmpty) {
        continue;
      }
      bool isAllParametersNamed = true;
      for (var parameter in constructor.parameters) {
        if (!parameter.isNamed) {
          isAllParametersNamed = false;
          break;
        }
      }
      if (isAllParametersNamed) {
        isConstructorWithNamedParametersFound = true;
        break;
      }
    }
    if (!isConstructorWithNamedParametersFound) {
      throw Exception(message ??
          'default constructor with named parameters '
              'is required in class: ${element.name}');
    }
    checkNext(element);
  }
}

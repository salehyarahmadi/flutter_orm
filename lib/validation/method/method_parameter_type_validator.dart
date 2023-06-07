import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/validation/validator.dart';

class MethodParameterTypeValidator extends ElementValidator<MethodElement> {
  final int index;
  final String typeName;
  String? message;

  MethodParameterTypeValidator(this.index, this.typeName, {this.message});

  @override
  check(MethodElement element) {
    if (element.parameters.length <= index || index < 0) {
      throw Exception(
          'index $index is out of range in parameters of ${element.name} method');
    }
    if (element.parameters[index].type.toString() != typeName) {
      throw Exception(message ??
          '${element.name} parameter type mismatch for '
              'index: $index and '
              'type: ${element.parameters[index].type.toString()}. '
              'correct type is $typeName');
    }
    checkNext(element);
  }
}

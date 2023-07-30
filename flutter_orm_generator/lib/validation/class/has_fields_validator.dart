import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class HasFieldsValidator extends ElementValidator<ClassElement> {
  final List<String> fieldsName;

  HasFieldsValidator({required this.fieldsName});

  @override
  check(ClassElement element) {
    List<String> classFields = element.fields.map((e) => e.name).toList();
    for (var fieldName in fieldsName) {
      if (!classFields.contains(fieldName)) {
        throw Exception("${element.name} doesn't have `$fieldName` field");
      }
    }
    checkNext(element);
  }
}

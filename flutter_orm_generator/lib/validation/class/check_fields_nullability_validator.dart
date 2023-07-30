import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class CheckFieldsNullabilityValidator extends ElementValidator<ClassElement> {
  final List<String> fieldsName;

  CheckFieldsNullabilityValidator({required this.fieldsName});

  @override
  check(ClassElement element) {
    List<FieldElement> entityFields = element.fields;
    List<String> entityFieldsName = entityFields.map((e) => e.name).toList();
    for (var fieldName in fieldsName) {
      if (!entityFieldsName.contains(fieldName)) {
        throw Exception("${element.name} doesn't have `$fieldName` field");
      }
      FieldElement f = entityFields.firstWhere((e) => e.name == fieldName);
      if (f.type.isNotNullable()) {
        throw Exception("${element.name}: `$fieldName` must be nullable");
      }
    }
    checkNext(element);
  }
}

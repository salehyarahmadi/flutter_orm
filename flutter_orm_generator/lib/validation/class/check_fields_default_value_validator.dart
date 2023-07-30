import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/validator.dart';
import 'package:source_gen/source_gen.dart';

const _columnChecker = TypeChecker.fromRuntime(Column);

class CheckFieldsDefaultValueValidator extends ElementValidator<ClassElement> {
  final List<String> fieldsName;

  CheckFieldsDefaultValueValidator({required this.fieldsName});

  @override
  check(ClassElement element) {
    List<FieldElement> entityFields = element.fields;
    List<String> entityFieldsName = entityFields.map((e) => e.name).toList();
    for (var fieldName in fieldsName) {
      if (!entityFieldsName.contains(fieldName)) {
        throw Exception("${element.name} doesn't have `$fieldName` field");
      }

      FieldElement f = entityFields.firstWhere((e) => e.name == fieldName);
      if (!_columnChecker.hasAnnotationOfExact(f)) {
        throw Exception("${element.name}: `$fieldName` must have "
            "default value using @Column annotation");
      }
      String? defaultValue =
          f.getStringFieldFromAnnotation(Column, Column.fields.defaultValue);
      if (defaultValue == null) {
        throw Exception("${element.name}: `$fieldName` must have "
            "default value using @Column annotation");
      }
    }
    checkNext(element);
  }
}

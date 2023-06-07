import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/validator.dart';
import 'package:source_gen/source_gen.dart';

const _primaryKeyChecker = TypeChecker.fromRuntime(PrimaryKey);

class HasValidPrimaryKeyValidator extends ElementValidator<ClassElement> {
  String? message;

  HasValidPrimaryKeyValidator({this.message});

  @override
  check(ClassElement element) {
    FieldElement? pkField;
    int count = 0;
    for (var field in element.fields) {
      if (_primaryKeyChecker.hasAnnotationOfExact(field)) {
        count++;
        pkField = field;
      }
    }
    if (count != 1) {
      throw Exception(
          message ?? '${element.name} must has exactly one primary key');
    }

    bool autoIncrement = pkField!.getBoolFieldFromAnnotation(
            PrimaryKey, PrimaryKey.fields.autoGenerate) ??
        false;
    if (autoIncrement && !pkField.type.isDartCoreInt) {
      throw Exception('error in ${element.name}: '
          'only integer primary key can be auto increment');
    }
    if (autoIncrement &&
        !pkField.type.getDisplayString(withNullability: true).contains('?')) {
      throw Exception('error in ${element.name}: '
          'auto increment primary key must be nullable');
    }
    if (!autoIncrement &&
        pkField.type.getDisplayString(withNullability: true).contains('?')) {
      throw Exception('error in ${element.name}: '
          'primary key cannot be nullable');
    }

    checkNext(element);
  }
}

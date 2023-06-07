import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/validation/validator.dart';
import 'package:source_gen/source_gen.dart';

const _dbChecker = TypeChecker.fromRuntime(DB);

class IsDBValidator extends ElementValidator<ClassElement> {
  String? message;

  IsDBValidator({this.message});

  @override
  check(ClassElement element) {
    if (!_dbChecker.hasAnnotationOfExact(element)) {
      throw Exception(message ?? '${element.name} must have @DB() annotation');
    }
    checkNext(element);
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm/validation/validator.dart';
import 'package:source_gen/source_gen.dart';

const _daoChecker = TypeChecker.fromRuntime(Dao);

class IsDaoValidator extends ElementValidator<ClassElement> {
  String? message;

  IsDaoValidator({this.message});

  @override
  check(ClassElement element) {
    if (!_daoChecker.hasAnnotationOfExact(element)) {
      throw Exception(message ?? '${element.name} must have @Dao() annotation');
    }
    checkNext(element);
  }
}

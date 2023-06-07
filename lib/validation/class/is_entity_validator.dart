import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/validator.dart';
import 'package:source_gen/source_gen.dart';

const _entityChecker = TypeChecker.fromRuntime(Entity);

class IsEntityValidator extends ElementValidator<ClassElement> {
  final ClassElement dbClass;
  String? message;

  IsEntityValidator(this.dbClass, {this.message});

  @override
  check(ClassElement element) {
    if (!_entityChecker.hasAnnotationOfExact(element)) {
      throw Exception(
          message ?? '${element.name} must have @Entity() annotation');
    }
    if (!(dbClass
            .getListFieldFromAnnotation(DB, DB.fields.entities)
            ?.map((e) => e.toTypeValue()?.element?.name)
            .toList()
            .contains(element.name) ??
        false)) {
      throw Exception(message ?? '${element.name} must define inside db class');
    }
    checkNext(element);
  }
}

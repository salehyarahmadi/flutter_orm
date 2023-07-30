import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/enums/foreign_key_action.dart';
import 'package:flutter_orm/utils/foreign_key.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/class/check_fields_default_value_validator.dart';
import 'package:flutter_orm_generator/validation/class/check_fields_nullability_validator.dart';
import 'package:flutter_orm_generator/validation/class/has_fields_validator.dart';
import 'package:flutter_orm_generator/validation/class/is_entity_validator.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class ForeignKeyValidator extends ElementValidator<ClassElement> {
  final ClassElement dbClass;

  ForeignKeyValidator(this.dbClass);

  @override
  check(ClassElement element) {
    List<ForeignKey> foreignKeys = element
            .getListFieldFromAnnotation(Entity, Entity.fields.foreignKeys)
            ?.map((e) => e.convertToForeignKey())
            .toList() ??
        [];

    for (var foreignKey in foreignKeys) {
      if (foreignKey.parentColumns.isEmpty) {
        throw Exception('${element.name}: parentColumns cannot be empty');
      }
      if (foreignKey.childColumns.isEmpty) {
        throw Exception('${element.name}: childColumns cannot be empty');
      }
      if (foreignKey.parentColumns.length != foreignKey.childColumns.length) {
        throw Exception('${element.name}: number of columns specified in '
            'parentColumns must match the number of columns specified in '
            'childColumns.');
      }

      IsEntityValidator(dbClass)
          .then(HasFieldsValidator(fieldsName: foreignKey.parentColumns))
          .check(((foreignKey.entity as DartObject).toTypeValue()?.element
              as ClassElement));
      HasFieldsValidator(fieldsName: foreignKey.childColumns).check(element);

      if (foreignKey.onDelete == ForeignKeyAction.SET_NULL ||
          foreignKey.onUpdate == ForeignKeyAction.SET_NULL) {
        CheckFieldsNullabilityValidator(fieldsName: foreignKey.childColumns)
            .check(element);
      }

      if (foreignKey.onDelete == ForeignKeyAction.SET_DEFAULT ||
          foreignKey.onUpdate == ForeignKeyAction.SET_DEFAULT) {
        CheckFieldsDefaultValueValidator(fieldsName: foreignKey.childColumns)
            .check(element);
      }
    }

    checkNext(element);
  }
}

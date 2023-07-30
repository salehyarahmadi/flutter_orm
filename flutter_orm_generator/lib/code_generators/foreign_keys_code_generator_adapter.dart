import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/enums/foreign_key_action.dart';
import 'package:flutter_orm/utils/foreign_key.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/class/check_fields_default_value_validator.dart';
import 'package:flutter_orm_generator/validation/class/check_fields_nullability_validator.dart';
import 'package:flutter_orm_generator/validation/class/foreign_key_validator.dart';
import 'package:flutter_orm_generator/validation/class/has_fields_validator.dart';
import 'package:flutter_orm_generator/validation/class/is_entity_validator.dart';
import 'package:flutter_orm_generator/validation/element/null_check_validator.dart';

class ForeignKeysCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  late ClassElement entityClass;

  ForeignKeysCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    _validateEntity(element);
    entityClass = element as ClassElement;

    List<ForeignKey> foreignKeys = entityClass
            .getListFieldFromAnnotation(Entity, Entity.fields.foreignKeys)
            ?.map((e) => e.convertToForeignKey())
            .toList() ??
        [];

    _validateForeignKeys();

    if (foreignKeys.isEmpty) return '';

    return foreignKeys.map((fk) => _generateForeignKeyQuery(fk)).join(',');
  }

  String _generateForeignKeyQuery(ForeignKey foreignKey) {
    String? parentTableName = ((foreignKey.entity as DartObject)
            .toTypeValue()
            ?.element as ClassElement)
        .getEntityTableName();

    if (parentTableName.isEmpty) return '';

    return "FOREIGN KEY(${foreignKey.childColumns.join(',')}) "
        "REFERENCES $parentTableName(${foreignKey.parentColumns.join(',')}) "
        "ON DELETE ${foreignKey.onDelete.query()} "
        "ON UPDATE ${foreignKey.onUpdate.query()} "
        "${foreignKey.deferred ? 'DEFERRABLE INITIALLY DEFERRED' : ''}";
  }

  _validateEntity(Element? entityClass) {
    NullCheckValidator().then(IsEntityValidator(dbClass)).check(entityClass);
  }

  _validateForeignKeys() {
    ForeignKeyValidator(dbClass).check(entityClass);
  }
}

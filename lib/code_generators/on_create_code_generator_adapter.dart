import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/class/is_entity_validator.dart';
import 'package:flutter_orm/validation/element/null_check_validator.dart';
import 'package:source_gen/source_gen.dart';

class OnCreateCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;
  final ConstantReader annotation;

  OnCreateCodeGeneratorAdapter(this.dbClass, this.annotation);

  @override
  String generate(Element? element) {
    String onCreate = '';
    onCreate += _generateEntitiesTable(dbClass, annotation);
    if (dbClass.hasOnCreateInterface()) {
      onCreate += '\n';
      onCreate += 'await onCreate(db, version);';
    }
    return onCreate;
  }

  String _generateEntitiesTable(
      ClassElement dbClass, ConstantReader annotation) {
    String entitiesTableQueryBuilder = '';
    entitiesTableQueryBuilder += 'Batch batch = db.batch();';
    annotation.peek(DB.fields.entities)?.listValue.forEach((e) {
      Element? entityElement = e.toTypeValue()?.element;
      NullCheckValidator()
          .then(IsEntityValidator(dbClass))
          .check(entityElement);
      String entityName = e.toTypeValue().toString();
      entityName = entityName.substring(0, entityName.length - 1);
      String query =
          'batch.execute(${entityName.helperClassName()}.queryBuilder());';

      entitiesTableQueryBuilder += query;

      if (entityElement
              .getListFieldFromAnnotation(Entity, Entity.fields.indices)
              ?.isNotEmpty ??
          false) {
        String indicesQuery =
            'batch.execute(${entityName.helperClassName()}.indicesBuilder());';
        entitiesTableQueryBuilder += indicesQuery;
      }
    });
    entitiesTableQueryBuilder += 'await batch.commit();';

    return entitiesTableQueryBuilder;
  }
}

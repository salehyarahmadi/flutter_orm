import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';

class PrimaryKeyCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  PrimaryKeyCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    ClassElement entityClass = element as ClassElement;
    FieldElement pkField = entityClass.findPrimaryKey();
    String name = pkField.getColumnName();
    bool autoIncrement = pkField.getBoolFieldFromAnnotation(
            PrimaryKey, PrimaryKey.fields.autoGenerate) ??
        false;
    return "$name ${dbClass.getProperSqliteType(pkField.type.toString(), forPrimaryKey: true)} PRIMARY KEY ${autoIncrement ? 'AUTOINCREMENT' : ''}";
  }
}

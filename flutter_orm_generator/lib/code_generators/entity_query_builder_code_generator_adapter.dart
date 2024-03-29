import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/column_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/foreign_keys_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/primary_key_code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';

class EntityQueryBuilderCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  EntityQueryBuilderCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    ClassElement entityClass = element as ClassElement;
    String tableName = entityClass.getEntityTableName();

    String pkQuery =
        CodeGeneratorBuilder(PrimaryKeyCodeGeneratorAdapter(dbClass))
            .element(entityClass)
            .generate();

    String columnsQuery =
        CodeGeneratorBuilder(ColumnCodeGeneratorAdapter(dbClass))
            .element(entityClass)
            .generate();

    String foreignKeysQuery =
        CodeGeneratorBuilder(ForeignKeysCodeGeneratorAdapter(dbClass))
            .element(entityClass)
            .generate();

    return '''
static String queryBuilder()  {
  return """
CREATE TABLE $tableName(
  $pkQuery${columnsQuery.isNotEmpty ? ',' : ''}
  $columnsQuery${foreignKeysQuery.isNotEmpty ? ',' : ''}
  $foreignKeysQuery
);
""";
  }
''';
  }
}

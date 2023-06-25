import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/embedded_column_code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';

class ColumnCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;
  final bool entityCheck;
  final String prefix;
  final bool hasAnyNullablePrefix;

  ColumnCodeGeneratorAdapter(
    this.dbClass, {
    this.entityCheck = true,
    this.prefix = '',
    this.hasAnyNullablePrefix = false,
  });

  @override
  String generate(Element? element) {
    ClassElement entityClass = element as ClassElement;
    List<FieldElement> columns =
        entityClass.getColumnsForTable(entityCheck: entityCheck);

    List<String> queries = [];
    for (var column in columns) {
      if (column.isEmbeddedField()) {
        queries.add(CodeGeneratorBuilder(EmbeddedColumnCodeGeneratorAdapter(
          dbClass,
          prevPrefix: prefix,
          hasAnyNullablePrefix:
              hasAnyNullablePrefix || column.type.isNullable(),
        )).element(column).generate());
        continue;
      }
      String name =
          '${prefix}${prefix.isNotEmpty ? '_' : ''}${column.getColumnName()}';

      bool isNullable = column.type.isNullable() || hasAnyNullablePrefix;
      String columnType =
          isNullable ? column.type.getNullable() : column.type.toString();
      queries.add("$name ${dbClass.getProperSqliteType(columnType)}");
    }

    return queries.join(",\n\t");
  }
}

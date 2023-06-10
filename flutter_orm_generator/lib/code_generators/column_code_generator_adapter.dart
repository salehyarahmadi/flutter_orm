import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';


class ColumnCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  ColumnCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    ClassElement entityClass = element as ClassElement;
    List<FieldElement> columns = entityClass.getColumnsForTable();

    List<String> queries = [];
    for (var column in columns) {
      String name = column.getColumnName();
      queries
          .add("$name ${dbClass.getProperSqliteType(column.type.toString())}");
    }

    return queries.join(",\n\t");
  }
}

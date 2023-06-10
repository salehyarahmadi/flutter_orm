import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm/utils/index.dart';

class EntityIndicesQueryBuilderCodeGeneratorAdapter
    extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement entityClass = element as ClassElement;
    String tableName = entityClass.getEntityTableName();

    List<Index>? indices = entityClass
            .getListFieldFromAnnotation(Entity, Entity.fields.indices)
            ?.map((e) => e.convertToTableIndex())
            .toList() ??
        [];

    if (indices.isEmpty) return '';
    _validateIndices(entityClass, tableName, indices);

    return '''
static String indicesBuilder()  {
  return """
    ${indices.map((index) => _generateIndexCreatorQuery(index, tableName)).toList().join('\n')}
""";
  }
''';
  }

  _validateIndices(ClassElement entity, String tableName, List<Index> indices) {
    for (Index index in indices) {
      if (index.columns.isEmpty) {
        throw Exception('$tableName: index columns cannot be empty!!');
      }
      for (String column in index.columns) {
        if (!entity.hasProperty(column)) {
          throw Exception('$tableName has not property with name: $column');
        }
      }
      if (index.orders.isNotEmpty &&
          index.orders.length != index.columns.length) {
        throw Exception('$tableName: orders property must be empty or '
            'the number of entries in the orders property should be '
            'equal to size of columns');
      }
    }
  }

  String _generateIndexCreatorQuery(Index index, String tableName) {
    return '''
CREATE ${index.unique ? 'UNIQUE' : ''} INDEX ${_getNameForIndex(index, tableName)}
ON $tableName (${_getColumnsForIndex(index)});
''';
  }

  String _getNameForIndex(Index index, String tableName) {
    if (index.name != null) return index.name!;

    return 'idx_${tableName}_${index.columns.join('_')}';
  }

  String _getColumnsForIndex(Index index) {
    bool hasOrders = index.orders.isNotEmpty;
    if (!hasOrders) return index.columns.join(',');

    String columns = '';
    int i = 0;
    for (String column in index.columns) {
      columns += '$column ${index.orders[i].name}';
      if (i < index.columns.length - 1) columns += ',';
      i++;
    }
    return columns;
  }
}

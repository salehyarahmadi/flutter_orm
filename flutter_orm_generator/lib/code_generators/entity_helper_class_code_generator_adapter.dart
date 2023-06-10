import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/entity_from_json_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/entity_indices_query_builder_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/entity_query_builder_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/entity_to_json_code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/class/has_named_parameters_default_constructor_validator.dart';
import 'package:flutter_orm_generator/validation/class/has_valid_primary_key_validator.dart';
import 'package:flutter_orm_generator/validation/class/is_entity_validator.dart';
import 'package:flutter_orm_generator/validation/element/is_class_validator.dart';
import 'package:flutter_orm_generator/validation/element/null_check_validator.dart';


class EntityHelperClassCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  EntityHelperClassCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    _validation(dbClass, element);
    ClassElement entityClass = element as ClassElement;
    String entityClassName = entityClass.displayName;
    String tableName = entityClass.getEntityTableName();

    String entityQueryBuilder =
        CodeGeneratorBuilder(EntityQueryBuilderCodeGeneratorAdapter(dbClass))
            .element(entityClass)
            .generate();

    String entityIndicesQuery =
        CodeGeneratorBuilder(EntityIndicesQueryBuilderCodeGeneratorAdapter())
            .element(entityClass)
            .generate();

    String entityFromJson =
        CodeGeneratorBuilder(EntityFromJsonCodeGeneratorAdapter(dbClass))
            .element(entityClass)
            .generate();

    String entityToJson =
        CodeGeneratorBuilder(EntityToJsonCodeGeneratorAdapter(dbClass))
            .element(entityClass)
            .generate();

    return '''
class ${entityClassName.helperClassName()} {

  static const String tableName = '$tableName';

  $entityQueryBuilder
  
  $entityIndicesQuery
  
  $entityFromJson
  
  $entityToJson

}
''';
  }

  _validation(ClassElement dbClass, Element? element) {
    NullCheckValidator()
        .then(IsClassValidator())
        .then(IsEntityValidator(dbClass))
        .then(HasValidPrimaryKeyValidator())
        .then(HasNamedParametersDefaultConstructorValidator())
        .check(element);
  }
}

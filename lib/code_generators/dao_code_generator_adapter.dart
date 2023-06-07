import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/code_generators/delete_code_generator_adapter.dart';
import 'package:flutter_orm/code_generators/insert_code_generator_adapter.dart';
import 'package:flutter_orm/code_generators/raw_query_code_generator_adapter.dart';
import 'package:flutter_orm/code_generators/transactional_code_generator_adapter.dart';
import 'package:flutter_orm/code_generators/update_code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/class/is_abstract_class_validator.dart';
import 'package:flutter_orm/validation/class/is_dao_validator.dart';
import 'package:flutter_orm/validation/element/is_class_validator.dart';
import 'package:flutter_orm/validation/element/null_check_validator.dart';


// Todo: check more than one annotation on dao methods
class DaoCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  DaoCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    _validation(element);
    ClassElement daoClass = element as ClassElement;
    String daoClassName = daoClass.displayName;

    String insertMethodsImpl =
        CodeGeneratorBuilder(InsertCodeGeneratorAdapter(dbClass))
            .element(daoClass)
            .generate();

    String updateMethodsImpl =
        CodeGeneratorBuilder(UpdateCodeGeneratorAdapter(dbClass))
            .element(daoClass)
            .generate();

    String deleteMethodsImpl =
        CodeGeneratorBuilder(DeleteCodeGeneratorAdapter(dbClass))
            .element(daoClass)
            .generate();

    String queryMethodsImpl =
        CodeGeneratorBuilder(RawQueryCodeGeneratorAdapter(dbClass))
            .element(daoClass)
            .generate();

    String transactionalMethodsImpl =
        CodeGeneratorBuilder(TransactionalCodeGeneratorAdapter())
            .element(daoClass)
            .generate();

    return """

class ${daoClassName.implClassName()} implements $daoClassName {
  final Database? db;

  ${daoClassName.implClassName()}(this.db);
  
  $insertMethodsImpl
  
  $updateMethodsImpl
  
  $deleteMethodsImpl
  
  $queryMethodsImpl
  
  $transactionalMethodsImpl
}
""";
  }

  _validation(Element? element) {
    NullCheckValidator()
        .then(IsClassValidator())
        .then(IsAbstractClassValidator())
        .then(IsDaoValidator())
        .check(element);
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/code_generators/bulk_insert_code_generator_adapter.dart';
import 'package:flutter_orm/code_generators/single_insert_code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';


class InsertCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  InsertCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    ClassElement daoClass = element as ClassElement;
    List<MethodElement> insertMethods =
        daoClass.getMethodsWithInsertAnnotation();
    String result = '';
    for (var method in insertMethods) {
      if (_isSingleInsert(method)) {
        result +=
            CodeGeneratorBuilder(SingleInsertCodeGeneratorAdapter(dbClass))
                .element(method)
                .generate();
      }
      if (_isBulkInsert(method)) {
        result += CodeGeneratorBuilder(BulkInsertCodeGeneratorAdapter(dbClass))
            .element(method)
            .generate();
      }
      result += '\n';
    }

    return result;
  }

  bool _isSingleInsert(MethodElement method) =>
      method.parameters.first.type.isEntity(dbClass);

  bool _isBulkInsert(MethodElement method) =>
      method.parameters.first.type.isListOfEntity(dbClass);
}

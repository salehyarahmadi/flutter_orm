import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/bulk_update_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/single_update_code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';


class UpdateCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  UpdateCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    ClassElement daoClass = element as ClassElement;
    List<MethodElement> updateMethods =
        daoClass.getMethodsWithUpdateAnnotation();
    String result = '';
    for (var method in updateMethods) {
      if (_isSingleUpdate(method)) {
        result +=
            CodeGeneratorBuilder(SingleUpdateCodeGeneratorAdapter(dbClass))
                .element(method)
                .generate();
      }
      if (_isBulkUpdate(method)) {
        result += CodeGeneratorBuilder(BulkUpdateCodeGeneratorAdapter(dbClass))
            .element(method)
            .generate();
      }
      result += '\n';
    }

    return result;
  }

  bool _isSingleUpdate(MethodElement method) =>
      method.parameters.first.type.isEntity(dbClass);

  bool _isBulkUpdate(MethodElement method) =>
      method.parameters.first.type.isListOfEntity(dbClass);
}

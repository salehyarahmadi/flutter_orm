import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';

class DaoOverrideCodeGeneratorAdapter extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement dbClass = element as ClassElement;
    String daoOverrides = '';
    for (var daoMethod in dbClass.getMethodsWithDaoReturnType()) {
      daoOverrides += _generateDaoOverride(daoMethod);
    }
    return daoOverrides;
  }

  String _generateDaoOverride(MethodElement daoMethod) {
    return """
@override
${daoMethod.returnType.toString()} ${daoMethod.name}() {
  return ${daoMethod.returnType.toString().implClassName()}(getDB());
}

""";
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/method/is_all_parameters_positional_validator.dart';
import 'package:flutter_orm/validation/method/method_return_type_validator.dart';
import 'package:flutter_orm/validation/method/transaction_actions_existence_validator.dart';
import 'package:flutter_orm/validation/method/transaction_parameter_validator.dart';
import 'package:flutter_orm/validation/validator.dart';

class TransactionalCodeGeneratorAdapter extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement daoClass = element as ClassElement;
    return _generateAllInsertMethodsImplementation(daoClass);
  }

  String _generateAllInsertMethodsImplementation(ClassElement daoClass) {
    List<MethodElement> transactionalMethods =
        daoClass.getMethodsWithTransactionalAnnotation();
    _validateTransactionalMethods(daoClass, transactionalMethods);
    String result = '';
    for (var method in transactionalMethods) {
      String methodImpl = _generateMethodImpl(daoClass, method);
      result += methodImpl + '\n';
    }

    return result;
  }

  _validateTransactionalMethods(
    ClassElement daoClass,
    List<MethodElement> transactionalMethods,
  ) {
    ElementValidator validator = MethodReturnTypeValidator(
      (type) => type.isFutureVoid(),
      'transactional method\'s return type must be Future<void>',
    )
        .then(IsAllParametersPositionalValidator())
        .then(TransactionActionsExistenceValidator(daoClass))
        .then(TransactionParameterValidator(daoClass));
    for (var method in transactionalMethods) {
      validator.check(method);
    }
  }

  String _generateMethodImpl(ClassElement daoClass, MethodElement method) {
    List<String> sequentialActions = method
            .getListFieldFromAnnotation(
                Transactional, Transactional.fields.sequentialActions)
            ?.map((e) => e.toStringValue() ?? '')
            .toList() ??
        [];
    List<String> foundedParametersName = [];
    String methodBody = '';
    for (var actionName in sequentialActions) {
      MethodElement actionMethod = daoClass.findMethod(actionName)!;
      String arguments = '';

      if (actionMethod.isInsertMethod() ||
          actionMethod.isUpdateMethod() ||
          actionMethod.isDeleteMethod()) {
        for (var actionMethodParameter in actionMethod.parameters) {
          ParameterElement foundParameter = method.parameters.firstWhere((e) =>
              _hasCorrectAnnotation(actionMethod, e) &&
              e.type.toString() == actionMethodParameter.type.toString() &&
              !foundedParametersName.contains(e.name));
          foundedParametersName.add(foundParameter.name);
          arguments += foundParameter.name + ',';
        }
      }
      if (actionMethod.isRawQueryMethod()) {
        for (var actionMethodParameter in actionMethod.parameters) {
          ParameterElement foundParameter = method.parameters.firstWhere((e) =>
              e.hasQueryParamAnnotation() &&
              e.type.toString() == actionMethodParameter.type.toString() &&
              !foundedParametersName.contains(e.name));
          String queryParamAnnotationMethodName =
              foundParameter.getStringFieldFromAnnotation(
                      QueryParam, QueryParam.fields.methodName) ??
                  '';
          String queryParamAnnotationParameterName =
              foundParameter.getStringFieldFromAnnotation(
                      QueryParam, QueryParam.fields.parameterName) ??
                  '';
          if (queryParamAnnotationMethodName == actionName &&
              queryParamAnnotationParameterName == actionMethodParameter.name) {
            foundedParametersName.add(foundParameter.name);
            arguments += foundParameter.name + ',';
          }
        }
      }

      String executeAction = 'await $actionName($arguments txn: txn) ;';
      methodBody += executeAction + '\n';
    }

    return """
@override
${method.declaration.toString()} async {
  db?.transaction((txn) async {
    $methodBody
  });
}
""";
  }

  bool _hasCorrectAnnotation(
    MethodElement actionMethod,
    ParameterElement parameter,
  ) {
    return (actionMethod.isInsertMethod() &&
            parameter.hasInsertParamAnnotation()) ||
        (actionMethod.isUpdateMethod() &&
            parameter.hasUpdateParamAnnotation()) ||
        (actionMethod.isDeleteMethod() && parameter.hasDeleteParamAnnotation());
  }
}

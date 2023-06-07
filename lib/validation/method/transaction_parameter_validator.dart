import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/validator.dart';
import 'package:source_gen/source_gen.dart';

const _insertParamChecker = TypeChecker.fromRuntime(InsertParam);
const _updateParamChecker = TypeChecker.fromRuntime(UpdateParam);
const _deleteParamChecker = TypeChecker.fromRuntime(DeleteParam);
const _queryParamChecker = TypeChecker.fromRuntime(QueryParam);

class TransactionParameterValidator extends ElementValidator<MethodElement> {
  final ClassElement daoClass;

  TransactionParameterValidator(this.daoClass);

  final List<String> _founded = [];

  @override
  check(MethodElement element) {
    _founded.clear();
    MethodElement transactionalMethod = element;

    List<String> sequentialActions = transactionalMethod
            .getListFieldFromAnnotation(
                Transactional, Transactional.fields.sequentialActions)
            ?.map((e) => e.toStringValue() ?? '')
            .toList() ??
        [];

    for (var actionName in sequentialActions) {
      MethodElement actionMethod = daoClass.findMethod(actionName)!;
      TypeChecker? typeChecker = _getParamTypeChecker(actionMethod);
      for (var actionMethodParameter in actionMethod.parameters) {
        bool found = false;
        for (var transactionalMethodParam in transactionalMethod.parameters) {
          found = _isValidParameterFound(
              transactionalMethodParam, actionMethodParameter, actionName);
          if (found) {
            _founded.add(transactionalMethodParam.name);
            break;
          }
        }
        if (!found) {
          throw Exception('${element.name}: you must have a parameter with '
              'type: `@${typeChecker.toString().substring(typeChecker.toString().indexOf('#') + 1)}'
              '(${actionMethod.isRawQueryMethod() ? "'$actionName', '${actionMethodParameter.name}'" : ""}) '
              '${actionMethodParameter.type.toString()}` '
              'for action: ${actionMethod.name} '
              'and parameter: ${actionMethodParameter.name}');
        }
      }
    }

    if (_founded.length < transactionalMethod.parameters.length) {
      throw Exception('${element.name}: this method has extra parameters');
    }

    checkNext(element);
  }

  bool _isValidParameterFound(
    ParameterElement transactionalMethodParam,
    ParameterElement actionMethodParameter,
    String actionName,
  ) {
    MethodElement _actionMethod = daoClass.findMethod(actionName)!;
    TypeChecker? _typeChecker = _getParamTypeChecker(_actionMethod);
    bool _isCandidate =
        _typeChecker?.hasAnnotationOfExact(transactionalMethodParam) == true &&
            transactionalMethodParam.type.toString() ==
                actionMethodParameter.type.toString() &&
            !_founded.contains(transactionalMethodParam.name);
    if (!_isCandidate) return false;

    return _actionMethod.isRawQueryMethod()
        ? ((transactionalMethodParam.getStringFieldFromAnnotation(
                    QueryParam, QueryParam.fields.methodName) ==
                actionName) &&
            (transactionalMethodParam.getStringFieldFromAnnotation(
                    QueryParam, QueryParam.fields.parameterName) ==
                actionMethodParameter.name))
        : true;
  }

  TypeChecker? _getParamTypeChecker(MethodElement actionMethod) {
    if (actionMethod.isInsertMethod()) {
      return _insertParamChecker;
    }
    if (actionMethod.isUpdateMethod()) {
      return _updateParamChecker;
    }
    if (actionMethod.isDeleteMethod()) {
      return _deleteParamChecker;
    }
    if (actionMethod.isRawQueryMethod()) {
      return _queryParamChecker;
    }
    return null;
  }
}

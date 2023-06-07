import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm/enums/on_conflict_strategy.dart';
import 'package:source_gen/source_gen.dart';

const _insertChecker = TypeChecker.fromRuntime(Insert);
const _updateChecker = TypeChecker.fromRuntime(Update);
const _deleteChecker = TypeChecker.fromRuntime(Delete);
const _rawQueryChecker = TypeChecker.fromRuntime(Query);
const _insertParamChecker = TypeChecker.fromRuntime(InsertParam);
const _updateParamChecker = TypeChecker.fromRuntime(UpdateParam);
const _deleteParamChecker = TypeChecker.fromRuntime(DeleteParam);
const _queryParamChecker = TypeChecker.fromRuntime(QueryParam);

extension MethodElementExtension on MethodElement {
  bool hasReturnType() {
    return returnType.getDisplayString(withNullability: true) !=
            'Future<void>' &&
        returnType.getDisplayString(withNullability: true) != 'void';
  }

  String getReturnTypeOfFutureMethod() {
    String displayName =
        this.returnType.getDisplayString(withNullability: true);
    String returnType = displayName.substring(
        displayName.indexOf('Future<') + 7, displayName.lastIndexOf('>'));
    return returnType;
  }

  String getConflictAlgorithm() {
    if (!_insertChecker.hasAnnotationOfExact(this) &&
        !_updateChecker.hasAnnotationOfExact(this)) {
      throw Exception('getConflictAlgorithm(): this method must be call '
          'on insert or update method element');
    }
    DartObject? annotation = _insertChecker.firstAnnotationOfExact(this) ??
        _updateChecker.firstAnnotationOfExact(this);
    if (annotation == null) return '';
    int? index = annotation
        .getField(Insert.fields.onConflict)
        ?.getField('index')
        ?.toIntValue();
    if (index == null) {
      return '';
    }

    String conflictAlgorithm = OnConflictStrategy.values[index].name;
    return 'conflictAlgorithm: ConflictAlgorithm.$conflictAlgorithm,';
  }

  bool isInsertMethod() {
    return _insertChecker.hasAnnotationOfExact(this);
  }

  bool isUpdateMethod() {
    return _updateChecker.hasAnnotationOfExact(this);
  }

  bool isDeleteMethod() {
    return _deleteChecker.hasAnnotationOfExact(this);
  }

  bool isRawQueryMethod() {
    return _rawQueryChecker.hasAnnotationOfExact(this);
  }

  int parametersWithInsertParamAnnotationCount() {
    int count = 0;
    for (var parameter in parameters) {
      if (_insertParamChecker.hasAnnotationOfExact(parameter)) {
        count++;
      }
    }
    return count;
  }

  int parametersWithUpdateParamAnnotationCount() {
    int count = 0;
    for (var parameter in parameters) {
      if (_updateParamChecker.hasAnnotationOfExact(parameter)) {
        count++;
      }
    }
    return count;
  }

  int parametersWithDeleteParamAnnotationCount() {
    int count = 0;
    for (var parameter in parameters) {
      if (_deleteParamChecker.hasAnnotationOfExact(parameter)) {
        count++;
      }
    }
    return count;
  }

  int parametersWithQueryParamAnnotationCount() {
    int count = 0;
    for (var parameter in parameters) {
      if (_queryParamChecker.hasAnnotationOfExact(parameter)) {
        count++;
      }
    }
    return count;
  }

  String declarationWithTransactionParameter() {
    return declaration.toString().replaceAll(
          ')',
          '${parameters.isNotEmpty ? ', ' : ''}{Transaction? txn})',
        );
  }
}

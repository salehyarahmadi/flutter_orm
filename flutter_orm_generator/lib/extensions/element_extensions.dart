import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:source_gen/source_gen.dart';

const _entityChecker = TypeChecker.fromRuntime(Entity);
const _primaryKeyChecker = TypeChecker.fromRuntime(PrimaryKey);
const _columnChecker = TypeChecker.fromRuntime(Column);
const _queryChecker = TypeChecker.fromRuntime(Query);
const _transactionalChecker = TypeChecker.fromRuntime(Transactional);
const _insertParamChecker = TypeChecker.fromRuntime(InsertParam);
const _updateParamChecker = TypeChecker.fromRuntime(UpdateParam);
const _deleteParamChecker = TypeChecker.fromRuntime(DeleteParam);
const _queryParamChecker = TypeChecker.fromRuntime(QueryParam);
const _dbChecker = TypeChecker.fromRuntime(DB);

extension ElementExtension on Element? {
  bool hasPrimaryKeyAnnotation() {
    if (this == null) return false;
    return _primaryKeyChecker.hasAnnotationOfExact(this!);
  }

  DartObject? getPrimaryKeyAnnotation() {
    if (this == null) return null;
    return _primaryKeyChecker.firstAnnotationOfExact(this!);
  }

  bool hasColumnAnnotation() {
    if (this == null) return false;
    return _columnChecker.hasAnnotationOfExact(this!);
  }

  DartObject? getColumnAnnotation() {
    if (this == null) return null;
    return _columnChecker.firstAnnotationOfExact(this!);
  }

  DartObject? getEntityAnnotation() {
    if (this == null) return null;
    return _entityChecker.firstAnnotationOfExact(this!);
  }

  DartObject? getQueryAnnotation() {
    if (this == null) return null;
    return _queryChecker.firstAnnotationOfExact(this!);
  }

  DartObject? getTransactionalAnnotation() {
    if (this == null) return null;
    return _transactionalChecker.firstAnnotationOfExact(this!);
  }

  bool hasInsertParamAnnotation() {
    if (this == null) return false;
    return _insertParamChecker.hasAnnotationOfExact(this!);
  }

  bool hasUpdateParamAnnotation() {
    if (this == null) return false;
    return _updateParamChecker.hasAnnotationOfExact(this!);
  }

  bool hasDeleteParamAnnotation() {
    if (this == null) return false;
    return _deleteParamChecker.hasAnnotationOfExact(this!);
  }

  bool hasQueryParamAnnotation() {
    if (this == null) return false;
    return _queryParamChecker.hasAnnotationOfExact(this!);
  }

  DartObject? getQueryParamAnnotation() {
    if (this == null) return null;
    return _queryParamChecker.firstAnnotationOfExact(this!);
  }

  DartObject? getDBAnnotation() {
    if (this == null) return null;
    return _dbChecker.firstAnnotationOfExact(this!);
  }

  String? getStringFieldFromAnnotation(Type annotation, String fieldName) {
    return _getFieldFromAnnotation(annotation, fieldName)?.toStringValue();
  }

  int? getIntFieldFromAnnotation(Type annotation, String fieldName) {
    return _getFieldFromAnnotation(annotation, fieldName)?.toIntValue();
  }

  bool? getBoolFieldFromAnnotation(Type annotation, String fieldName) {
    return _getFieldFromAnnotation(annotation, fieldName)?.toBoolValue();
  }

  DartType? getDartTypeFieldFromAnnotation(Type annotation, String fieldName) {
    return _getFieldFromAnnotation(annotation, fieldName)?.toTypeValue();
  }

  List<DartObject>? getListFieldFromAnnotation(
      Type annotation, String fieldName) {
    return _getFieldFromAnnotation(annotation, fieldName)?.toListValue();
  }

  DartObject? _getFieldFromAnnotation(Type annotation, String fieldName) {
    if (this == null) return null;
    var _checker = TypeChecker.fromRuntime(annotation);
    if (!_checker.hasAnnotationOfExact(this!)) return null;
    return _checker.firstAnnotationOfExact(this!)?.getField(fieldName);
  }
}

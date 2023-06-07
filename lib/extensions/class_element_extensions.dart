import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/converter/built_in_support_converters_helper.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/utils/constants.dart';
import 'package:source_gen/source_gen.dart';

const _primaryKeyChecker = TypeChecker.fromRuntime(PrimaryKey);
const _daoChecker = TypeChecker.fromRuntime(Dao);
const _deleteChecker = TypeChecker.fromRuntime(Delete);
const _insertChecker = TypeChecker.fromRuntime(Insert);
const _updateChecker = TypeChecker.fromRuntime(Update);
const _queryChecker = TypeChecker.fromRuntime(Query);
const _typeConverterChecker = TypeChecker.fromRuntime(TypeConverter);
const _dbChecker = TypeChecker.fromRuntime(DB);
const _transactionalChecker = TypeChecker.fromRuntime(Transactional);
const _entityChecker = TypeChecker.fromRuntime(Entity);
const _ignoreChecker = TypeChecker.fromRuntime(Ignore);

extension ClassElementExtension on ClassElement? {
  FieldElement findPrimaryKey() {
    for (var field in this!.fields) {
      if (_primaryKeyChecker.hasAnnotationOfExact(field)) {
        return field;
      }
    }
    throw Exception('${this!.name} has not primary key');
  }

  List<FieldElement> getColumnsForTable({bool includePrimaryKey = false}) {
    if (this == null) {
      throw Exception('element is null');
    }
    if (!_entityChecker.hasAnnotationOfExact(this!)) {
      throw Exception('${this!.name} is not Entity class');
    }
    List<FieldElement> list = [];
    for (FieldElement field in this?.fields ?? []) {
      if (!field.isPrivate && !_ignoreChecker.hasAnnotationOfExact(field)) {
        if (!includePrimaryKey &&
            _primaryKeyChecker.hasAnnotationOfExact(field)) {
          continue;
        }
        list.add(field);
      }
    }
    return list;
  }

  List<MethodElement> getMethodsWithDaoReturnType() {
    List<MethodElement> list = [];
    for (var method in this?.methods ?? []) {
      if ((method.returnType.element is ClassElement) &&
          (_daoChecker.hasAnnotationOfExact(
              method.returnType.element as ClassElement))) {
        list.add(method);
      }
    }

    return list;
  }

  List<MethodElement> getMethodsWithDeleteAnnotation() {
    List<MethodElement> list = [];
    for (var method in this?.methods ?? []) {
      if (_deleteChecker.hasAnnotationOfExact(method)) {
        list.add(method);
      }
    }
    return list;
  }

  List<MethodElement> getMethodsWithInsertAnnotation() {
    List<MethodElement> list = [];
    for (var method in this?.methods ?? []) {
      if (_insertChecker.hasAnnotationOfExact(method)) {
        list.add(method);
      }
    }
    return list;
  }

  List<MethodElement> getMethodsWithUpdateAnnotation() {
    List<MethodElement> list = [];
    for (var method in this?.methods ?? []) {
      if (_updateChecker.hasAnnotationOfExact(method)) {
        list.add(method);
      }
    }
    return list;
  }

  List<MethodElement> getMethodsWithQueryAnnotation() {
    List<MethodElement> list = [];
    for (var method in this?.methods ?? []) {
      if (_queryChecker.hasAnnotationOfExact(method)) {
        list.add(method);
      }
    }
    return list;
  }

  List<MethodElement> getMethodsWithTransactionalAnnotation() {
    List<MethodElement> list = [];
    for (var method in this?.methods ?? []) {
      if (_transactionalChecker.hasAnnotationOfExact(method)) {
        list.add(method);
      }
    }
    return list;
  }

  Map<String, String> getUserDefinedConvertibleTypes() {
    Map<String, String> convertibleTypes = {};
    if (this == null) return {};
    Element? typeConvertersClass = this!
        .getDartTypeFieldFromAnnotation(
            TypeConverters, TypeConverters.fields.converters)
        ?.element;
    if (typeConvertersClass != null) {
      for (var method in (typeConvertersClass as ClassElement).methods) {
        if (_typeConverterChecker.hasAnnotationOfExact(method)) {
          if (method.parameters.first.type.isNotBuiltIn()) {
            convertibleTypes.putIfAbsent(
                method.parameters.first.type.toString(),
                () => method.returnType.toString());
          }
        }
      }
    }
    return convertibleTypes;
  }

  List<String> getUserDefinedConvertersHelperMethods() {
    List<String> list = [];
    if (this == null) return [];
    Element? typeConvertersClass = this!
        .getDartTypeFieldFromAnnotation(
            TypeConverters, TypeConverters.fields.converters)
        ?.element;
    if (typeConvertersClass != null) {
      for (var method in (typeConvertersClass as ClassElement).methods) {
        if (_typeConverterChecker.hasAnnotationOfExact(method)) {
          bool isReturnTypeNullable =
              method.returnType.toString().contains('?');
          bool isParameterTypeNullable =
              method.parameters.first.type.toString().contains('?');
          String returnTypeName =
              method.returnType.getDisplayString(withNullability: false);
          String parameterTypeName = method.parameters.first.type
              .getDisplayString(withNullability: false);
          if (returnTypeName.isBuiltIn()) {
            list.add("""
              static ${method.returnType.toString()} from${isParameterTypeNullable ? 'Nullable' : ''}$parameterTypeName(value) {
                return ${typeConvertersClass.name}.${method.name}(value as ${method.parameters.first.type.toString()});
              }
          """);
          } else {
            list.add("""
              static ${method.returnType.toString()} to${isReturnTypeNullable ? 'Nullable' : ''}$returnTypeName(value) {
                return ${typeConvertersClass.name}.${method.name}(value as ${method.parameters.first.type.toString()});
              }
          """);
          }
        }
      }
    }
    return list;
  }

  String getProperSqliteType(String dartType, {bool forPrimaryKey = false}) {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('getProperSqliteType(): '
          'this method must be call on db class element');
    }
    String? sqliteType;
    if (builtInTypes.containsKey(dartType)) {
      sqliteType = builtInTypes[dartType]!;
    } else if (dartType.isBuiltInSupport()) {
      sqliteType =
          BuiltInSupportConvertersHelper.getProperSqliteType(dartType)!;
    } else if (getUserDefinedConvertibleTypes().keys.contains(dartType)) {
      sqliteType = builtInTypes[getUserDefinedConvertibleTypes()[dartType]];
    }

    if (sqliteType == null) {
      throw Exception("$dartType doesn't support");
    }

    if (forPrimaryKey) {
      sqliteType = sqliteType.replaceAll('NOT NULL', '');
    }
    return sqliteType;
  }

  bool hasInterface(String name) {
    return this
            ?.interfaces
            .map((e) => e.element.name)
            .toList()
            .contains(name) ??
        false;
  }

  bool hasMethod(String name) {
    return this?.methods.map((e) => e.name).toList().contains(name) ?? false;
  }

  bool hasOnConfigureInterface() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnConfigureInterface(): '
          'this method must be call on db class element');
    }
    return hasInterface('OnConfigure');
  }

  bool hasOnConfigureMethod() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnConfigureMethod(): '
          'this method must be call on db class element');
    }
    return hasMethod('onConfigure');
  }

  bool hasOnOpenInterface() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnOpenInterface(): '
          'this method must be call on db class element');
    }
    return hasInterface('OnOpen');
  }

  bool hasOnOpenMethod() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnOpenMethod(): '
          'this method must be call on db class element');
    }
    return hasMethod('onOpen');
  }

  bool hasOnUpgradeInterface() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnUpgradeInterface(): '
          'this method must be call on db class element');
    }
    return hasInterface('OnUpgrade');
  }

  bool hasOnUpgradeMethod() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnUpgradeMethod(): '
          'this method must be call on db class element');
    }
    return hasMethod('onUpgrade');
  }

  bool hasOnDowngradeInterface() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnDowngradeInterface(): '
          'this method must be call on db class element');
    }
    return hasInterface('OnDowngrade');
  }

  bool hasOnDowngradeMethod() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnDowngradeMethod(): '
          'this method must be call on db class element');
    }
    return hasMethod('onDowngrade');
  }

  bool hasOnCreateInterface() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnCreateInterface(): '
          'this method must be call on db class element');
    }
    return hasInterface('OnCreate');
  }

  bool hasOnCreateMethod() {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('hasOnCreateMethod(): '
          'this method must be call on db class element');
    }
    return hasMethod('onCreate');
  }

  MethodElement? findMethod(String methodName) {
    List<MethodElement> methods = this?.methods ?? [];
    if (methods.map((e) => e.name).contains(methodName)) {
      return methods.firstWhere((m) => m.name == methodName);
    }
    return null;
  }

  FieldElement getPrimaryKeyWithEntityName(String entityName) {
    if (!_dbChecker.hasAnnotationOfExact(this!)) {
      throw Exception('getPrimaryKeyWithEntityName(): '
          'this method must be call on db class element');
    }
    DartObject? dbAnnotation = _dbChecker.firstAnnotationOfExact(this!);
    if (dbAnnotation == null) {
      throw Exception('getPrimaryKeyWithEntityName(): annotation is null');
    }

    List<ClassElement> entities = dbAnnotation
            .getField(DB.fields.entities)
            ?.toListValue()
            ?.map((e) => e.toTypeValue()!.element! as ClassElement)
            .toList() ??
        [];
    for (var entity in entities) {
      if (entity.name == entityName) {
        for (var field in entity.fields) {
          if (_primaryKeyChecker.hasAnnotationOfExact(field)) {
            return field;
          }
        }
      }
    }

    throw Exception(
        'getPrimaryKeyWithEntityName(): $entityName has not primary key');
  }

  String getEntityTableName() {
    if (this == null) {
      throw Exception('class is null');
    }
    return this!
            .getStringFieldFromAnnotation(Entity, Entity.fields.tableName) ??
        this!.name;
  }

  List<FieldElement> getCustomObjectFields() {
    if (this == null) {
      throw Exception('element is null');
    }
    List<FieldElement> list = [];
    for (FieldElement field in this?.fields ?? []) {
      if (!field.isPrivate && !_ignoreChecker.hasAnnotationOfExact(field)) {
        list.add(field);
      }
    }
    return list;
  }

  bool hasProperty(String name) {
    if (this == null) {
      throw Exception('element is null');
    }
    for (FieldElement field in this?.fields ?? []) {
      if (field.name == name) {
        return true;
      }
    }
    return false;
  }
}

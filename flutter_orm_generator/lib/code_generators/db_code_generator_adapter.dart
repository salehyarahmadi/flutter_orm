import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/converters_helper_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/dao_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/dao_override_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/default_on_configure_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/default_on_create_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/default_on_downgrade_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/default_on_open_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/default_on_upgrade_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/entity_helper_class_code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/on_create_code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/class/is_abstract_class_validator.dart';
import 'package:flutter_orm_generator/validation/class/is_db_validator.dart';
import 'package:flutter_orm_generator/validation/class/type_converters_validator.dart';
import 'package:flutter_orm_generator/validation/element/is_class_validator.dart';
import 'package:flutter_orm_generator/validation/element/null_check_validator.dart';
import 'package:source_gen/source_gen.dart';

class DBCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ConstantReader annotation;
  final BuildStep buildStep;

  DBCodeGeneratorAdapter(this.annotation, this.buildStep);

  @override
  String generate(Element? element) {
    _validation(element);
    ClassElement dbClass = element as ClassElement;
    String className = dbClass.displayName;
    String path = buildStep.inputId.path;
    String name = annotation.peek(DB.fields.name)!.stringValue;
    int version = annotation.peek(DB.fields.version)?.intValue ?? 1;
    bool readOnly = annotation.peek(DB.fields.readOnly)?.boolValue ?? false;
    bool singleInstance =
        annotation.peek(DB.fields.singleInstance)?.boolValue ?? true;

    String defaultOnConfigure =
        CodeGeneratorBuilder(DefaultOnConfigureCodeGeneratorAdapter())
            .element(dbClass)
            .generate();

    String defaultOnOpen =
        CodeGeneratorBuilder(DefaultOnOpenCodeGeneratorAdapter())
            .element(dbClass)
            .generate();

    String defaultOnUpgrade =
        CodeGeneratorBuilder(DefaultOnUpgradeCodeGeneratorAdapter())
            .element(dbClass)
            .generate();

    String defaultOnDowngrade =
        CodeGeneratorBuilder(DefaultOnDowngradeCodeGeneratorAdapter())
            .element(dbClass)
            .generate();

    String defaultOnCreate =
        CodeGeneratorBuilder(DefaultOnCreateCodeGeneratorAdapter())
            .element(dbClass)
            .generate();

    String onCreate =
        CodeGeneratorBuilder(OnCreateCodeGeneratorAdapter(dbClass, annotation))
            .generate();

    String daoOverrides =
        CodeGeneratorBuilder(DaoOverrideCodeGeneratorAdapter())
            .element(dbClass)
            .generate();

    String convertersHelperClass =
        CodeGeneratorBuilder(ConvertersHelperCodeGeneratorAdapter())
            .element(dbClass)
            .generate();

    String implClassName = className.implClassName();

    return '''
part of '${path.substring(path.lastIndexOf('/') + 1)}';

$convertersHelperClass

class $implClassName extends $className {
  static final $implClassName _instance = $implClassName._internal();

  $implClassName._internal();
  
  static $implClassName get() {
    return _instance;
  }

  Database? _database;

  Future<Database?> initialize({String? path}) async {
    if (_database == null) {
      var databasesPath = path ?? (await getDatabasesPath() + "/$name.db");
      _database = await openDatabase(
        databasesPath,
        version: $version,
        readOnly: $readOnly,
        singleInstance: $singleInstance,
        ${dbClass.hasOnConfigureInterface() ? 'onConfigure: onConfigure,' : ''}
        ${dbClass.hasOnOpenInterface() ? 'onOpen: onOpen,' : ''}
        ${dbClass.hasOnUpgradeInterface() ? 'onUpgrade: onUpgrade,' : ''}
        ${dbClass.hasOnDowngradeInterface() ? 'onDowngrade: onDowngrade,' : ''}        
        onCreate: (db, version) async {
          $onCreate
        },
      );
    }
    return _database;
  }
  
  Database? getDB() {
    return _database;
  }
  
  $defaultOnConfigure
  
  $defaultOnOpen
  
  $defaultOnUpgrade
  
  $defaultOnDowngrade
  
  $defaultOnCreate
  
  $daoOverrides

}

${_generateEntitiesHelperClasses(dbClass, annotation)}

${_generateDaoClasses(dbClass)}

''';
  }

  _validation(Element? element) {
    NullCheckValidator()
        .then(IsClassValidator())
        .then(IsAbstractClassValidator())
        .then(IsDBValidator())
        .then(TypeConvertersValidator())
        .check(element);
  }

  String _generateEntitiesHelperClasses(
      ClassElement dbClass, ConstantReader annotation) {
    String entitiesHelperClasses = '';
    annotation.peek(DB.fields.entities)?.listValue.forEach((e) {
      Element? entityElement = e.toTypeValue()?.element;
      String entityHelperClass =
          CodeGeneratorBuilder(EntityHelperClassCodeGeneratorAdapter(dbClass))
              .element(entityElement)
              .generate();
      entitiesHelperClasses += entityHelperClass;
    });
    return entitiesHelperClasses;
  }

  String _generateDaoClasses(ClassElement dbClass) {
    String daoClasses = '';
    for (var daoAbstractMethod in dbClass.getMethodsWithDaoReturnType()) {
      String daoClass = CodeGeneratorBuilder(DaoCodeGeneratorAdapter(dbClass))
          .element(daoAbstractMethod.returnType.element)
          .generate();
      daoClasses += daoClass;
    }
    return daoClasses;
  }
}

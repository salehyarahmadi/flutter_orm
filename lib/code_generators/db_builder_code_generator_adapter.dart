import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/class/is_abstract_class_validator.dart';
import 'package:flutter_orm/validation/class/is_db_validator.dart';
import 'package:flutter_orm/validation/element/is_class_validator.dart';
import 'package:flutter_orm/validation/element/null_check_validator.dart';
import 'package:source_gen/source_gen.dart';

class DBBuilderCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ConstantReader annotation;
  final BuildStep buildStep;

  DBBuilderCodeGeneratorAdapter(this.annotation, this.buildStep);

  @override
  String generate(Element? element) {
    _validation(element);

    String path = buildStep.inputId.path;

    String dbsBuilder = '';
    annotation.peek(DBBuilder.fields.databases)?.listValue.forEach((e) {
      Element? dbElement = e.toTypeValue()?.element;
      _validateDBElement(dbElement);
      String dbName = e.toTypeValue().toString();
      dbName = dbName.substring(0, dbName.length - 1);
      String dbBuilder = '';
      dbBuilder += _generateCodeForGetDB(dbName);
      dbsBuilder += dbBuilder;
    });

    return '''
part of '${path.substring(path.lastIndexOf('/') + 1)}';

class DBContext {
  $dbsBuilder
}
''';
  }

  void _validation(Element? element) {
    NullCheckValidator()
        .then(IsClassValidator())
        .then(IsAbstractClassValidator())
        .check(element);
  }

  _validateDBElement(Element? dbElement) {
    NullCheckValidator()
        .then(IsClassValidator())
        .then(IsAbstractClassValidator())
        .then(IsDBValidator())
        .check(dbElement);
  }

  String _generateCodeForGetDB(String dbName) {
    return '''
static Future<$dbName> get$dbName({String? path}) async {
  if (${dbName.implClassName()}.get().getDB() == null) {
    await ${dbName.implClassName()}.get().initialize(path: path);
  }
  return ${dbName.implClassName()}.get();
}
 
''';
  }
}

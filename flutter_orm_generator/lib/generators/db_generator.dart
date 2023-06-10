import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/db_code_generator_adapter.dart';
import 'package:source_gen/source_gen.dart';

class DBGenerator extends GeneratorForAnnotation<DB> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return CodeGeneratorBuilder(DBCodeGeneratorAdapter(annotation, buildStep))
        .element(element)
        .generate();
  }
}

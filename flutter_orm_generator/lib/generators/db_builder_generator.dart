import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/db_builder_code_generator_adapter.dart';
import 'package:source_gen/source_gen.dart';

class DBBuilderGenerator extends GeneratorForAnnotation<DBBuilder> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return CodeGeneratorBuilder(
            DBBuilderCodeGeneratorAdapter(annotation, buildStep))
        .element(element)
        .generate();
  }
}

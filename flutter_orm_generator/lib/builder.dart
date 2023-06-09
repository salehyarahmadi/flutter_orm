import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'generators/db_builder_generator.dart';
import 'generators/db_generator.dart';

Builder dbBuilder(BuilderOptions options) =>
    LibraryBuilder(DBGenerator(), generatedExtension: '.db.dart');

Builder dbBuilderBuilder(BuilderOptions options) =>
    LibraryBuilder(DBBuilderGenerator(), generatedExtension: '.dbbuilder.dart');

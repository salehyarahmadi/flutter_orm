import 'package:example/db/note_db.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';

part 'database_builder.dbbuilder.dart';

@DBBuilder(databases: [NoteDB])
abstract class DatabaseBuilder {}

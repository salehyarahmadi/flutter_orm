import 'package:example/db/note_db.dart';
import 'package:flutter_orm/flutter_orm.dart';

part 'database_builder.dbbuilder.dart';

@DBBuilder(databases: [NoteDB])
abstract class DatabaseBuilder {}

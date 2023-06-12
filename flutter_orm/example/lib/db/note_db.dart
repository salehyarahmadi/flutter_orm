import 'package:example/converters/converters.dart';
import 'package:example/dao/note_dao.dart';
import 'package:example/entities/note.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/db_config/db_config.dart';
import 'package:sqflite/sqflite.dart';

part 'note_db.db.dart';

@DB(
  name: 'note_db',
  version: 1,
  readOnly: false,
  singleInstance: true,
  entities: [Note],
)
@TypeConverters(Converters)
abstract class NoteDB implements OnCreate, OnUpgrade {
  NoteDao noteDao();

  @override
  Future<void> onCreate(Database? db, int version) async {
    print('OnCreate');
  }

  @override
  Future<void> onUpgrade(Database? db, int oldVersion, int newVersion) async {
    print('Migration');
  }
}

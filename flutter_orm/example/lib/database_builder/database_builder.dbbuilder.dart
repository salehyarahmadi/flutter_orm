// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DBBuilderGenerator
// **************************************************************************

part of 'database_builder.dart';

class DBContext {
  static Future<NoteDB> getNoteDB({String? path}) async {
    if (NoteDBImpl.get().getDB() == null) {
      await NoteDBImpl.get().initialize(path: path);
    }
    return NoteDBImpl.get();
  }
}

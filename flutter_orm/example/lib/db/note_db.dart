import 'package:example/converters/converters.dart';
import 'package:example/custom_objects/custom_note.dart';
import 'package:example/dao/note_dao.dart';
import 'package:example/entities/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orm/flutter_orm.dart';
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
abstract class NoteDB {
  NoteDao noteDao();

  @OnUpgrade()
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('onUpgrade');
  }

  @OnDowngrade()
  Future<void> onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('onDowngrade');
  }

  @OnConfigure()
  Future<void> onConfigure(Database db) async {
    print('onConfigure');
  }

  @OnOpen()
  Future<void> onOpen(Database db) async {
    print('onOpen');
  }
}

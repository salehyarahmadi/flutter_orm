// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DBGenerator
// **************************************************************************

part of 'note_db.dart';

class ConvertersHelper {
  static TimeOfDay? toNullableTimeOfDay(value) {
    return Converters.function1(value as String?);
  }

  static String? fromNullableTimeOfDay(value) {
    return Converters.function2(value as TimeOfDay?);
  }
}

class NoteDBImpl extends NoteDB {
  static final NoteDBImpl _instance = NoteDBImpl._internal();

  NoteDBImpl._internal();

  static NoteDBImpl get() {
    return _instance;
  }

  Database? _database;

  Future<Database?> initialize({String? path}) async {
    if (_database == null) {
      var databasesPath = path ?? (await getDatabasesPath() + "/note_db.db");
      _database = await openDatabase(
        databasesPath,
        version: 1,
        readOnly: false,
        singleInstance: true,
        onConfigure: onConfigure,
        onOpen: onOpen,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade,
        onCreate: (db, version) async {
          Batch batch = db.batch();
          batch.execute(NoteHelper.queryBuilder());
          batch.execute(NoteHelper.indicesBuilder());
          await batch.commit();
        },
      );
    }
    return _database;
  }

  Database? getDB() {
    return _database;
  }

  @override
  NoteDao noteDao() {
    return NoteDaoImpl(getDB());
  }
}

class NoteHelper {
  static const String tableName = 'Note';

  static String queryBuilder() {
    return """
CREATE TABLE Note(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  text TEXT NOT NULL,
	isEdited INTEGER NOT NULL,
	createDate TEXT NOT NULL,
	updateDate TEXT,
	lat REAL,
	lng REAL,
	addr_city TEXT,
	addr_streeeeeeet TEXT,
	addr_addrName_nameOfAddress TEXT,
	addr_addrName_flag INTEGER
);
""";
  }

  static String indicesBuilder() {
    return """
    CREATE UNIQUE INDEX idx_Note_text
ON Note (text);

""";
  }

  static Note fromJson(Map<String, Object?> data) {
    return Note(
      id: data['id'] as int?,
      text: data['text'] as String,
      isEdited: PredefinedConvertersHelper.to('bool', data['isEdited']),
      createDate: PredefinedConvertersHelper.to('DateTime', data['createDate']),
      updateDate:
          PredefinedConvertersHelper.to('DateTime?', data['updateDate']),
      latitude: PredefinedConvertersHelper.to('double?', data['lat']),
      longitude: PredefinedConvertersHelper.to('double?', data['lng']),
      address: addressFromJson(data),
    );
  }

  static AddressName? addressNameFromJson(Map<String, Object?> data) {
    if (data['addr_addrName_nameOfAddress'] == null) return null;
    if (data['addr_addrName_flag'] == null) return null;

    return AddressName(
      name: data['addr_addrName_nameOfAddress'] as String,
      flag: PredefinedConvertersHelper.to('bool', data['addr_addrName_flag']),
    );
  }

  static Address? addressFromJson(Map<String, Object?> data) {
    if (data['addr_city'] == null) return null;

    if (addressNameFromJson(data) == null) return null;

    return Address(
      city: data['addr_city'] as String,
      street: data['addr_streeeeeeet'] as String?,
      addressName: addressNameFromJson(data)!,
    );
  }

  static Map<String, Object?> toJson(Note entity) {
    return {
      'text': entity.text,
      'isEdited': PredefinedConvertersHelper.from('bool', entity.isEdited),
      'createDate':
          PredefinedConvertersHelper.from('DateTime', entity.createDate),
      'updateDate':
          PredefinedConvertersHelper.from('DateTime?', entity.updateDate),
      'lat': PredefinedConvertersHelper.from('double?', entity.latitude),
      'lng': PredefinedConvertersHelper.from('double?', entity.longitude),
      'addr_city': entity.address?.city,
      'addr_streeeeeeet': entity.address?.street,
      'addr_addrName_nameOfAddress': entity.address?.addressName.name,
      'addr_addrName_flag': PredefinedConvertersHelper.from(
          'bool?', entity.address?.addressName.flag),
    };
  }
}

class NoteDaoImpl implements NoteDao {
  final Database? db;

  NoteDaoImpl(this.db);

  @override
  Future<void> insert(Note note, {Transaction? txn}) async {
    var executor = txn ?? db;
    await executor?.insert(
      NoteHelper.tableName,
      NoteHelper.toJson(note),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<void> bulkInsert(List<Note> notes, {Transaction? txn}) async {
    var executor = txn ?? db;
    if (executor != null) {
      var batch = executor.batch();
      for (var e in notes) {
        batch.insert(
          NoteHelper.tableName,
          NoteHelper.toJson(e),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit();
    }
  }

  @override
  Future<void> update(Note note, {Transaction? txn}) async {
    if (note.id != null) {
      var executor = txn ?? db;
      await executor?.update(
        NoteHelper.tableName,
        NoteHelper.toJson(note),
        where: 'id = ?',
        whereArgs: [note.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> bulkUpdate(List<Note> notes, {Transaction? txn}) async {
    var executor = txn ?? db;
    if (executor != null) {
      var batch = executor.batch();
      for (var e in notes) {
        executor.update(
          NoteHelper.tableName,
          NoteHelper.toJson(e),
          where: 'id = ?',
          whereArgs: [e.id],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit();
    }
  }

  @override
  Future<void> delete(Note note, {Transaction? txn}) async {
    if (note.id != null) {
      var executor = txn ?? db;
      await executor?.delete(
        'Note',
        where: 'id = ?',
        whereArgs: [note.id],
      );
    }
  }

  @override
  Future<List<Note>> all({Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select * from Note
''');

    List<Note> list = [];
    for (var record in records ?? []) {
      list.add(NoteHelper.fromJson(record));
    }
    return list;
  }

  @override
  Future<void> deleteAll({Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
delete from Note
''');
  }

  @override
  Future<void> deleteById(int id, {Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
delete from Note where id = "$id"
''');
  }

  @override
  Future<Note?> getById(int id, {Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select * from Note where id= "$id"
''');

    if (records?.isNotEmpty ?? false) {
      return NoteHelper.fromJson(records![0]);
    }
  }

  @override
  Future<int?> count({Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select count(*) from Note
''');

    return (records?[0][records[0].keys.first]) as int?;
  }

  @override
  Future<List<Note>> getNotes(bool isEdited, {Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select * from Note where isEdited= "${PredefinedConvertersHelper.from("bool", isEdited)}"
''');

    List<Note> list = [];
    for (var record in records ?? []) {
      list.add(NoteHelper.fromJson(record));
    }
    return list;
  }

  @override
  Future<List<Note>> getNotesByIds(List<int> ids, {Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select * from Note where id IN (${ids.map((e) => "$e").toList().join(",")})
''');

    List<Note> list = [];
    for (var record in records ?? []) {
      list.add(NoteHelper.fromJson(record));
    }
    return list;
  }

  @override
  Future<List<Note>> getNotesByLatitudes(List<double> lats,
      {Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select * from Note where lat IN (${lats.map((e) => "${PredefinedConvertersHelper.from("double", e)}").toList().join(",")})
''');

    List<Note> list = [];
    for (var record in records ?? []) {
      list.add(NoteHelper.fromJson(record));
    }
    return list;
  }

  @override
  Future<RawData> search(String search, {Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select * from Note where text LIKE '%$search%'
''');

    return RawData(records);
  }

  @override
  Future<List<double>> getLatitudes({Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select lat from Note
''');

    List<double> list = [];
    for (var record in records ?? []) {
      list.add(PredefinedConvertersHelper.to(
        "double",
        record[record.keys.first],
      ));
    }
    return list;
  }

  @override
  Future<List<CustomNote>> getCustomNotes({Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select id, text, lat, createDate from Note
''');

    List<CustomNote> list = [];
    for (var record in records ?? []) {
      list.add(CustomNote(
        id: record['id'] as int,
        text: record['text'] as String,
        latitude: PredefinedConvertersHelper.to('double', record['lat']),
        createDate:
            PredefinedConvertersHelper.to('DateTime', record['createDate']),
      ));
    }
    return list;
  }

  @override
  Future<CustomNote?> getCustomNoteById(int id, {Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
select id, text, lat, createDate from Note where id= "$id"
''');

    if (records?.isNotEmpty ?? false) {
      return CustomNote(
        id: records?[0]['id'] as int,
        text: records?[0]['text'] as String,
        latitude: PredefinedConvertersHelper.to('double', records?[0]['lat']),
        createDate: PredefinedConvertersHelper.to(
            'DateTime', records?[0]['createDate']),
      );
    }
  }

  @override
  Future<TimeOfDay?> getTimeOfDay({Transaction? txn}) async {
    var executor = txn ?? db;
    List<Map<String, Object?>>? records = await executor?.rawQuery('''
test
''');

    if (records?.isNotEmpty ?? false) {
      return ConvertersHelper.toNullableTimeOfDay(
          records?[0][records[0].keys.first]);
    }
  }

  @override
  Future<void> insertAndDelete(Note newNote, Note oldNote) async {
    db?.transaction((txn) async {
      await insert(newNote, txn: txn);
      await delete(oldNote, txn: txn);
    });
  }

  @override
  Future<void> insertAndDeleteById(Note newNote, int noteId) async {
    db?.transaction((txn) async {
      await insert(newNote, txn: txn);
      await deleteById(noteId, txn: txn);
    });
  }
}

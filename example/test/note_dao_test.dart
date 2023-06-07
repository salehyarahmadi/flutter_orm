import 'package:example/dao/note_dao.dart';
import 'package:example/database_builder/database_builder.dart';
import 'package:example/db/note_db.dart';
import 'package:example/entities/note.dart';
import 'package:flutter_orm/utils/raw_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  late NoteDB database;
  late NoteDao dao;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    database = await DBContext.getNoteDB(path: inMemoryDatabasePath);
    dao = database.noteDao();
  });

  test('count test', () async {
    expect(await dao.count(), 0);
  });

  test('single insert test', () async {
    DateTime now = DateTime.now();
    Note note = Note(
      text: 'Test Note',
      isEdited: false,
      createDate: now,
      latitude: 1.1,
    );

    dao.insert(note);
    expect(await dao.count(), 1);

    Note? insertedNote = await dao.getById(1);
    expect(insertedNote, isNot(null));
    expect(insertedNote!.text, note.text);
    expect(insertedNote.isEdited, note.isEdited);
    expect(insertedNote.createDate, note.createDate);
    expect(insertedNote.latitude, note.latitude);
    expect(insertedNote.updateDate, note.updateDate);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('bulk insert test', () async {
    dao.bulkInsert([
      Note(
        text: 'Bulk Insert Test 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
      ),
      Note(
        text: 'Bulk Insert Test 2',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
      ),
    ]);
    expect(await dao.count(), 2);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('single update test', () async {
    DateTime now = DateTime.now();
    Note note = Note(
      text: 'Test Note',
      isEdited: false,
      createDate: now,
      latitude: 1.5,
    );

    dao.insert(note);
    expect(await dao.count(), 1);

    Note insertedNote = (await dao.all()).first;
    expect(insertedNote, isNot(null));

    Note newNote = Note(
      id: insertedNote.id,
      text: 'Test Note(edited)',
      isEdited: true,
      createDate: now,
      latitude: 1.6,
      updateDate: DateTime.now(),
    );
    await dao.update(newNote);
    expect(await dao.count(), 1);
    Note updatedNote = (await dao.all()).first;
    expect(updatedNote, isNot(null));
    expect(updatedNote.id, newNote.id);
    expect(updatedNote.text, newNote.text);
    expect(updatedNote.isEdited, newNote.isEdited);
    expect(updatedNote.createDate, newNote.createDate);
    expect(updatedNote.latitude, newNote.latitude);
    expect(updatedNote.updateDate, newNote.updateDate);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('bulk update test', () async {
    List<Note> insertNotes = [
      Note(
        text: 'Bulk Update Test 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
      ),
      Note(
        text: 'Bulk Update Test 2',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
      ),
    ];
    dao.bulkInsert(insertNotes);
    expect(await dao.count(), 2);

    var all = await dao.all();
    int? firstId = all[0].id;
    int? secondId = all[1].id;
    List<Note> updateNotes = [
      Note(
        id: firstId,
        text: 'Bulk Update Test 1(edited)',
        isEdited: true,
        createDate: insertNotes[0].createDate,
        latitude: 0.55,
        updateDate: DateTime.now(),
      ),
      Note(
        id: secondId,
        text: 'Bulk Update Test 2(edited)',
        isEdited: true,
        createDate: insertNotes[1].createDate,
        latitude: 0.66,
        updateDate: DateTime.now(),
      ),
    ];

    await dao.bulkUpdate(updateNotes);
    expect(await dao.count(), 2);
    for (var e in (await dao.all())) {
      expect(e.isEdited, true);
    }

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('delete test', () async {
    dao.insert(Note(
      text: 'Test Note',
      isEdited: false,
      createDate: DateTime.now(),
      latitude: 0.5,
    ));
    expect(await dao.count(), 1);

    await dao.delete((await dao.all()).first);
    expect(await dao.count(), 0);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('getNotes by isEdited flag test', () async {
    dao.bulkInsert([
      Note(
        text: 'Test Note 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
      ),
      Note(
        text: 'Test Note 2',
        isEdited: true,
        createDate: DateTime.now(),
        latitude: 0.6,
      ),
    ]);
    expect(await dao.count(), 2);

    List<Note> editedNotes = await dao.getNotes(true);
    expect(editedNotes.length, 1);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('insertAndDelete transaction test', () async {
    Note note = Note(
      text: 'Old Note',
      isEdited: false,
      createDate: DateTime.now(),
    );
    await dao.insert(note);
    expect(await dao.count(), 1);

    Note oldNote = (await dao.all()).first;
    Note newNote = Note(
      text: 'New Note',
      isEdited: false,
      createDate: DateTime.now(),
    );

    await dao.insertAndDelete(newNote, oldNote);
    expect(await dao.count(), 1);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('pass list of int as parameter to dao method test', () async {
    dao.bulkInsert([
      Note(
        text: 'Test Note 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
      ),
      Note(
        text: 'Test Note 2',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
      ),
      Note(
        text: 'Test Note 3',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.7,
      ),
    ]);
    expect(await dao.count(), 3);

    List<Note> notes = await dao.all();
    List<int> ids = notes.map((e) => e.id!).toList();
    List<int> searchIds = [ids[0], ids[1]];
    List<Note> searchedNotes = await dao.getNotesByIds(searchIds);
    expect(searchedNotes.length, 2);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('pass list of double as parameter to dao method test', () async {
    dao.bulkInsert([
      Note(
        text: 'Test Note 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
      ),
      Note(
        text: 'Test Note 2',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
      ),
      Note(
        text: 'Test Note 3',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.7,
      ),
    ]);
    expect(await dao.count(), 3);

    List<Note> searchedNotes = await dao.getNotesByLatitudes([0.5, 0.7]);
    expect(searchedNotes.length, 2);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('RawData in dao return type result test', () async {
    dao.bulkInsert([
      Note(
        text: 'Simple Note 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
      ),
      Note(
        text: 'Simple Note 2',
        isEdited: true,
        createDate: DateTime.now(),
        latitude: 0.6,
      ),
      Note(
        text: 'Note 3',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.7,
      ),
    ]);
    expect(await dao.count(), 3);

    RawData result = await dao.search('Simple');
    expect(result, isNotNull);
    expect(result.data, isNotNull);
    expect(result.data!.length, 2);
    expect(result.data![0]['text'], 'Simple Note 1');
    expect(result.data![0]['isEdited'], 0);
    expect(result.data![0]['lat'], 0.5);
    expect(result.data![1]['text'], 'Simple Note 2');
    expect(result.data![1]['isEdited'], 1);
    expect(result.data![1]['lat'], 0.6);

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });

  test('unique text by index test', () async {
    dao.insert(
      Note(
        text: 'Test Note',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
      ),
    );
    expect(await dao.count(), 1);

    List<Note> notes = await dao.all();
    Note insertedNote = notes.first;

    int? insertedNoteId = insertedNote.id;

    dao.insert(
      Note(
        text: 'Test Note',
        isEdited: true,
        createDate: DateTime.now(),
        latitude: 0.4,
      ),
    );

    expect(await dao.count(), 1);

    Note? searchedNote = await dao.getById(insertedNoteId!);
    expect(searchedNote, isNot(null));

    await dao.deleteAll();
    expect(await dao.count(), 0);
  });
}

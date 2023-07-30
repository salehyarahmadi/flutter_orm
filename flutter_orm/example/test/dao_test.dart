import 'package:example/dao/note_dao.dart';
import 'package:example/dao/user_dao.dart';
import 'package:example/database_builder/database_builder.dart';
import 'package:example/db/note_db.dart';
import 'package:example/entities/note.dart';
import 'package:flutter_orm/utils/raw_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  late NoteDB database;
  late NoteDao noteDao;
  late UserDao userDao;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    database = await DBContext.getNoteDB(path: inMemoryDatabasePath);
    noteDao = database.noteDao();
    userDao = database.userDao();
  });

  test('count test', () async {
    expect(await noteDao.count(), 0);
  });

  Future<int> insertTestUserAndGetId() async {
    User user = User(name: 'Test User');
    await userDao.insert(user);
    expect(await userDao.count(), 1);

    List<User> users = await userDao.all();
    User insertedUser = users.first;
    expect(insertedUser, isNot(null));
    expect(insertedUser.id, isNot(null));

    return insertedUser.id!;
  }

  Future deleteAllUsers() async {
    await userDao.deleteAll();
    expect(await userDao.count(), 0);
  }

  test('single insert test', () async {
    DateTime now = DateTime.now();
    int userId = await insertTestUserAndGetId();
    Note note = Note(
      text: 'Test Note',
      isEdited: false,
      createDate: now,
      latitude: 1.1,
      userId: userId,
    );

    noteDao.insert(note);
    expect(await noteDao.count(), 1);

    Note? insertedNote = await noteDao.getById(1);
    expect(insertedNote, isNot(null));
    expect(insertedNote!.text, note.text);
    expect(insertedNote.isEdited, note.isEdited);
    expect(insertedNote.createDate, note.createDate);
    expect(insertedNote.latitude, note.latitude);
    expect(insertedNote.updateDate, note.updateDate);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('bulk insert test', () async {
    int userId = await insertTestUserAndGetId();
    noteDao.bulkInsert([
      Note(
        text: 'Bulk Insert Test 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
        userId: userId,
      ),
      Note(
        text: 'Bulk Insert Test 2',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
        userId: userId,
      ),
    ]);
    expect(await noteDao.count(), 2);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('single update test', () async {
    int userId = await insertTestUserAndGetId();
    DateTime now = DateTime.now();
    Note note = Note(
      text: 'Test Note',
      isEdited: false,
      createDate: now,
      latitude: 1.5,
      userId: userId,
    );

    noteDao.insert(note);
    expect(await noteDao.count(), 1);

    Note insertedNote = (await noteDao.all()).first;
    expect(insertedNote, isNot(null));

    Note newNote = Note(
      id: insertedNote.id,
      text: 'Test Note(edited)',
      isEdited: true,
      createDate: now,
      latitude: 1.6,
      updateDate: DateTime.now(),
      userId: userId,
    );
    await noteDao.update(newNote);
    expect(await noteDao.count(), 1);
    Note updatedNote = (await noteDao.all()).first;
    expect(updatedNote, isNot(null));
    expect(updatedNote.id, newNote.id);
    expect(updatedNote.text, newNote.text);
    expect(updatedNote.isEdited, newNote.isEdited);
    expect(updatedNote.createDate, newNote.createDate);
    expect(updatedNote.latitude, newNote.latitude);
    expect(updatedNote.updateDate, newNote.updateDate);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('bulk update test', () async {
    int userId = await insertTestUserAndGetId();
    List<Note> insertNotes = [
      Note(
        text: 'Bulk Update Test 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
        userId: userId,
      ),
      Note(
        text: 'Bulk Update Test 2',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
        userId: userId,
      ),
    ];
    noteDao.bulkInsert(insertNotes);
    expect(await noteDao.count(), 2);

    var all = await noteDao.all();
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
        userId: userId,
      ),
      Note(
        id: secondId,
        text: 'Bulk Update Test 2(edited)',
        isEdited: true,
        createDate: insertNotes[1].createDate,
        latitude: 0.66,
        updateDate: DateTime.now(),
        userId: userId,
      ),
    ];

    await noteDao.bulkUpdate(updateNotes);
    expect(await noteDao.count(), 2);
    for (var e in (await noteDao.all())) {
      expect(e.isEdited, true);
    }

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('delete test', () async {
    int userId = await insertTestUserAndGetId();
    noteDao.insert(Note(
      text: 'Test Note',
      isEdited: false,
      createDate: DateTime.now(),
      latitude: 0.5,
      userId: userId,
    ));
    expect(await noteDao.count(), 1);

    await noteDao.delete((await noteDao.all()).first);
    expect(await noteDao.count(), 0);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('getNotes by isEdited flag test', () async {
    int userId = await insertTestUserAndGetId();
    noteDao.bulkInsert([
      Note(
        text: 'Test Note 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
        userId: userId,
      ),
      Note(
        text: 'Test Note 2',
        isEdited: true,
        createDate: DateTime.now(),
        latitude: 0.6,
        userId: userId,
      ),
    ]);
    expect(await noteDao.count(), 2);

    List<Note> editedNotes = await noteDao.getNotes(true);
    expect(editedNotes.length, 1);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('insertAndDelete transaction test', () async {
    int userId = await insertTestUserAndGetId();
    Note note = Note(
      text: 'Old Note',
      isEdited: false,
      createDate: DateTime.now(),
      userId: userId,
    );
    await noteDao.insert(note);
    expect(await noteDao.count(), 1);

    Note oldNote = (await noteDao.all()).first;
    Note newNote = Note(
      text: 'New Note',
      isEdited: false,
      createDate: DateTime.now(),
      userId: userId,
    );

    await noteDao.insertAndDelete(newNote, oldNote);
    expect(await noteDao.count(), 1);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('pass list of int as parameter to dao method test', () async {
    int userId = await insertTestUserAndGetId();
    noteDao.bulkInsert([
      Note(
        text: 'Test Note 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
        userId: userId,
      ),
      Note(
        text: 'Test Note 2',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
        userId: userId,
      ),
      Note(
        text: 'Test Note 3',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.7,
        userId: userId,
      ),
    ]);
    expect(await noteDao.count(), 3);

    List<Note> notes = await noteDao.all();
    List<int> ids = notes.map((e) => e.id!).toList();
    List<int> searchIds = [ids[0], ids[1]];
    List<Note> searchedNotes = await noteDao.getNotesByIds(searchIds);
    expect(searchedNotes.length, 2);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('pass list of double as parameter to dao method test', () async {
    int userId = await insertTestUserAndGetId();
    noteDao.bulkInsert([
      Note(
        text: 'Test Note 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
        userId: userId,
      ),
      Note(
        text: 'Test Note 2',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
        userId: userId,
      ),
      Note(
        text: 'Test Note 3',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.7,
        userId: userId,
      ),
    ]);
    expect(await noteDao.count(), 3);

    List<Note> searchedNotes = await noteDao.getNotesByLatitudes([0.5, 0.7]);
    expect(searchedNotes.length, 2);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('RawData in dao return type result test', () async {
    int userId = await insertTestUserAndGetId();
    noteDao.bulkInsert([
      Note(
        text: 'Simple Note 1',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.5,
        userId: userId,
      ),
      Note(
        text: 'Simple Note 2',
        isEdited: true,
        createDate: DateTime.now(),
        latitude: 0.6,
        userId: userId,
      ),
      Note(
        text: 'Note 3',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.7,
        userId: userId,
      ),
    ]);
    expect(await noteDao.count(), 3);

    RawData result = await noteDao.search('Simple');
    expect(result, isNotNull);
    expect(result.data, isNotNull);
    expect(result.data!.length, 2);
    expect(result.data![0]['text'], 'Simple Note 1');
    expect(result.data![0]['isEdited'], 0);
    expect(result.data![0]['lat'], 0.5);
    expect(result.data![1]['text'], 'Simple Note 2');
    expect(result.data![1]['isEdited'], 1);
    expect(result.data![1]['lat'], 0.6);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('unique text by index test', () async {
    int userId = await insertTestUserAndGetId();
    noteDao.insert(
      Note(
        text: 'Test Note',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
        userId: userId,
      ),
    );
    expect(await noteDao.count(), 1);

    List<Note> notes = await noteDao.all();
    Note insertedNote = notes.first;

    int? insertedNoteId = insertedNote.id;

    noteDao.insert(
      Note(
        text: 'Test Note',
        isEdited: true,
        createDate: DateTime.now(),
        latitude: 0.4,
        userId: userId,
      ),
    );

    expect(await noteDao.count(), 1);

    Note? searchedNote = await noteDao.getById(insertedNoteId!);
    expect(searchedNote, isNot(null));

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('embedded field test', () async {
    int userId = await insertTestUserAndGetId();
    String testCity = 'Test City';
    String testStreet = 'Test Street';
    String testAddressName = 'Test Address Name';
    bool testAddressFlag = true;
    noteDao.insert(
      Note(
        text: 'Test Note',
        isEdited: false,
        createDate: DateTime.now(),
        latitude: 0.6,
        address: Address(
          city: testCity,
          street: testStreet,
          addressName: AddressName(
            name: testAddressName,
            flag: testAddressFlag,
          ),
        ),
        userId: userId,
      ),
    );
    expect(await noteDao.count(), 1);

    List<Note> notes = await noteDao.all();
    Note insertedNote = notes.first;

    expect(insertedNote, isNot(null));
    expect(insertedNote.address, isNot(null));
    expect(insertedNote.address!.addressName, isNot(null));
    expect(insertedNote.address!.city, testCity);
    expect(insertedNote.address!.street, testStreet);
    expect(insertedNote.address!.addressName.name, testAddressName);
    expect(insertedNote.address!.addressName.flag, testAddressFlag);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    deleteAllUsers();
  });

  test('foreign key test', () async {
    User user = User(name: 'Test User');
    await userDao.insert(user);
    expect(await userDao.count(), 1);

    List<User> users = await userDao.all();
    User insertedUser = users.first;
    expect(insertedUser, isNot(null));
    expect(insertedUser.id, isNot(null));

    Note note = Note(
      text: 'Test Note',
      isEdited: false,
      createDate: DateTime.now(),
      latitude: 0.6,
      address: Address(
        city: 'Test City',
        street: 'Test Street',
        addressName: AddressName(
          name: 'Test Address Name',
          flag: true,
        ),
      ),
      userId: insertedUser.id!,
    );
    await noteDao.insert(note);
    List<Note> notes = await noteDao.all();
    Note insertedNote = notes.first;
    expect(insertedNote, isNot(null));

    await userDao.deleteById(insertedUser.id!);
    expect(await userDao.count(), 0);
    // on delete action is cascade, then note must be deleted
    expect(await noteDao.count(), 0);

    await noteDao.deleteAll();
    expect(await noteDao.count(), 0);
    await userDao.deleteAll();
    expect(await userDao.count(), 0);
  });
}

import 'package:example/database_builder/database_builder.dart';
import 'package:example/db/note_db.dart';
import 'package:example/entities/note.dart';
import 'package:example/pages/notes_list_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORM Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'ORM Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late NoteDB noteDB;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  void _initDB() {
    DBContext.getNoteDB().then((db) {
      noteDB = db;
      _insertMockNote().then((_) {
        Future.delayed(const Duration(seconds: 3)).then((value) {
          setState(() {
            _initialized = true;
          });
        });
      });
    });
  }

  Future<void> _insertMockNote() async {
    int count = await noteDB.noteDao().count() ?? 0;
    if (count > 0) return;
    DateTime now = DateTime.now();
    await noteDB.noteDao().bulkInsert([
      Note(
        text: 'Mock Note 1',
        createDate: now,
        isEdited: false,
      ),
      Note(
        text: 'Mock Note 2',
        createDate: now,
        isEdited: false,
      ),
    ]);
    print('mock notes inserted');
    await noteDB.noteDao().bulkUpdate([
      Note(
        id: 1,
        text: 'Mock Note 1 edited',
        latitude: 1.1,
        createDate: now,
        updateDate: DateTime.now(),
        isEdited: true,
      ),
      Note(
        id: 2,
        text: 'Mock Note 2 edited',
        latitude: 1.2,
        createDate: now,
        updateDate: DateTime.now(),
        isEdited: true,
      ),
    ]);
    print('mock notes updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _initialized ? 'NoteDB initialized' : 'Initializing NoteDB...',
              style: const TextStyle(fontSize: 20),
            ),
            if (_initialized)
              MaterialButton(
                child: const Text('Go To Notes App'),
                color: Colors.green,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotesListPage(noteDB),
                  ));
                },
              ),
          ],
        ),
      ),
    );
  }
}

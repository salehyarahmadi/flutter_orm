import 'package:example/dao/note_dao.dart';
import 'package:example/db/note_db.dart';
import 'package:example/entities/note.dart';
import 'package:flutter/material.dart';

class AddNotePage extends StatefulWidget {
  final NoteDB noteDB;

  const AddNotePage(this.noteDB, {Key? key}) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late NoteDao noteDao;

  @override
  void initState() {
    super.initState();
    noteDao = widget.noteDB.noteDao();
  }

  String _text = '';

  _addNote() {
    Note note = Note(
      text: _text,
      isEdited: false,
      createDate: DateTime.now(),
      latitude: 1.0521564564,
      longitude: 2.012144548,
    );
    noteDao.insert(note).then((value) {
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            TextFormField(
              onChanged: (value) {
                _text = value;
              },
            ),
            const SizedBox(height: 16),
            MaterialButton(
              child: const Text('Add'),
              color: Colors.green,
              textColor: Colors.white,
              onPressed: _addNote,
            ),
          ],
        ),
      ),
    );
  }
}

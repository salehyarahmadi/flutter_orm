import 'package:example/dao/note_dao.dart';
import 'package:example/db/note_db.dart';
import 'package:example/entities/note.dart';
import 'package:flutter/material.dart';

class EditNotePage extends StatefulWidget {
  final NoteDB noteDB;
  final Note note;

  const EditNotePage(
    this.noteDB, {
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late NoteDao noteDao;

  @override
  void initState() {
    super.initState();
    noteDao = widget.noteDB.noteDao();
  }

  String _text = '';

  _editNote() {
    Note note = Note(
      id: widget.note.id,
      text: _text,
      isEdited: true,
      createDate: widget.note.createDate,
      updateDate: DateTime.now(),
      latitude: widget.note.latitude,
    );
    noteDao.update(note).then((value) {
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.note.text,
              onChanged: (value) {
                _text = value;
              },
            ),
            const SizedBox(height: 16),
            MaterialButton(
              child: const Text('Edit'),
              color: Colors.green,
              textColor: Colors.white,
              onPressed: _editNote,
            ),
          ],
        ),
      ),
    );
  }
}

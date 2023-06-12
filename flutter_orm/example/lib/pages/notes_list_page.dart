import 'package:example/dao/note_dao.dart';
import 'package:example/db/note_db.dart';
import 'package:example/entities/note.dart';
import 'package:example/pages/add_note_page.dart';
import 'package:example/pages/edit_note_page.dart';
import 'package:example/pages/note_page.dart';
import 'package:flutter/material.dart';

class NotesListPage extends StatefulWidget {
  final NoteDB noteDB;

  const NotesListPage(this.noteDB, {Key? key}) : super(key: key);

  @override
  _NotesListPageState createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final List<Note> _notes = [];
  int _totalCount = 0;
  late NoteDao noteDao;

  @override
  void initState() {
    super.initState();
    noteDao = widget.noteDB.noteDao();
    _getNotes();
  }

  _getNotes() {
    noteDao.all().then((notes) {
      noteDao.count().then((totalCount) {
        setState(() {
          _totalCount = totalCount ?? 0;
          _notes.clear();
          _notes.addAll(notes);
        });
      });
    });
  }

  _deleteNote(int id) {
    noteDao.getById(id).then((note) {
      if (note != null) {
        noteDao.delete(note).then((value) {
          _getNotes();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddNotePage(widget.noteDB),
          ));
          if (result == true) {
            _getNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _notes.isEmpty
            ? const Center(
                child: Text('Empty'),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Total Notes Count: $_totalCount',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (BuildContext context, int index) {
                        return NoteWidget(
                          widget.noteDB,
                          note: _notes[index],
                          onDelete: (int id) {
                            _deleteNote(id);
                          },
                          onEdit: (Note note) async {
                            bool? result = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (context) =>
                                  EditNotePage(widget.noteDB, note: note),
                            ));
                            if (result == true) {
                              _getNotes();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class NoteWidget extends StatelessWidget {
  final NoteDB noteDB;
  final Note note;
  final Function(int id) onDelete;
  final Function(Note note) onEdit;

  const NoteWidget(
    this.noteDB, {
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.deepOrange,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.red,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '${note.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    note.text,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotePage(noteDB, id: note.id!),
                    ));
                  },
                  child: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => onEdit.call(note),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => onDelete.call(note.id!),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

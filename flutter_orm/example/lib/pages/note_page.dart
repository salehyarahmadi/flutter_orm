import 'package:example/dao/note_dao.dart';
import 'package:example/db/note_db.dart';
import 'package:example/entities/note.dart';
import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  final NoteDB noteDB;
  final int id;

  const NotePage(
    this.noteDB, {
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  Note? _note;
  late NoteDao noteDao;

  @override
  void initState() {
    super.initState();
    noteDao = widget.noteDB.noteDao();
    _getNote();
  }

  _getNote() {
    noteDao.getById(widget.id).then((note) {
      setState(() {
        _note = note;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        child: _note == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Note ID :',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: Colors.red,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            '${_note!.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_note!.isEdited)
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'edited',
                        style: TextStyle(fontSize: 14, color: Colors.green),
                      ),
                    ),
                  if (_note!.isEdited) const SizedBox(height: 16),
                  if (_note!.isEdited)
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Edit Date: ${_note!.updateDate.toString()}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.green),
                      ),
                    ),
                  if (_note!.isEdited) const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Latitude: ${_note!.latitude}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Longitude: ${_note!.longitude}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'AddressName: ${_note!.address?.addressName.name}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'City: ${_note!.address?.city}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Street: ${_note!.address?.city}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'AddressFlag: ${_note!.address?.addressName.flag}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      _note!.text,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

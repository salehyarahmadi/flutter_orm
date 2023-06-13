import 'package:example/custom_objects/custom_note.dart';
import 'package:example/entities/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orm/flutter_orm.dart';

@Dao()
abstract class NoteDao {
  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> insert(Note note);

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> bulkInsert(List<Note> notes);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> update(Note note);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> bulkUpdate(List<Note> notes);

  @Delete()
  Future<void> delete(Note note);

  @Query("select * from Note")
  Future<List<Note>> all();

  @Query("delete from Note")
  Future<void> deleteAll();

  @Query("delete from Note where id = :id")
  Future<void> deleteById(int id);

  @Query("select * from Note where id= :id")
  Future<Note?> getById(int id);

  @Query("select count(*) from Note")
  Future<int?> count();

  @Query("select * from Note where isEdited= :isEdited")
  Future<List<Note>> getNotes(bool isEdited);

  @Query("select * from Note where id IN (:ids)")
  Future<List<Note>> getNotesByIds(List<int> ids);

  @Query("select * from Note where lat IN (:lats)")
  Future<List<Note>> getNotesByLatitudes(List<double> lats);

  @Transactional(sequentialActions: ['insert', 'delete'])
  Future<void> insertAndDelete(
    @InsertParam() Note newNote,
    @DeleteParam() Note oldNote,
  );

  @Transactional(sequentialActions: ['insert', 'deleteById'])
  Future<void> insertAndDeleteById(
    @InsertParam() Note newNote,
    @QueryParam('deleteById', 'id') int noteId,
  );

  @Query("select * from Note where text LIKE '%:search%'")
  Future<RawData> search(String search);

  @Query("select lat from Note")
  Future<List<double>> getLatitudes();

  @Query("select id, text, lat, createDate from Note")
  @SingularReturnType(CustomNote)
  Future<List<CustomNote>> getCustomNotes();

  @Query("select id, text, lat, createDate from Note where id= :id")
  @SingularReturnType(CustomNote)
  Future<CustomNote?> getCustomNoteById(int id);

  @Query("test")
  Future<TimeOfDay?> getTimeOfDay();
}

import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/enums/on_conflict_strategy.dart';
import 'package:flutter_orm/utils/raw_data.dart';

/// Annotation for create data access object.
/// It must be applied on an abstract class.
/// In the class that this annotation applied on, you can
/// define methods for access and manipulate data in tables
/// ```dart
/// @Dao()
/// abstract class NoteDao {
///   // methods for access and manipulate data
/// }
/// ```
class Dao {
  const Dao();
}

/// Annotation for define an insert method.
/// Methods that annotated with this annotation can have only one
/// input parameter that is an [Entity] or List of an [Entity] and
/// cannot be nullable.
/// If the input parameter is [Entity], the return type can be Future<void> or
/// Future<int?>, but if the input parameter is List of [Entity], the return type
/// only can be Future<void>.
/// You can set [OnConflictStrategy] for when conflict occurs.
/// ```dart
///   @Insert(onConflict: OnConflictStrategy.ignore)
///   Future<void> insert(Note note);
///
///   @Insert(onConflict: OnConflictStrategy.ignore)
///   Future<void> bulkInsert(List<Note> notes);
/// ```
class Insert {
  static _InsertFields fields = const _InsertFields();
  final OnConflictStrategy? onConflict;

  const Insert({this.onConflict});
}

class _InsertFields {
  const _InsertFields();

  String get onConflict => 'onConflict';
}

/// Annotation for define an update method.
/// Methods that annotated with this annotation can have only one
/// input parameter that is an [Entity] or List of an [Entity] and
/// cannot be nullable.
/// If the input parameter is [Entity], the return type can be Future<void> or
/// Future<int?>, but if the input parameter is List of [Entity], the return type
/// only can be Future<void>.
/// You can set [OnConflictStrategy] for when conflict occurs.
/// ```dart
///   @Update(onConflict: OnConflictStrategy.replace)
///   Future<void> update(Note note);
///
///   @Update(onConflict: OnConflictStrategy.replace)
///   Future<void> bulkUpdate(List<Note> notes);
/// ```
class Update {
  static _UpdateFields fields = const _UpdateFields();
  final OnConflictStrategy? onConflict;

  const Update({this.onConflict});
}

class _UpdateFields {
  const _UpdateFields();

  String get onConflict => 'onConflict';
}

/// Annotation for define a delete method.
/// Methods that annotated with this annotation can have only one
/// input parameter that is an [Entity] and cannot be nullable.
/// The return type can be Future<void> or Future<int?>.
/// ```dart
///   @Delete()
///   Future<void> delete(Note note);
/// ```
class Delete {
  const Delete();
}

/// Annotation for define raw query for access or manipulate data.
/// You have to pass your raw query as a String to [query] property of
/// this annotation.
/// You have to detect the return type, yourself.
/// You can fetch raw results as List<Map<String, Object?>>? by using
/// [RawData] class as the return type.
/// Also, you can fetch results as a custom class. In this case you must
/// pass that custom class to the [SingularReturnType] annotation.
/// For better query, you can have any number of input parameters and
/// you can pass these parameters to query using the colon(:) symbol.
/// Examples:
/// ```dart
///   @Query("select * from Note")
///   Future<List<Note>> all();
///
///   @Query("delete from Note")
///   Future<void> deleteAll();
///
///   @Query("select * from Note where id= :id")
///   Future<Note?> getById(int id);
///
///   @Query("select count(*) from Note")
///   Future<int?> count();
///
///   @Query("select * from Note where isEdited= :isEdited")
///   Future<List<Note>> getNotes(bool isEdited);
///
///   @Query("select * from Note where id IN (:ids)")
///   Future<List<Note>> getNotesByIds(List<int> ids);
///
///   @Query("select * from Note where lat IN (:lats)")
///   Future<List<Note>> getNotesByLatitudes(List<double> lats);
///
///   @Query("select * from Note where text LIKE '%:search%'")
///   Future<RawData> search(String search);
///
///   @Query("select lat from Note")
///   Future<List<double>> getLatitudes();
///
///   @Query("select id, text, lat, createDate from Note")
///   @SingularReturnType(CustomNote)
///   Future<List<CustomNote>> getCustomNotes();
///
///   @Query("select id, text, lat, createDate from Note where id= :id")
///   @SingularReturnType(CustomNote)
///   Future<CustomNote?> getCustomNoteById(int id);
/// ```
class Query {
  static _QueryFields fields = const _QueryFields();
  final String query;

  const Query(this.query);
}

class _QueryFields {
  const _QueryFields();

  String get query => 'query';
}

class SingularReturnType {
  static _SingularReturnTypeFields fields = const _SingularReturnTypeFields();
  final Object type;

  const SingularReturnType(this.type);
}

class _SingularReturnTypeFields {
  const _SingularReturnTypeFields();

  String get type => 'type';
}

/// Annotation for define transaction on database.
/// For define transaction you have to use other dao methods name
/// as [sequentialActions] and pass required parameters by [InsertParam],
/// [UpdateParam], [DeleteParam] and [QueryParam] annotations.
/// The return type of these methods must be Future<void>
/// Example:
/// ```dart
/// @Dao()
/// abstract class NoteDao {
///   @Insert(onConflict: OnConflictStrategy.ignore)
///   Future<void> insert(Note note);
///
///   @Query("delete from Note where id = :id")
///   Future<void> deleteById(int id);
///
///   @Transactional(sequentialActions: ['insert', 'deleteById'])
///   Future<void> insertAndDeleteById(
///     @InsertParam() Note newNote,
///     @QueryParam('deleteById', 'id') int noteId,
///   );
/// }
/// ```
class Transactional {
  static _TransactionalFields fields = const _TransactionalFields();
  final List<String> sequentialActions;

  const Transactional({required this.sequentialActions});
}

class _TransactionalFields {
  const _TransactionalFields();

  String get sequentialActions => 'sequentialActions';
}

class InsertParam {
  const InsertParam();
}

class UpdateParam {
  const UpdateParam();
}

class DeleteParam {
  const DeleteParam();
}

class QueryParam {
  static _QueryParamFields fields = const _QueryParamFields();
  final String methodName;
  final String parameterName;

  const QueryParam(this.methodName, this.parameterName);
}

class _QueryParamFields {
  const _QueryParamFields();

  String get methodName => 'methodName';

  String get parameterName => 'parameterName';
}

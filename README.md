# flutter_orm

An annotation-based ORM for [Flutter](https://flutter.io) inspired by the [Room persistence library](https://developer.android.com/training/data-storage/room).
This library is based on [sqflite](https://github.com/tekartik/sqflite) and wrapped it for better APIs.
Supports Android, iOS and MacOS.

* Simple APIs for create DB, Entities
* Simple APIs for CRUD operations
* Supports transactions
* Supports custom type converters
* Supports migrations
* Supports embedded fields
* Supports foreign keys

Usage example: 
* [notes](https://github.com/salehyarahmadi/flutter_orm/tree/main/example): Simple flutter notes project working on Android/iOS

The library is in Beta and isn't completely stable.

## Getting Started

In your flutter project add the dependency:

```yml
dependencies:
  ...
  flutter_orm:
  sqflite:

dev_dependencies:
  ...
  flutter_orm_generator:
  build_runner:
```

For help getting started with Flutter, view the online
[documentation](https://flutter.io/).

## Import

```dart
import 'package:flutter_orm/flutter_orm.dart';
```

Note that, if you make any change in structure of database(include `DB`, `Dao`, `Entity` and etc), you have to run below command for apply changes.

```dart
flutter pub run build_runner build --delete-conflicting-outputs;
```

## Entity(Table)

For create an entity or table, you can use `@Entity` annotation on a class. 
You can set `tableName` and `indices` for this table, in this annotation.
If you don't set `tableName`, the class name will be set as the default name.
You have to set primary key for table by using `@PrimaryKey` annotation.
The entity must have exactly one primary key and only integer primary key can be auto generated.
Auto generated primary key must be nullable.
All properties of the class that this annotation applied on, map to a column in the table unless properties that `@Ignore` annotation are applied on. Default column name is property name. If you want to change it use `@Column` annotation and set `name` property.
Also you can set default value for columns using `defaultValue` property of `@Column` annotation.

```dart
@Entity(tableName: 'notes', indices: [
  Index(columns: ['text'], unique: true)
])
class Note {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String text;
  final bool isEdited;
  final DateTime createDate;
  final DateTime? updateDate;

  @Column(name: 'lat')
  final double? latitude;

  @Column(name: 'lng')
  final double? longitude;

  @Ignore()
  final String? ignoreTest;

  @Column(name: 'defaultValueTest1', defaultValue: 'test')
  final String? defaultValueTest1;

  @Column(name: 'defaultValueTest2', defaultValue: '0')
  final int? defaultValueTest2;

  Note({
    this.id,
    required this.text,
    required this.isEdited,
    required this.createDate,
    this.updateDate,
    this.latitude,
    this.longitude,
    this.ignoreTest,
    this.defaultValueTest1,
    this.defaultValueTest2,
  });
}
```

### Foreign Key
Foreign keys allows you to specify constraints across entities such that SQLite will ensure that the relationship is valid when you modify the database.
For define foreign key in entities, you have to set `foreignKeys` property of `@Entity` annotation and pass a list of `ForeignKey` instances to it.
A foreign key constraint can be deferred until the transaction is complete. This is useful if you are doing bulk inserts into the database
in a single transaction. By default, foreign key constraints are immediate but you can change this value by setting `deferred` to `true`.

```dart
@Entity()
class User {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;

  User({
    this.id,
    required this.name,
  });
}

@Entity(
  foreignKeys: [
    ForeignKey(
      entity: User,
      parentColumns: ['id'],
      childColumns: ['userId'],
      onDelete: ForeignKeyAction.CASCADE,
      onUpdate: ForeignKeyAction.CASCADE,
      deferred: false,
    )
  ],
)
class Note {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String text;

  final int userId;

  Note({
    this.id,
    required this.text,
    required this.userId,
  });
}
```

 `ForeignKey` class has these properties:
 * `entity` : The parent Entity to reference. It must be a class annotated with `@Entity` and referenced in the same database.
 * `parentColumns` : The list of column names in the parent Entity. Number of columns must match the number of columns specified in `childColumns`.
 * `childColumns` : The list of column names in the current Entity. Number of columns must match the number of columns specified in `parentColumns`.
 * `onDelete` : Action to take when the parent Entity is deleted from the database. Default value of `onDelete` is `ForeignKeyAction.NO_ACTION`.
 * `onUpdate` : Action to take when the parent Entity is updated in the database. Default value of `onUpdate` is `ForeignKeyAction.NO_ACTION`.
 * `deferred` : A foreign key constraint can be deferred until the transaction is complete. This is useful if you are doing bulk inserts into the database in a single transaction. By default, foreign key constraints are immediate but you can change it by setting this field to `true`.

#### By default, SQLite does not enforce foreign keys. This is usually necessary explicitly turning it on.
```dart
@DB(
  name: 'note_db',
  version: 1,
  entities: [Note, User],
)
abstract class NoteDB {
  @OnConfigure()
  Future<void> onConfigure(Database db) async {
    db.execute('PRAGMA foreign_keys = ON;');
  }
}
```


### Embedded Field
If you want to use an object that you have defined yourself, in your entity, you can use `@Embedded` annotation.
Suppose that the `Note` entity has an `address` property that is an object itself.
In this situation, you can use `@Embedded` annotation on that field.
Embedded objects also can have embedded fields.
Embedded object fields, can have `@Column` and `@Ignore` annotation, but they can't have `@PrimaryKey`.
You should note that the fields of embedded object, merge with entity fields in table.
For example, for the below entity, created table has these columns: `id`, `text`, `address_lat` and `address_lng`.
If you have noticed, embedded object fields has a prefix in its column name that is field name by default.
You can change this prefix by change `prefix` property of `@Embedded` annotation.

```dart
@Entity()
class Note {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String text;

  @Embedded()
  final Address? address;

  Note({
    this.id,
    required this.text,
    required this.isEdited,
    this.address,
  });
}

class Address {
  @Column(name: 'lat')
  final double latitude;

  @Column(name: 'lng')
  final double latitude;

  Address({
    required this.latitude,
    required this.latitude,
  });
}
```


## Database

For create a database, you can use `@DB` annotation on an abstract class. 
Database entities(tables) must be defined in this annotation.
Configuration methods like `OnConfigure`, `OnOpen`, `OnUpgrade` and `OnDowngrade` for actions like Migration can define in this class.

```dart
@DB(
  name: 'note_db',
  version: 1,
  entities: [Note],
)
abstract class NoteDB {
  @OnUpgrade()
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('onUpgrade');
  }

  @OnDowngrade()
  Future<void> onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('onDowngrade');
  }

  @OnConfigure()
  Future<void> onConfigure(Database db) async {
    print('onConfigure');
  }

  @OnOpen()
  Future<void> onOpen(Database db) async {
    print('onOpen');
  }
}
```

## Database Builder

For initialize databases and generate methods for access to databases, you have to define an abstract class with `@DBBuilder` annotation and pass databases class to `databases` paramater of `@DBBuilder` annotation.
You don't need to do anything extra.

```dart
@DBBuilder(databases: [NoteDB])
abstract class DatabaseBuilder {}
```

After define this class, you can create and access to database like this:

```dart
NoteDB db = await DBContext.getNoteDB();
```

Both `DB` and `DBBuilder` class, must be defined in separated files.
Also generated files for these classes, must be bind to original file using `part` keyword.

```dart
part 'filename.dbbuilder.dart'

@DBBuilder(databases: [NoteDB])
abstract class DatabaseBuilder {}
```

```dart
part 'filename.db.dart'

@DB(
  name: 'note_db',
  version: 1,
  entities: [Note],
)
abstract class NoteDB {}
```

## Dao

For Create `Dao`(Data Access Object) you can use `@Dao` annotation. `@Dao` annotation must apply on an abstract class.
In this class you can define methods for access and manipulate data in tables.

```dart
@Dao()
abstract class NoteDao {
  // methods for access and manipulate data
}
```

After define this class, you have to define an abstract method in your db class for access to this dao:

```dart
@DB(
  name: 'note_db',
  version: 1,
  entities: [Note],
)
abstract class NoteDB {
  NoteDao noteDao();
}
```

For access to dao, do like this:
```dart
NoteDB noteDB = await DBContext.getNoteDB();
final dao = noteDB.noteDao();
int count = await dao.count() ?? 0;
```

### Insert

For insert data in your tables, you can use `@Insert` annotation.
Methods that annotated with this annotation can have only one input parameter that is an `Entity` or List of an `Entity` and cannot be nullable.
If the input parameter is `Entity`, the return type can be `Future<void>` or `Future<int?>`, but if the input parameter is List of `Entity`, the return type only can be `Future<void>`.
You can set `OnConflictStrategy` for when conflict occurs.

```dart
@Dao()
abstract class NoteDao {
  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> insert(Note note);
  
  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> bulkInsert(List<Note> notes);
}
```

### Update

For update data in your tables, you can use `@Update` annotation.
Methods that annotated with this annotation can have only one input parameter that is an `Entity` or List of an `Entity` and cannot be nullable.
If the input parameter is `Entity`, the return type can be `Future<void>` or `Future<int?>`, but if the input parameter is List of `Entity`, the return type only can be `Future<void>`.
You can set `OnConflictStrategy` for when conflict occurs.

```dart
@Dao()
abstract class NoteDao {
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> update(Note note);
  
  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> bulkUpdate(List<Note> notes);
}
```

### Delete

For delete data in your tables, you can use `@Delete` annotation.
Methods that annotated with this annotation can have only one input parameter that is an `Entity` and cannot be nullable.
The return type can be `Future<void>` or `Future<int?>`.


```dart
@Dao()
abstract class NoteDao {
  @Delete()
  Future<void> delete(Note note);
}
```

### Query

For define raw query to access or manipulate your data, you can use `@Query` annotation.
You have to pass your raw query as a String to `query` property of this annotation. Also, you have to detect the return type, yourself.
You can fetch raw results as `List<Map<String, Object?>>?` by using `RawData` class as the return type.
Also, you can fetch results as a custom class. In this case you must pass that custom class to the `@SingularReturnType` annotation.
For better query, you can have any number of input parameters and you can pass these parameters to query using the `colon(:)` symbol.

```dart
@Dao()
abstract class NoteDao {
   @Query("select * from Note")
   Future<List<Note>> all();
   
   @Query("delete from Note")
   Future<void> deleteAll();
   
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
}
```

### Transaction

Transactions can define using `@Transactional` annotation.
For define transaction you have to use other dao methods name as `sequentialActions` and pass required parameters by `@InsertParam`, `@UpdateParam`, `@DeleteParam` and `@QueryParam` annotations. For example if the first method of the `sequentialActions` property, is an `insert` method, you have to define an input parameter with `@InsertParam` annotation and correct type based on original method.
`@QueryParam` has two arguments. The first is method name and the second is parameter name in original method.
The return type of these methods must be `Future<void>`.


```dart
@Dao()
abstract class NoteDao {
  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> insert(Note note);
  
  @Query("delete from Note where id = :id")
  Future<void> deleteById(int id);
  
  @Transactional(sequentialActions: ['insert', 'deleteById'])
  Future<void> insertAndDeleteById(
    @InsertParam() Note newNote,
    @QueryParam('deleteById', 'id') int noteId,
  );
}
```


## TypeConverter

If there are types that doesn't support internally, you can define these types yourself, using `@TypeConverter` annotation.
You can define a class and write methods for convert these types to a supported type. these methods must annotated with `@TypeConverter` annotation.

```dart
class Converters {
  @TypeConverter()
  static DateTime to(String value) {
    return DateTime.parse(value);
  }
  
  @TypeConverter()
  static String from(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
```

Note that you have to write both methods(`from` and `to`). After define these methods, you can use DateTime in your entities as a field.
Note that `DateTime` class, is support internally and you don't need define `TypeConverter` for that.
After that, you have to pass this class to your database class in `@TypeConverters` annotation.

```dart
@DB(
  name: 'note_db',
  version: 1,
  entities: [Note],
)
@TypeConverters(Converters)
abstract class NoteDB {
  // DAOs
}

```

## built-in types support:
* int
* num
* String
* Uint8List
* bool
* double
* DateTime

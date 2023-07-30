import 'package:example/entities/note.dart';
import 'package:flutter_orm/flutter_orm.dart';

@Dao()
abstract class UserDao {
  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> insert(User user);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> update(User user);

  @Query("select * from User where id= :id")
  Future<Note?> getById(int id);

  @Query("select * from User")
  Future<List<User>> all();

  @Query("select count(*) from User")
  Future<int?> count();

  @Delete()
  Future<void> delete(User user);

  @Query("delete from User")
  Future<void> deleteAll();

  @Query("delete from User where id = :id")
  Future<void> deleteById(int id);
}

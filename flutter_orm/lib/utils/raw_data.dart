/// If you want to fetch raw results as List<Map<String, Object?>>?
/// from a query in [Dao] class, you can use this class as return type of
/// a method in your [Dao] class.
/// Example:
/// ```dart
/// @Dao()
/// abstract class NoteDao {
///   @Query("select * from Note where text LIKE '%:search%'")
///   Future<RawData> search(String search);
/// }
/// ```
class RawData {
  final List<Map<String, Object?>>? data;

  const RawData(this.data);
}

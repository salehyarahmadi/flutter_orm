import 'package:flutter_orm/flutter_orm.dart';

@Entity(indices: [
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

  Note({
    this.id,
    required this.text,
    required this.isEdited,
    required this.createDate,
    this.updateDate,
    this.latitude,
    this.longitude,
    this.ignoreTest,
  });
}

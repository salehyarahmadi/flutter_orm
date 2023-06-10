import 'package:flutter_orm/annotations/entity_annotations.dart';

class CustomNote {
  @Column(name: 'id')
  final int id;

  @Column(name: 'text')
  final String text;

  @Column(name: 'lat')
  final double latitude;

  final DateTime createDate;

  const CustomNote({
    required this.id,
    required this.text,
    required this.latitude,
    required this.createDate,
  });
}

import 'package:flutter_orm/flutter_orm.dart';

@Entity(
  indices: [
    Index(columns: ['text'], unique: true)
  ],
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
  final bool isEdited;
  final DateTime createDate;
  final DateTime? updateDate;

  @Column(name: 'lat')
  final double? latitude;

  @Column(name: 'lng')
  final double? longitude;

  @Ignore()
  final String? ignoreTest;

  @Embedded(prefix: 'addr')
  final Address? address;

  final int userId;

  @Column(name: 'defaultValueTest1', defaultValue: 'dft')
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
    this.address,
    required this.userId,
    this.defaultValueTest1,
    this.defaultValueTest2,
  });
}

class Address {
  final String city;

  @Column(name: 'streeeeeeet')
  final String? street;

  @Embedded(prefix: 'addrName')
  final AddressName addressName;

  Address({
    required this.city,
    required this.street,
    required this.addressName,
  });
}

class AddressName {
  @Column(name: 'nameOfAddress')
  final String name;

  final bool flag;

  AddressName({required this.name, required this.flag});
}

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

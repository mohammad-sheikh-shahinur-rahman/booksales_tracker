// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 1;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      id: fields[0] as String,
      name: fields[1] as String,
      barcode: fields[2] as String?,
      costPrice: fields[3] as double,
      sellingPrice: fields[4] as double,
      stockQuantity: fields[5] as int,
      edition: fields[6] as String?,
      category: fields[7] as String?,
      isbn: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.barcode)
      ..writeByte(3)
      ..write(obj.costPrice)
      ..writeByte(4)
      ..write(obj.sellingPrice)
      ..writeByte(5)
      ..write(obj.stockQuantity)
      ..writeByte(6)
      ..write(obj.edition)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.isbn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

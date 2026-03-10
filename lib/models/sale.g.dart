// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 0;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale(
      id: fields[0] as String?,
      customerName: fields[1] as String,
      customerMobile: fields[2] as String,
      customerAddress: fields[3] as String?,
      customerCity: fields[4] as String?,
      bookName: fields[5] as String,
      bookEdition: fields[6] as String?,
      bookCategory: fields[7] as String?,
      salePrice: fields[8] as double,
      quantity: fields[9] as int,
      discount: fields[10] as double,
      paymentType: fields[11] as String,
      saleDate: fields[12] as DateTime,
      note: fields[13] as String?,
      costPrice: fields[14] as double,
      bookIsbn: fields[15] as String?,
      receivedAmount: fields[16] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.customerMobile)
      ..writeByte(3)
      ..write(obj.customerAddress)
      ..writeByte(4)
      ..write(obj.customerCity)
      ..writeByte(5)
      ..write(obj.bookName)
      ..writeByte(6)
      ..write(obj.bookEdition)
      ..writeByte(7)
      ..write(obj.bookCategory)
      ..writeByte(8)
      ..write(obj.salePrice)
      ..writeByte(9)
      ..write(obj.quantity)
      ..writeByte(10)
      ..write(obj.discount)
      ..writeByte(11)
      ..write(obj.paymentType)
      ..writeByte(12)
      ..write(obj.saleDate)
      ..writeByte(13)
      ..write(obj.note)
      ..writeByte(14)
      ..write(obj.costPrice)
      ..writeByte(15)
      ..write(obj.bookIsbn)
      ..writeByte(16)
      ..write(obj.receivedAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

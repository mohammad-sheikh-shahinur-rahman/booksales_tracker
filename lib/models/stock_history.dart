import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 3)
class StockHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bookId;

  @HiveField(2)
  final String bookName;

  @HiveField(3)
  final int changeAmount;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String type;

  @HiveField(6)
  final String? note;

  StockHistory({
    String? id,
    required this.bookId,
    required this.bookName,
    required this.changeAmount,
    required this.date,
    required this.type,
    this.note,
  }) : id = id ?? const Uuid().v4();
}

class StockHistoryAdapter extends TypeAdapter<StockHistory> {
  @override
  final int typeId = 3;

  @override
  StockHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockHistory(
      id: fields[0] as String,
      bookId: fields[1] as String,
      bookName: fields[2] as String,
      changeAmount: fields[3] as int,
      date: fields[4] as DateTime,
      type: fields[5] as String,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bookId)
      ..writeByte(2)
      ..write(obj.bookName)
      ..writeByte(3)
      ..write(obj.changeAmount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.note);
  }
}

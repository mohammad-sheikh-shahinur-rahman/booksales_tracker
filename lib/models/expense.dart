import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String? note;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  }) : id = id ?? const Uuid().v4();
}

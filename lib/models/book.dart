import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 1)
class Book extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? barcode;

  @HiveField(3)
  final double costPrice;

  @HiveField(4)
  final double sellingPrice;

  @HiveField(5)
  int stockQuantity;

  @HiveField(6)
  final String? edition;

  @HiveField(7)
  final String? category;

  @HiveField(8)
  final String? isbn;

  Book({
    required this.id,
    required this.name,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    this.stockQuantity = 0,
    this.edition,
    this.category,
    this.isbn,
  });

  double get potentialProfit => (sellingPrice - costPrice) * stockQuantity;
}

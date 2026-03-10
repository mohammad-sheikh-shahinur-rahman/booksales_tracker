import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'sale.g.dart';

@HiveType(typeId: 0)
class Sale extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final String customerMobile;

  @HiveField(3)
  final String? customerAddress;

  @HiveField(4)
  final String? customerCity;

  @HiveField(5)
  final String bookName;

  @HiveField(6)
  final String? bookEdition;

  @HiveField(7)
  final String? bookCategory;

  @HiveField(8)
  final double salePrice;

  @HiveField(9)
  final int quantity;

  @HiveField(10)
  final double discount;

  @HiveField(11)
  final String paymentType;

  @HiveField(12)
  final DateTime saleDate;

  @HiveField(13)
  final String? note;

  @HiveField(14)
  final double costPrice;

  @HiveField(15)
  final String? bookIsbn;

  @HiveField(16)
  final double? receivedAmount; // Made nullable to handle old data

  Sale({
    String? id,
    required this.customerName,
    required this.customerMobile,
    this.customerAddress,
    this.customerCity,
    required this.bookName,
    this.bookEdition,
    this.bookCategory,
    required this.salePrice,
    this.quantity = 1,
    this.discount = 0.0,
    required this.paymentType,
    required this.saleDate,
    this.note,
    this.costPrice = 0.0,
    this.bookIsbn,
    this.receivedAmount = 0.0,
  }) : id = id ?? const Uuid().v4();

  double get totalAmount => (salePrice * quantity) - discount;
  
  // Handled null safely for dueAmount
  double get dueAmount => totalAmount - (receivedAmount ?? totalAmount);
  
  double get totalCost => costPrice * quantity;
  double get profit => totalAmount - totalCost;
  
  // Safe received amount getter
  double get safeReceivedAmount => receivedAmount ?? totalAmount;
}

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'supplier.g.dart';

@HiveType(typeId: 4)
class Supplier extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String address;

  @HiveField(4)
  final double totalPurchaseAmount;

  @HiveField(5)
  final double totalPaidAmount;

  Supplier({
    String? id,
    required this.name,
    required this.phone,
    required this.address,
    this.totalPurchaseAmount = 0.0,
    this.totalPaidAmount = 0.0,
  }) : id = id ?? const Uuid().v4();

  double get dueAmount => totalPurchaseAmount - totalPaidAmount;
}

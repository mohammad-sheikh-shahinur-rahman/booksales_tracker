import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sale.dart';

class BackupService {
  static Future<void> createBackup(List<Sale> sales) async {
    try {
      final List<Map<String, dynamic>> jsonData = sales.map((sale) => {
        'id': sale.id,
        'customerName': sale.customerName,
        'customerMobile': sale.customerMobile,
        'customerAddress': sale.customerAddress,
        'customerCity': sale.customerCity,
        'bookName': sale.bookName,
        'bookEdition': sale.bookEdition,
        'bookCategory': sale.bookCategory,
        'salePrice': sale.salePrice,
        'quantity': sale.quantity,
        'discount': sale.discount,
        'paymentType': sale.paymentType,
        'saleDate': sale.saleDate.toIso8601String(),
        'note': sale.note,
      }).toList();

      final String jsonString = jsonEncode(jsonData);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/booksales_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)], text: 'Book Sales App Backup');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Sale>?> restoreBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final String content = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(content);

        return jsonData.map((item) => Sale(
          id: item['id'],
          customerName: item['customerName'],
          customerMobile: item['customerMobile'],
          customerAddress: item['customerAddress'],
          customerCity: item['customerCity'],
          bookName: item['bookName'],
          bookEdition: item['bookEdition'],
          bookCategory: item['bookCategory'],
          salePrice: item['salePrice'].toDouble(),
          quantity: item['quantity'] ?? 1,
          discount: item['discount'].toDouble(),
          paymentType: item['paymentType'],
          saleDate: DateTime.parse(item['saleDate']),
          note: item['note'],
        )).toList();
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}

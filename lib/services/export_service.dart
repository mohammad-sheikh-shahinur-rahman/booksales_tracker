import 'dart:io';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import '../models/sale.dart';

class ExportService {
  // 1. PDF Report Generation (HTML-to-PDF for perfect Bengali shaping)
  static Future<void> generatePdfReport({
    required String title,
    required List<Sale> sales,
  }) async {
    final totalAmount = sales.fold(0.0, (sum, item) => sum + item.totalAmount);
    final String dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

    String rowsHtml = "";
    for (var i = 0; i < sales.length; i++) {
      final sale = sales[i];
      rowsHtml += """
        <tr>
          <td style="text-align: center;">${DateFormat('dd/MM/yy').format(sale.saleDate)}</td>
          <td>${sale.bookName}</td>
          <td>${sale.customerName}</td>
          <td style="text-align: center;">${sale.quantity}</td>
          <td style="text-align: right;">${sale.totalAmount.toStringAsFixed(0)} টাকা</td>
        </tr>
      """;
    }

    final String htmlContent = """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;700&display=swap');
        body { font-family: 'Noto Sans Bengali', sans-serif; padding: 20px; color: #333; }
        .header { border-bottom: 2px solid #1E293B; padding-bottom: 10px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
        .header h1 { color: #1E293B; margin: 0; font-size: 22px; }
        .header p { margin: 5px 0; color: #666; font-size: 14px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background-color: #f1f5f9; color: #1E293B; border: 1px solid #cbd5e1; padding: 10px; font-size: 12px; }
        td { border: 1px solid #e2e8f0; padding: 10px; font-size: 12px; }
        .summary { margin-top: 30px; text-align: right; }
        .summary h2 { color: #1E293B; font-size: 18px; background: #f8fafc; display: inline-block; padding: 10px 20px; border-radius: 8px; }
        .footer { margin-top: 50px; text-align: center; font-size: 10px; color: #999; border-top: 1px solid #eee; padding-top: 10px; }
      </style>
    </head>
    <body>
      <div class="header">
        <div>
          <h1>আমাদের সমাজ প্রকাশনী</h1>
          <p>$title</p>
        </div>
        <div style="text-align: right;">
          <p>তারিখ: $dateStr</p>
        </div>
      </div>

      <table>
        <thead>
          <tr>
            <th width="80">তারিখ</th>
            <th>বইয়ের নাম</th>
            <th>ক্রেতার নাম</th>
            <th width="50">পরিমাণ</th>
            <th width="100">মোট টাকা</th>
          </tr>
        </thead>
        <tbody>
          $rowsHtml
        </tbody>
      </table>

      <div class="summary">
        <h2>সর্বমোট বিক্রয়: ${totalAmount.toStringAsFixed(0)} টাকা</h2>
      </div>

      <div class="footer">
        জেনারেটেড বাই: BookSales Tracker Pro | www.amadersonaj.com
      </div>
    </body>
    </html>
    """;

    await Printing.layoutPdf(
      onLayout: (format) async => await Printing.convertHtml(
        html: htmlContent,
        format: format,
      ),
      name: 'Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // 2. Excel Export Feature
  static Future<void> exportToExcel(List<Sale> sales) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sales Report'];
    excel.delete('Sheet1');

    CellStyle headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString("#1E293B"),
      fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    List<String> headers = ['তারিখ', 'ক্রেতার নাম', 'বইয়ের নাম', 'পরিমাণ', 'মূল্য', 'ডিসকাউন্ট', 'মোট টাকা', 'প্রাপ্ত টাকা', 'বাকি'];
    for (var i = 0; i < headers.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    for (var i = 0; i < sales.length; i++) {
      final sale = sales[i];
      final rowIndex = i + 1;
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = TextCellValue(DateFormat('dd/MM/yyyy').format(sale.saleDate));
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(sale.customerName);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue(sale.bookName);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = IntCellValue(sale.quantity);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = DoubleCellValue(sale.salePrice);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = DoubleCellValue(sale.discount);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = DoubleCellValue(sale.totalAmount);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value = DoubleCellValue(sale.receivedAmount ?? 0.0);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).value = DoubleCellValue(sale.dueAmount);
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/Sales_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)..createSync(recursive: true)..writeAsBytesSync(fileBytes);
      await Share.shareXFiles([XFile(filePath)], text: 'Sales Report Excel File');
    }
  }
}

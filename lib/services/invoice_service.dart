import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';

class InvoiceService {
  static const String _primaryColor = "#1E293B";

  static Future<String> _getLogoBase64() async {
    try {
      final ByteData bytes = await rootBundle.load('assets/image/img.png');
      final Uint8List list = bytes.buffer.asUint8List();
      return base64Encode(list);
    } catch (e) {
      return "";
    }
  }

  static const String _commonStyles = """
    <style>
      @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;700&display=swap');
      body { font-family: 'Noto Sans Bengali', Arial, sans-serif; margin: 0; padding: 20px; color: #333; line-height: 1.4; }
      .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid $_primaryColor; padding-bottom: 15px; }
      .company-info { display: flex; align-items: center; }
      .company-logo { width: 60px; height: 60px; margin-right: 15px; border-radius: 50%; }
      .company-text h1 { color: $_primaryColor; margin: 0; font-size: 24px; font-weight: 900; }
      .company-text p { margin: 2px 0; font-size: 12px; color: #666; }
      .badge { background: $_primaryColor; color: white; padding: 6px 15px; border-radius: 4px; font-weight: bold; font-size: 12px; text-transform: uppercase; }
      .info-grid { display: flex; justify-content: space-between; margin-bottom: 30px; background: #f8f9fa; padding: 15px; border-radius: 8px; }
      .info-box h3 { margin: 0 0 5px 0; font-size: 11px; text-transform: uppercase; color: #888; }
      .info-box p { margin: 0; font-size: 14px; font-weight: bold; }
      table { width: 100%; border-collapse: collapse; margin-top: 10px; }
      th { background: #f1f5f9; color: $_primaryColor; text-align: left; padding: 12px 10px; font-size: 12px; border-bottom: 2px solid #cbd5e1; }
      td { padding: 12px 10px; border-bottom: 1px solid #e2e8f0; font-size: 13px; }
      .total-section { margin-top: 30px; display: flex; justify-content: flex-end; }
      .total-table { width: 250px; }
      .total-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 13px; }
      .grand-total { border-top: 2px solid $_primaryColor; margin-top: 8px; padding-top: 10px; font-weight: bold; font-size: 16px; color: $_primaryColor; }
      .footer { margin-top: 60px; text-align: center; border-top: 1px solid #eee; padding-top: 20px; font-size: 11px; color: #999; }
      .signature-wrap { display: flex; justify-content: space-between; margin-top: 80px; }
      .sig-box { width: 160px; border-top: 1px solid #333; text-align: center; padding-top: 8px; font-size: 12px; font-weight: bold; }
    </style>
  """;

  static Future<void> _generateAndPrint(String htmlContent, String fileName) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => await Printing.convertHtml(
          html: "<html><head><meta charset='utf-8'></head><body>$htmlContent</body></html>",
          format: format,
        ),
        name: fileName,
      );
    } catch (e) {
      print("Invoice Generation Error: $e");
    }
  }

  static Future<void> generateCustomInvoice({
    required String customerName,
    required String customerMobile,
    String? customerAddress,
    required List<Map<String, dynamic>> items,
    required double discount,
    required double received,
  }) async {
    final settingsBox = Hive.box('settings');
    final pubName = settingsBox.get('pub_name', defaultValue: 'আমাদের সমাজ প্রকাশনী');
    final pubAddress = settingsBox.get('pub_address', defaultValue: '৩৮, বাংলাবাজার, ঢাকা-১১০০');
    final pubPhone = settingsBox.get('pub_phone', defaultValue: '০১৭xxxxxxxx');
    final logoBase64 = await _getLogoBase64();

    double subtotal = 0;
    String itemsHtml = "";
    
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final dynamic book = item['book'];
      final int qty = item['qty'] ?? 1;
      double price = 0;
      String name = "Unknown";
      
      if (book is Sale) {
        price = book.salePrice;
        name = book.bookName;
      } else {
        price = (book.sellingPrice ?? 0.0).toDouble();
        name = book.name ?? "Unknown Item";
      }

      double itemTotal = price * qty;
      subtotal += itemTotal;

      itemsHtml += """
        <tr>
          <td style="text-align: center;">${i + 1}</td>
          <td>$name</td>
          <td style="text-align: center;">$qty</td>
          <td style="text-align: right;">${price.toStringAsFixed(0)} টাকা</td>
          <td style="text-align: right;">${itemTotal.toStringAsFixed(0)} টাকা</td>
        </tr>
      """;
    }

    double total = subtotal - discount;
    double due = total - received;

    final String htmlContent = """
      $_commonStyles
      <div class="header">
        <div class="company-info">
          <img src="data:image/png;base64,$logoBase64" class="company-logo" onerror="this.style.display='none'">
          <div class="company-text">
            <h1>$pubName</h1>
            <p>$pubAddress | ফোন: $pubPhone</p>
          </div>
        </div>
        <div class="badge">অফিসিয়াল ইনভয়েস</div>
      </div>

      <div class="info-grid">
        <div class="info-box">
          <h3>বিল প্রাপক:</h3>
          <p>$customerName</p>
          <p style="font-weight: normal; font-size: 12px; color: #666;">$customerMobile</p>
          <p style="font-weight: normal; font-size: 12px; color: #666;">$customerAddress</p>
        </div>
        <div class="info-box" style="text-align: right;">
          <h3>তারিখ:</h3>
          <p>${DateFormat('dd MMMM, yyyy').format(DateTime.now())}</p>
          <h3 style="margin-top: 10px;">ইনভয়েস নং:</h3>
          <p>#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}</p>
        </div>
      </div>

      <table>
        <thead>
          <tr>
            <th width="40" style="text-align: center;">ক্র.নং</th>
            <th>বিবরণ</th>
            <th width="60" style="text-align: center;">পরিমাণ</th>
            <th width="100" style="text-align: right;">দর</th>
            <th width="100" style="text-align: right;">মোট</th>
          </tr>
        </thead>
        <tbody>
          $itemsHtml
        </tbody>
      </table>

      <div class="total-section">
        <div class="total-table">
          <div class="total-row"><span>উপ-মোট:</span><span>${subtotal.toStringAsFixed(0)} টাকা</span></div>
          <div class="total-row" style="color: #ef4444;"><span>ডিসকাউন্ট:</span><span>- ${discount.toStringAsFixed(0)} টাকা</span></div>
          <div class="total-row grand-total"><span>সর্বমোট দেয়:</span><span>${total.toStringAsFixed(0)} টাকা</span></div>
          <div class="total-row" style="margin-top: 5px;"><span>পরিশোধিত:</span><span>${received.toStringAsFixed(0)} টাকা</span></div>
          <div class="total-row" style="font-weight: bold; color: ${due > 0 ? '#f59e0b' : '#10b981'};">
            <span>${due > 0 ? 'বাকি (Due):' : 'পরিশোধিত (Paid)'}</span>
            <span>${due > 0 ? due.toStringAsFixed(0) + ' টাকা' : 'হ্যাঁ'}</span>
          </div>
        </div>
      </div>

      <div class="signature-wrap">
        <div class="sig-box">ক্রেতার স্বাক্ষর</div>
        <div class="sig-box">কর্তৃপক্ষের স্বাক্ষর</div>
      </div>

      <div class="footer">
        আমাদের থেকে বই কেনার জন্য আপনাকে ধন্যবাদ।<br>
        Software by: BookSales Tracker
      </div>
    """;

    await _generateAndPrint(htmlContent, "Invoice-$customerName");
  }

  static Future<void> generateInvoice(Sale sale) async {
    await generateCustomInvoice(
      customerName: sale.customerName,
      customerMobile: sale.customerMobile,
      customerAddress: sale.customerAddress,
      items: [{'book': sale, 'qty': sale.quantity}],
      discount: sale.discount,
      received: sale.receivedAmount ?? sale.totalAmount,
    );
  }

  static Future<void> generateChalan(Sale sale) async {
    final settingsBox = Hive.box('settings');
    final pubName = settingsBox.get('pub_name', defaultValue: 'আমাদের সমাজ প্রকাশনী');
    final pubAddress = settingsBox.get('pub_address', defaultValue: '৩৮, বাংলাবাজার, ঢাকা-১১০০');
    final logoBase64 = await _getLogoBase64();
    
    final String htmlContent = """
      $_commonStyles
      <div class="header">
        <div class="company-info">
          <img src="data:image/png;base64,$logoBase64" class="company-logo" onerror="this.style.display='none'">
          <div class="company-text">
            <h1>$pubName</h1>
            <p>$pubAddress</p>
          </div>
        </div>
        <div class="badge" style="background: #334155;">সরবরাহ চালান / CHALAN</div>
      </div>

      <div class="info-grid">
        <div class="info-box">
          <h3>প্রাপক:</h3>
          <p>${sale.customerName}</p>
          <p style="font-weight: normal; font-size: 12px;">${sale.customerMobile}</p>
          <p style="font-weight: normal; font-size: 12px;">${sale.customerAddress ?? 'N/A'}</p>
        </div>
        <div class="info-box" style="text-align: right;">
          <h3>তারিখ:</h3>
          <p>${DateFormat('dd/MM/yyyy').format(sale.saleDate)}</p>
        </div>
      </div>

      <table>
        <thead>
          <tr>
            <th width="40" style="text-align: center;">ক্র.নং</th>
            <th>বইয়ের বিবরণ</th>
            <th width="100" style="text-align: center;">পরিমাণ</th>
            <th width="150" style="text-align: center;">মন্তব্য</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td style="text-align: center;">০১</td>
            <td>${sale.bookName}</td>
            <td style="text-align: center;">${sale.quantity} কপি</td>
            <td style="text-align: center;">-</td>
          </tr>
        </tbody>
      </table>

      <div style="margin-top: 50px; border: 1px dashed #ccc; padding: 15px; border-radius: 8px; font-size: 12px;">
        <strong>বিশেষ নির্দেশাবলী:</strong> পণ্য বুঝে নেওয়ার সময় কার্টুন বা প্যাকিং অক্ষত আছে কিনা যাচাই করে নিন।
      </div>

      <div class="signature-wrap">
        <div class="sig-box">বাহকের স্বাক্ষর</div>
        <div class="sig-box">গ্রহীতার স্বাক্ষর</div>
      </div>
    """;

    await _generateAndPrint(htmlContent, "Chalan-${sale.customerName}");
  }

  static Future<void> generateLabel(Sale sale) async {
    final settingsBox = Hive.box('settings');
    final pubName = settingsBox.get('pub_name', defaultValue: 'আমাদের সমাজ প্রকাশনী');
    final pubPhone = settingsBox.get('pub_phone', defaultValue: '০১৭xxxxxxxx');
    final logoBase64 = await _getLogoBase64();

    final String htmlContent = """
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;700&display=swap');
        body { font-family: 'Noto Sans Bengali', Arial, sans-serif; padding: 0; margin: 0; }
        .label-wrap { border: 2.5px dashed #000; border-radius: 12px; padding: 25px; width: 400px; height: 300px; margin: auto; background: #fff; }
        .l-header { background: #000; color: #fff; padding: 6px 15px; border-radius: 6px 6px 0 0; display: flex; justify-content: space-between; font-size: 11px; font-weight: bold; }
        .l-body { padding: 20px 0; border-bottom: 1px solid #eee; margin-bottom: 15px; }
        .cust-name { font-size: 26px; font-weight: 900; margin: 5px 0; color: #000; }
        .cust-phone { background: #f1f5f9; padding: 8px 12px; border-radius: 6px; font-weight: 900; font-size: 18px; display: inline-block; margin-top: 10px; border: 1px solid #cbd5e1; }
        .pay-badge { border: 2px solid #000; padding: 6px 12px; font-size: 13px; font-weight: 900; text-transform: uppercase; }
        .sender-wrap { display: flex; align-items: center; justify-content: space-between; }
        .sender-info { display: flex; align-items: center; }
        .sender-logo { width: 35px; height: 35px; margin-right: 10px; border-radius: 50%; }
        .sender-text h4 { margin: 0; font-size: 13px; color: #1E293B; }
        .sender-text p { margin: 0; font-size: 10px; color: #64748B; }
      </style>
      <div class="label-wrap">
        <div class="l-header"><span>BOOK PARCEL</span><span>HANDLE WITH CARE</span></div>
        <div class="l-body">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
              <div style="font-size: 12px; color: #64748B; font-weight: bold;">SHIP TO / প্রাপক:</div>
              <div class="cust-name">${sale.customerName}</div>
            </div>
            <div class="pay-badge">${sale.dueAmount > 0 ? 'COD: ' + sale.dueAmount.toStringAsFixed(0) : 'PAID'}</div>
          </div>
          <div class="cust-phone">📞 ${sale.customerMobile}</div>
          <div style="font-size: 14px; margin-top: 12px; color: #334155; line-height: 1.4;">
            <strong>ঠিকানা:</strong> ${sale.customerAddress ?? 'N/A'}
          </div>
        </div>
        <div class="sender-wrap">
          <div class="sender-info">
            <img src="data:image/png;base64,$logoBase64" class="sender-logo" onerror="this.style.display='none'">
            <div class="sender-text">
              <h4>প্রেরক: $pubName</h4>
              <p>ফোন: $pubPhone</p>
            </div>
          </div>
          <div style="text-align: right; opacity: 0.5; font-size: 9px; font-weight: bold;">
            BookSales Tracker Pro
          </div>
        </div>
      </div>
    """;
    await _generateAndPrint(htmlContent, "Label-${sale.customerName}");
  }
}

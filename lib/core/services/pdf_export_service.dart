import 'dart:typed_data';
import 'package:flutter/foundation.dart'
    show kIsWeb; // To check if running on web
import 'package:flutter/services.dart'
    show rootBundle; // Added for font loading
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:logistics/data/order_model/order_model.dart';
import 'dart:convert'; // For base64Encode
// import 'package:intl/intl.dart'; // Not needed for simplified version
// import 'dart:io'; // NOT USED ON WEB
// import 'package:path_provider/path_provider.dart'; // NOT USED ON WEB

class PdfExportService {
  static Future<Uint8List> generateOrderReceiptPdf(OrderModel order) async {
    final pdf = pw.Document();

    // Load the font
    final fontData = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    // Create a theme with the loaded font
    final pdfTheme = pw.ThemeData.withFont(base: ttf);

    pdf.addPage(
      pw.Page(
        // Simplified to pw.Page for this test
        theme: pdfTheme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              'Hello PDF World! Order: ${order.orderNumber}',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 20,
                color: PdfColors.black,
              ), // Explicit style
            ),
          ); // JUST a single line of text
        },
      ),
    );

    final Uint8List bytes = await pdf.save();

    if (kIsWeb) {
      // Print Base64 of PDF bytes to browser console for debugging
      final base64String = base64Encode(bytes);
      print('PDF_BASE64_START');
      print(base64String);
      print('PDF_BASE64_END');
      print(
        'To debug, copy the string between PDF_BASE64_START and PDF_BASE64_END.',
      );
      print('Then go to an online Base64 to PDF converter and paste it there.');
    } else {
      print("Platform is not web, skipping Base64 log for now.");
    }

    return bytes;
  }
}

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String orderNumber;

  const PdfViewerPage({
    super.key,
    required this.pdfBytes,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$orderNumber Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}

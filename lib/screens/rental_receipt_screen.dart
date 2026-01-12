import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/rental_receipt_model.dart';

class RentalReceiptPdf {
  static Future<void> generate(RentalReceipt receipt) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // String? resolveLogoUrl(String? logo) {
    //   if (logo == null || logo.isEmpty) return null;

    //   if (logo.startsWith('http')) return logo;

    //   return 'http://10.0.2.2:8080/public/$logo.png';
    // }

    //   final logoUrl = resolveLogoUrl(receipt.school.logoUrl);

    pw.ImageProvider? logoImage;

    try {
      final logoBytes =
          await rootBundle.load('assets/images/logo-oceandojo.png');

      logoImage = pw.MemoryImage(
        logoBytes.buffer.asUint8List(),
      );
    } catch (e) {
      logoImage = null;
    }

    final qrData = '''
                  Rental Receipt
                  School: ${receipt.school.name}
                  Student: ${receipt.student!.name}
                  Total: ${receipt.total}
                  Date: ${receipt.createdAt.toIso8601String()}
          ''';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              /// HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        receipt.school.name,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (receipt.school.nis != null)
                        pw.Text('NIS: ${receipt.school.nis}'),
                      pw.Text('Phone: ${receipt.school.phone}'),
                    ],
                  ),
                  if (receipt.school.logoUrl != null)
                    if (logoImage != null)
                      pw.Container(
                        width: 80,
                        height: 80,
                        child: pw.Image(
                          logoImage,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(),

              pw.SizedBox(height: 16),

              /// TITLE
              pw.Center(
                child: pw.Text(
                  'COMPROVANTE DE ALUGUEL DE EQUIPAMENTO',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 24),

              /// STUDENT INFO
              pw.Text(
                'Aluno:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Nome: ${receipt.student!.name}'),
              pw.Text('Nível: ${receipt.student!.skillLevel.name}'),
              pw.Text(
                'Data: ${dateFormat.format(receipt.createdAt)}',
              ),

              pw.SizedBox(height: 24),

              /// ITEMS
              pw.Text(
                'Equipamentos:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 8),

              ...receipt.rentals.map(
                (item) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.equipmentName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${item.quantity} × €${item.unitPrice.toStringAsFixed(2)}'
                        ' = €${item.total.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),

              pw.Divider(),

              /// TOTAL
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: €${receipt.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 40),

              /// QR CODE
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Validação do Recibo',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: qrData,
                      width: 120,
                      height: 120,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Escaneie para verificar este aluguel',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              /// FOOTER
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 200,
                      child: pw.Divider(),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Assinatura do Aluno / Responsável',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    /// 📤 PREVIEW / PRINT / SHARE
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

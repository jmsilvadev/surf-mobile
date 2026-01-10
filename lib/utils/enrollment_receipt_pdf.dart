import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class EnrollmentReceiptPdf {
  static Future<void> generate({
    required String schoolName,
    required String studentName,
    required String studentLevel,
    required int classId,
    required String teacherName,
    required DateTime startDateTime,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Text(
                schoolName,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Enrollment Receipt'),
              pw.Divider(),

              pw.SizedBox(height: 16),

              // STUDENT
              pw.Text('Student Information',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Name: $studentName'),
              pw.Text('Level: $studentLevel'),
              pw.Text('Issued at: ${dateFormat.format(DateTime.now())}'),

              pw.SizedBox(height: 16),

              // CLASS
              pw.Text('Class Information',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Class ID: #$classId'),
              pw.Text('Teacher: $teacherName'),
              pw.Text(
                'Date/Time: ${dateFormat.format(startDateTime)}',
              ),

              pw.SizedBox(height: 40),

              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Student / Responsible Signature',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    // 📤 abre preview / print / share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

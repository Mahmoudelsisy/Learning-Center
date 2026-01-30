import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student_profile.dart';
import '../models/session_model.dart';

class PdfService {
  Future<void> generateStudentReport(StudentProfile student, String name) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.alexandriaRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text('تقرير أداء الطالب: $name', style: pw.TextStyle(font: font, fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Text('إجمالي النجوم: ${student.totalStars}', style: pw.TextStyle(font: font, fontSize: 18)),
                pw.Text('نوع الدفع: ${student.paymentType == 'monthly' ? 'شهري' : 'بالحصة'}', style: pw.TextStyle(font: font, fontSize: 18)),
                pw.SizedBox(height: 20),
                pw.Text('ملاحظات إضافية:', style: pw.TextStyle(font: font, fontSize: 18)),
                pw.Text(student.tags.join(', '), style: pw.TextStyle(font: font, fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> generateSessionSummary(SessionModel session, List<String> presentStudents) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.alexandriaRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text('ملخص الحصة: ${session.title}', style: pw.TextStyle(font: font, fontSize: 24)),
                pw.SizedBox(height: 10),
                pw.Text('التاريخ: ${session.date}', style: pw.TextStyle(font: font, fontSize: 14)),
                pw.SizedBox(height: 20),
                pw.Text('ملاحظات الدرس:', style: pw.TextStyle(font: font, fontSize: 18)),
                pw.Text(session.notes.isEmpty ? 'لا يوجد ملاحظات' : session.notes, style: pw.TextStyle(font: font, fontSize: 14)),
                pw.SizedBox(height: 20),
                pw.Text('الطلاب الحاضرون:', style: pw.TextStyle(font: font, fontSize: 18)),
                ...presentStudents.map((name) => pw.Text('- $name', style: pw.TextStyle(font: font, fontSize: 14))),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../core/utils/formatter.dart';
import '../models/package_model.dart';
import '../models/user_model.dart';

class ReceiptService {
  /// Generate a PDF receipt document in bytes
  static Future<Uint8List> generateReceiptPdf({
    required String orderNumber,
    required double totalAmount,
    required String paymentMethod,
    required String paymentTime,
    required UserModel? user,
    required List<PackageModel> items,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'KPM ACADEMY INDONESIA',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Klinik Pendidikan MIPA - Bukti Pembayaran Resmi',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green100,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.green700, width: 1),
                    ),
                    child: pw.Text(
                      'LUNAS / PAID',
                      style: pw.TextStyle(
                        color: PdfColors.green800,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),

              // Transaction Info Table
              pw.Text(
                'INFORMASI TRANSAKSI',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 8),
              _pdfRow('No. Resi / Order ID', orderNumber),
              _pdfRow('Waktu Transaksi', paymentTime),
              _pdfRow('Metode Pembayaran', paymentMethod),
              _pdfRow('Nama Siswa / Akun', user?.name ?? 'Siswa KPM'),
              _pdfRow('Status Transaksi', 'Berhasil & Terverifikasi'),

              pw.SizedBox(height: 18),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 14),

              // Items
              pw.Text(
                'RINCIAN PAKET BELAJAR',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 8),

              if (items.isEmpty)
                _pdfItemRow('Paket Belajar Intensif KPM', 'SD & SMP • Akses 90 Hari', Formatter.currency(totalAmount))
              else
                ...items.map(
                  (item) => _pdfItemRow(
                    item.title,
                    '${item.jenjang} ${item.kelas} • ${item.activeDays} Hari Akses',
                    Formatter.currency(item.effectivePrice),
                  ),
                ),

              pw.SizedBox(height: 18),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 14),

              // Cost Breakdown
              _pdfRow('Subtotal', Formatter.currency(totalAmount)),
              _pdfRow('Biaya Admin / Layanan', 'GRATIS'),
              _pdfRow('PPN (11%)', 'Termasuk'),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.blue800, thickness: 1.5),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL PEMBAYARAN', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    Formatter.currency(totalAmount),
                    style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer Note
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'KPM Academy - Terverifikasi Otomatis',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Dokumen ini adalah bukti pembayaran digital yang sah dan terdaftar resmi di sistem KPM Academy.',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _pdfItemRow(String title, String subtitle, String price) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(subtitle, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
          ),
          pw.Text(price, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        ],
      ),
    );
  }

  /// Saves the PDF to Download or Documents directory and returns the File
  static Future<File> saveReceiptToFile({
    required Uint8List pdfBytes,
    required String orderNumber,
  }) async {
    Directory? directory;

    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        directory = downloadDir;
      }
    }

    if (directory == null) {
      try {
        directory = await getDownloadsDirectory();
      } catch (_) {}
    }

    directory ??= await getApplicationDocumentsDirectory();

    final safeName = orderNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final filePath = '${directory.path}/Resi_KPM_$safeName.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);
    return file;
  }

  /// Open the saved receipt file with the default PDF viewer
  static Future<void> openReceiptFile(String filePath) async {
    await OpenFilex.open(filePath);
  }
}

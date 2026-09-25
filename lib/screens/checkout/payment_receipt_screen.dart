import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/order_model.dart';
import '../../models/package_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/receipt_service.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../main_navigation_screen.dart';

class PaymentReceiptScreen extends StatelessWidget {
  final OrderModel? order;
  final PackageModel? package;
  final List<PackageModel>? items;

  const PaymentReceiptScreen({
    super.key,
    this.order,
    this.package,
    this.items,
  });

  Future<void> _handleDownloadReceipt(
    BuildContext context, {
    required String orderNum,
    required double totalAmount,
    required String paymentMethod,
    required String paymentTime,
    required UserModel? user,
    required List<PackageModel> purchasedItems,
  }) async {
    try {
      final pdfBytes = await ReceiptService.generateReceiptPdf(
        orderNumber: orderNum,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        paymentTime: paymentTime,
        user: user,
        items: purchasedItems,
      );

      final file = await ReceiptService.saveReceiptToFile(
        pdfBytes: pdfBytes,
        orderNumber: orderNum,
      );

      if (context.mounted) {
        AppModal.showReceiptDownloaded(
          context,
          orderNumber: orderNum,
          filePath: file.path,
          onOpenFile: () => ReceiptService.openReceiptFile(file.path),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppModal.showInfo(
          context,
          title: 'Gagal Mengunduh Resi',
          message: 'Terjadi kendala saat menyimpan file PDF: $e',
        );
      }
    }
  }

  void _navigateToPurchasedCourse(BuildContext context, List<PackageModel> purchasedItems) {
    final targetPkg = purchasedItems.isNotEmpty ? purchasedItems.first : package;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(initialIndex: 1),
      ),
      (route) => false,
    );
    if (targetPkg != null) {
      Navigator.pushNamed(context, '/package_detail', arguments: targetPkg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context).user;

    final String orderNum = order?.orderNumber ?? 'ORD-KPM-${DateTime.now().millisecondsSinceEpoch}';
    final double totalAmount = order?.totalPrice ?? package?.effectivePrice ?? 150000;
    final String paymentMethod = order?.paymentType ?? 'Midtrans QRIS / Virtual Account';
    final String paymentTime = order?.paymentTime ?? Formatter.date(DateTime.now());

    final List<PackageModel> purchasedItems = items ?? (package != null ? [package!] : []);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateToPurchasedCourse(context, purchasedItems);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _navigateToPurchasedCourse(context, purchasedItems),
          ),
          title: const Text('Resi Pembayaran'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download Resi (PDF)',
              onPressed: () => _handleDownloadReceipt(
                context,
                orderNum: orderNum,
                totalAmount: totalAmount,
                paymentMethod: paymentMethod,
                paymentTime: paymentTime,
                user: user,
                purchasedItems: purchasedItems,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Bagikan Resi',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'BUKTI PEMBAYARAN KPM ACADEMY\nOrder ID: $orderNum\nTotal: ${Formatter.currency(totalAmount)}\nStatus: LUNAS'));
                AppModal.showSuccess(
                  context,
                  title: 'Resi Berhasil Disalin! 📋',
                  message: 'Rincian bukti pembayaran telah disalin ke clipboard dan siap Anda bagikan ke media sosial atau pesan chat.',
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Top Success Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 52),
              ),
              const SizedBox(height: 14),
              Text(
                'Pembayaran Berhasil! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Terima kasih! Akses paket belajar Anda telah aktif.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Official Receipt Card (Invoice Card Style)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                  ),
                ),
                child: Column(
                  children: [
                    // Header of the receipt
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.verified_rounded, color: AppTheme.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'KPM ACADEMY INDONESIA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                Text(
                                  'Klinik Pendidikan MIPA • Bukti Pembayaran Resmi',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LUNAS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Receipt Content
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _receiptRow(
                            'No. Resi / Order ID',
                            orderNum,
                            isDark,
                            isCopyable: true,
                            onCopy: () {
                              Clipboard.setData(ClipboardData(text: orderNum));
                              AppModal.showSuccess(
                                context,
                                title: 'No. Resi Disalin 📋',
                                message: 'Nomor order $orderNum telah disalin ke clipboard.',
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          _receiptRow('Waktu Transaksi', paymentTime, isDark),
                          const SizedBox(height: 10),
                          _receiptRow('Metode Pembayaran', paymentMethod, isDark),
                          const SizedBox(height: 10),
                          _receiptRow('Nama Siswa / Akun', user?.name ?? 'Siswa KPM', isDark),
                          const SizedBox(height: 10),
                          _receiptRow('Status Transaksi', 'Berhasil & Terverifikasi', isDark, isSuccess: true),

                          const SizedBox(height: 16),
                          _dashedDivider(isDark),
                          const SizedBox(height: 16),

                          // Purchased items
                          Text(
                            'Rincian Paket Belajar:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (purchasedItems.isEmpty)
                            _itemTile(
                              'Paket Belajar Intensif KPM',
                              'SD & SMP • 90 Hari Akses',
                              totalAmount,
                              isDark,
                            )
                          else
                            ...purchasedItems.map(
                              (item) => _itemTile(
                                item.title,
                                '${item.jenjang} ${item.kelas} • ${item.activeDays} Hari Akses',
                                item.effectivePrice,
                                isDark,
                              ),
                            ),

                          const SizedBox(height: 16),
                          _dashedDivider(isDark),
                          const SizedBox(height: 16),

                          // Cost breakdown
                          _receiptRow('Subtotal', Formatter.currency(totalAmount), isDark),
                          const SizedBox(height: 8),
                          _receiptRow('Biaya Admin Midtrans', 'GRATIS', isDark, isGreen: true),
                          const SizedBox(height: 8),
                          _receiptRow('PPN (11%)', 'Termasuk', isDark),
                          const SizedBox(height: 14),

                          Divider(height: 1, color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL PEMBAYARAN',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                Formatter.currency(totalAmount),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Receipt Footer with barcode/QR simulation
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.qr_code_rounded, size: 28, color: AppTheme.primaryBlue),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TERVERIFIKASI OTOMATIS',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                  ),
                                  Text(
                                    'Sistem KPM & Midtrans Gateway',
                                    style: TextStyle(fontSize: 9, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.security_rounded, size: 22, color: AppTheme.accentGreen),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () => _handleDownloadReceipt(
                        context,
                        orderNum: orderNum,
                        totalAmount: totalAmount,
                        paymentMethod: paymentMethod,
                        paymentTime: paymentTime,
                        user: user,
                        purchasedItems: purchasedItems,
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download Resi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 2,
                      ),
                      onPressed: () => _navigateToPurchasedCourse(context, purchasedItems),
                      icon: const Icon(Icons.school_rounded, size: 18),
                      label: const Text('Mulai Belajar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(
    String label,
    String value,
    bool isDark, {
    bool isCopyable = false,
    VoidCallback? onCopy,
    bool isSuccess = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
        if (isCopyable)
          GestureDetector(
            onTap: onCopy,
            child: Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.copy_rounded, size: 12, color: AppTheme.primaryBlue),
              ],
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSuccess || isGreen
                  ? AppTheme.accentGreen
                  : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
            ),
          ),
      ],
    );
  }

  Widget _itemTile(String title, String subtitle, double price, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatter.currency(price),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBorderColor : const Color(0xFFCBD5E1),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

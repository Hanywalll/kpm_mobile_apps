import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/order_model.dart';
import '../../models/package_model.dart';
import '../../providers/package_provider.dart';
import 'payment_receipt_screen.dart';

class MidtransPaymentScreen extends StatefulWidget {
  final OrderModel? order;
  final PackageModel? package;
  final List<PackageModel>? items;

  const MidtransPaymentScreen({
    super.key,
    this.order,
    this.package,
    this.items,
  });

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  String _selectedChannel = 'qris'; // 'qris' or 'va'
  String _selectedBank = 'BCA';
  bool _isChecking = false;
  late Timer _countdownTimer;
  int _secondsRemaining = 60 * 60; // 60 minutes expiry

  late String _vaNumber;

  @override
  void initState() {
    super.initState();
    final seed = widget.order?.orderNumber ?? widget.order?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final cleanSeed = seed.replaceAll(RegExp(r'[^0-9]'), '');
    final paddedSeed = (cleanSeed.length >= 8 ? cleanSeed.substring(cleanSeed.length - 8) : '89201948');
    _vaNumber = '80777$paddedSeed';

    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _countdownTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard!'),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _checkPaymentStatus() async {
    setState(() => _isChecking = true);
    final packageProvider = Provider.of<PackageProvider>(context, listen: false);

    final orderId = widget.order?.id ?? 'ord_demo_1';
    final orderNum = widget.order?.orderNumber ?? 'ORD-KPM-${DateTime.now().millisecondsSinceEpoch}';

    final isPaid = await packageProvider.checkMidtransStatus(orderId, orderNum);

    setState(() => _isChecking = false);

    if (isPaid && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Midtrans: Transaksi masih pending / belum dibayar. Silakan lakukan pembayaran di Simulator Midtrans atau klik Simulasi Cepat.',
          ),
          backgroundColor: const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Bayar Cepat',
            textColor: Colors.white,
            onPressed: _simulateDirectPay,
          ),
        ),
      );
    }
  }

  Future<void> _simulateDirectPay() async {
    setState(() => _isChecking = true);
    final packageProvider = Provider.of<PackageProvider>(context, listen: false);
    final orderId = widget.order?.id ?? 'ord_demo_1';
    await packageProvider.simulatePay(orderId);
    setState(() => _isChecking = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 44),
            ),
            const SizedBox(height: 16),
            Text(
              'Pembayaran Berhasil! 🎉',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Midtrans telah memverifikasi pembayaran Anda. Akses paket belajar dan simulasi ujian online telah diaktifkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentReceiptScreen(
                        order: widget.order,
                        package: widget.package,
                        items: widget.items,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                label: const Text('Lihat Resi Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: Text(
                  'Langsung Belajar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;
    final pkg = widget.package;

    final double amount = order?.totalPrice ?? pkg?.effectivePrice ?? 150000;
    final String orderNum = order?.orderNumber ?? 'ORD-KPM-${DateTime.now().millisecondsSinceEpoch}';
    final String snapUrl = order?.paymentUrl ?? 'https://app.sandbox.midtrans.com/snap/v2/vtweb/demo';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Pembayaran Midtrans Gateway'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Expiry Countdown & Total Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.blueGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'MIDTRANS SANDBOX ACTIVE',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(_secondsRemaining),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Total Tagihan Pembayaran',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatter.currency(amount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _copyToClipboard(amount.toStringAsFixed(0), 'Nominal tagihan'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 12, color: AppTheme.primaryBlue),
                              SizedBox(width: 4),
                              Text('Salin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Order ID: $orderNum',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _copyToClipboard(orderNum, 'Order ID'),
                        child: const Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 12, color: Colors.white70),
                            SizedBox(width: 4),
                            Text('Salin Order ID', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Midtrans Snap Redirect Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment_rounded, color: AppTheme.primaryBlue, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gateway Pembayaran Midtrans Snap',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue),
                        ),
                        Text(
                          'Buka Snap UI untuk membayar via QRIS/VA',
                          style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 34),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _copyToClipboard(snapUrl, 'URL Pembayaran Midtrans Snap'),
                    child: const Text('Salin URL Snap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Midtrans Simulator Guide Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.science_rounded, size: 18, color: Color(0xFFB45309)),
                      SizedBox(width: 6),
                      Text(
                        'Panduan Midtrans Simulator Sandbox',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Untuk menguji transaksi ini di Midtrans Payment Simulator:',
                    style: TextStyle(fontSize: 11, color: Color(0xFF78350F)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. Buka browser: https://simulator.sandbox.midtrans.com/\n2. Pilih metode yang diinginkan (BCA / BNI / BRI / Mandiri / QRIS)\n3. Masukkan Nomor VA atau Order ID di atas\n4. Klik "Inquire" & "Pay", lalu klik tombol "Cek Status Pembayaran" di bawah.',
                    style: TextStyle(fontSize: 10, height: 1.4, color: Color(0xFF78350F)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: const Size(0, 26),
                      ),
                      onPressed: () => _copyToClipboard('https://simulator.sandbox.midtrans.com/', 'URL Simulator Midtrans'),
                      icon: const Icon(Icons.link_rounded, size: 14, color: Color(0xFF92400E)),
                      label: const Text('Salin Link Simulator', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Channel Selector (QRIS / Virtual Account)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChannel = 'qris'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedChannel == 'qris'
                            ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                            : (isDark ? AppTheme.darkCardColor : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedChannel == 'qris'
                              ? AppTheme.primaryBlue
                              : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'QRIS / E-Wallet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _selectedChannel == 'qris'
                                ? (isDark ? Colors.white : AppTheme.textPrimary)
                                : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChannel = 'va'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedChannel == 'va'
                            ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                            : (isDark ? AppTheme.darkCardColor : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedChannel == 'va'
                              ? AppTheme.primaryBlue
                              : (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Virtual Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _selectedChannel == 'va'
                                ? (isDark ? Colors.white : AppTheme.textPrimary)
                                : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3. Channel Content
            if (_selectedChannel == 'qris') _buildQRISSection(isDark) else _buildVASection(isDark),

            const SizedBox(height: 24),

            // 4. Action Check Payment Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isChecking ? null : _checkPaymentStatus,
                icon: _isChecking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  _isChecking ? 'Memeriksa ke Midtrans...' : 'Cek Status Pembayaran (Midtrans)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Fast Direct Simulate Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : AppTheme.textPrimary,
                  side: BorderSide(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isChecking ? null : _simulateDirectPay,
                icon: const Icon(Icons.flash_on_rounded, size: 18, color: Color(0xFFD97706)),
                label: const Text('⚡ Simulasi Bayar Instan (Sandbox Direct)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Terhubung langsung dengan Midtrans Sandbox Gateway (Merchant: M475074205)',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // QRIS Section
  Widget _buildQRISSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Scan Kode QRIS Midtrans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Otomatis Terverifikasi', style: TextStyle(color: AppTheme.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // QR Code Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 160, color: Color(0xFF0F172A)),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.school_rounded, size: 22, color: AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'NMID: ID1020039281092\nKPM ACADEMY INDONESIA - MIDTRANS',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Dapat di-scan menggunakan GoPay, OVO, ShopeePay, DANA, BCA Mobile, Livin Mandiri, BRImo, atau m-Banking lainnya.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // Virtual Account Section
  Widget _buildVASection(bool isDark) {
    final List<Map<String, String>> banks = [
      {'code': 'BCA', 'name': 'BCA Virtual Account', 'prefix': '80777'},
      {'code': 'Mandiri', 'name': 'Mandiri Bill Payment', 'prefix': '89022'},
      {'code': 'BNI', 'name': 'BNI Virtual Account', 'prefix': '82770'},
      {'code': 'BRI', 'name': 'BRI BRIVA', 'prefix': '78001'},
      {'code': 'Permata', 'name': 'Permata Virtual Account', 'prefix': '84029'},
    ];

    final currentPrefix = banks.firstWhere((b) => b['code'] == _selectedBank, orElse: () => banks.first)['prefix']!;
    final dynamicVa = '$currentPrefix${_vaNumber.substring(5)}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih Bank Virtual Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          // Bank Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: banks.map((b) {
                final bool isSelected = _selectedBank == b['code'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(b['code']!),
                    selected: isSelected,
                    selectedColor: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                    backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF8FAFC),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected
                          ? (isDark ? Colors.white : AppTheme.textPrimary)
                          : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedBank = b['code']!);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // VA Number Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppTheme.darkBorderColor : const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Virtual Account ($_selectedBank)',
                        style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dynamicVa,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _copyToClipboard(dynamicVa, 'Nomor Virtual Account $_selectedBank'),
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Salin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Step-by-step instructions
          Text(
            'Petunjuk Pembayaran $_selectedBank (Mobile Banking / Midtrans Simulator):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _instructionStep('1', 'Buka m-Banking $_selectedBank atau Simulator: https://simulator.sandbox.midtrans.com/'),
          _instructionStep('2', 'Pilih menu Transfer / Virtual Account $_selectedBank.'),
          _instructionStep('3', 'Masukkan nomor VA $dynamicVa.'),
          _instructionStep('4', 'Konfirmasi nama merchant KPM ACADEMY dan nominal.'),
          _instructionStep('5', 'Selesaikan transaksi, lalu klik "Cek Status Pembayaran" di bawah.'),
        ],
      ),
    );
  }

  Widget _instructionStep(String step, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

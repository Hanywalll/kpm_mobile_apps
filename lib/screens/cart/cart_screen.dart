import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/package_model.dart';
import '../../providers/package_provider.dart';
import '../../widgets/auth_guard_bottom_sheet.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  bool _isPromoApplied = false;
  double _promoDiscount = 0.0;
  String? _promoMessage;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'KPMJUARA' || code == 'HEMAT10') {
      setState(() {
        _isPromoApplied = true;
        _promoDiscount = 20000;
        _promoMessage = 'Voucher $code berhasil dipasang! (Hemat Rp 20.000)';
      });
      AppModal.showSuccess(
        context,
        title: 'Voucher Berhasil Dipasang! 🎉',
        message: 'Kode voucher $code berhasil diterapkan. Anda hemat Rp 20.000 untuk transaksi ini!',
      );
    } else if (code.isEmpty) {
      AppModal.showInfo(
        context,
        title: 'Kode Voucher Kosong',
        message: 'Silakan masukkan kode voucher atau promo terlebih dahulu.',
      );
    } else {
      AppModal.showInfo(
        context,
        title: 'Kode Tidak Valid',
        message: 'Kode promo yang dimasukkan tidak ditemukan atau telah kadaluarsa. Coba gunakan kode: KPMJUARA',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packageProvider = Provider.of<PackageProvider>(context);
    final cartItems = packageProvider.cartItems;

    final double subtotal = packageProvider.cartTotalPrice;
    final double originalPrice = packageProvider.cartOriginalPrice;
    final double discount = packageProvider.cartTotalDiscount + (_isPromoApplied ? _promoDiscount : 0);
    final double finalTotal = (subtotal - (_isPromoApplied ? _promoDiscount : 0)).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Keranjang Belajar'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              tooltip: 'Kosongkan Keranjang',
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: const [
                        Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kosongkan Keranjang?',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'Apakah kamu yakin ingin menghapus semua paket belajar yang ada di dalam keranjang?',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                    ),
                    actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    actions: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () {
                          packageProvider.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Ya, Kosongkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context, isDark)
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cart count header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daftar Paket (${cartItems.length} Item)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified_rounded, size: 14, color: AppTheme.primaryBlue),
                                  SizedBox(width: 4),
                                  Text(
                                    'Siap Checkout',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Item List
                        ...cartItems.map((pkg) => _buildCartItemCard(context, pkg, packageProvider, isDark)),

                        const SizedBox(height: 12),

                        // Promo / Voucher Code Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: AppTheme.bentoBoxDecoration(context: context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_number_outlined, size: 18, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Punya Kode Promo / Voucher?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _promoController,
                                        textCapitalization: TextCapitalization.characters,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppTheme.textPrimary,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Contoh: KPMJUARA',
                                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      minimumSize: const Size(0, 42),
                                    ),
                                    onPressed: _applyPromo,
                                    child: const Text('Pakai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                              if (_isPromoApplied) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accentGreen),
                                    const SizedBox(width: 6),
                                    Text(
                                      _promoMessage ?? 'Promo Aktif',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.accentGreen, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Rincian Pembayaran
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.bentoBoxDecoration(context: context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ringkasan Biaya',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _summaryRow('Total Harga Paket', Formatter.currency(originalPrice), isDark),
                              const SizedBox(height: 8),
                              if (discount > 0) ...[
                                _summaryRow('Total Potongan Diskon', '- ${Formatter.currency(discount)}', isDark, isHighlight: true),
                                const SizedBox(height: 8),
                              ],
                              _summaryRow('Biaya Layanan & PPN', 'GRATIS', isDark, isFree: true),
                              const SizedBox(height: 12),
                              Divider(height: 1, color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Tagihan',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    Formatter.currency(finalTotal),
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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Action Bar (Compact & Sleek)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardColor : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Pembayaran',
                              style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Formatter.currency(finalTotal),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            elevation: 1,
                          ),
                          onPressed: () {
                            AuthGuard.check(
                              context,
                              featureName: 'Checkout Keranjang Belajar',
                              onAuthenticated: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                      cartPackage: cartItems.first,
                                      customTotal: finalTotal,
                                      cartItems: cartItems,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                          label: Text(
                            'Checkout (${cartItems.length}) ➔',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, PackageModel pkg, PackageProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${pkg.jenjang} ${pkg.kelas}',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pkg.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  provider.removeFromCart(pkg.id);
                  AppModal.showInfo(
                    context,
                    title: 'Paket Dihapus',
                    message: '${pkg.title} berhasil dihapus dari keranjang belajar.',
                  );
                },
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                tooltip: 'Hapus dari keranjang',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${pkg.activeDays} Hari Akses • ${pkg.totalModules} Modul',
                style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (pkg.hasDiscount)
                    Text(
                      Formatter.currency(pkg.price),
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 10,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                      ),
                    ),
                  Text(
                    Formatter.currency(pkg.effectivePrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDark, {bool isHighlight = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isFree
                ? AppTheme.accentGreen
                : isHighlight
                    ? Colors.redAccent
                    : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 52, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 20),
            Text(
              'Keranjang Belajar Kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu belum memasukkan paket belajar ke dalam keranjang. Yuk pilih paket belajar terbaik sekarang!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.school_rounded, size: 18),
              label: const Text('Jelajahi Paket Belajar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

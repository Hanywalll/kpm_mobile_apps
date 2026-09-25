import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/package_model.dart';
import '../../providers/package_provider.dart';
import '../../widgets/primary_button.dart';
import 'midtrans_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final PackageModel? cartPackage;
  final double? customTotal;
  final List<PackageModel>? cartItems;

  const CheckoutScreen({
    super.key,
    this.cartPackage,
    this.customTotal,
    this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'QRIS / E-Wallet';
  bool _isProcessing = false;

  void _handlePayment(PackageModel mainPkg, double totalAmount, List<PackageModel> items) async {
    setState(() => _isProcessing = true);
    final packageProvider = Provider.of<PackageProvider>(context, listen: false);

    final order = await packageProvider.createOrder(
      mainPkg.id,
      totalPrice: totalAmount,
      isCustomAmount: widget.customTotal != null,
    );

    setState(() => _isProcessing = false);

    if (order != null && mounted) {
      if (items.isNotEmpty) {
        packageProvider.clearCart();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MidtransPaymentScreen(
            order: order,
            package: mainPkg,
            items: items.isNotEmpty ? items : [mainPkg],
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(packageProvider.errorMessage ?? 'Gagal membuat order.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final packageProvider = Provider.of<PackageProvider>(context);

    PackageModel pkg;
    List<PackageModel> itemsList = widget.cartItems ?? [];

    if (widget.cartPackage != null) {
      pkg = widget.cartPackage!;
    } else if (routeArg is PackageModel) {
      pkg = routeArg;
      itemsList = [pkg];
    } else if (packageProvider.cartItems.isNotEmpty) {
      pkg = packageProvider.cartItems.first;
      itemsList = packageProvider.cartItems;
    } else if (packageProvider.selectedPackage != null) {
      pkg = packageProvider.selectedPackage!;
      itemsList = [pkg];
    } else if (packageProvider.packages.isNotEmpty) {
      pkg = packageProvider.packages.first;
      itemsList = [pkg];
    } else {
      pkg = PackageModel(
        id: 'pkg_kpm_1',
        title: 'Paket Belajar & Latihan KPM',
        description: 'Akses Lengkap Kartu Belajar & Soal',
        price: 150000,
        discountPrice: 150000,
        isDiscountActive: false,
      );
      itemsList = [pkg];
    }

    final double effectiveTotal = widget.customTotal ??
        (itemsList.isNotEmpty
            ? itemsList.fold(0.0, (sum, i) => sum + i.effectivePrice)
            : pkg.effectivePrice);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Pembayaran Paket'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${itemsList.length} Item',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Item cards
            if (itemsList.length <= 1)
              _buildSingleItemCard(pkg, isDark)
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.bentoBoxDecoration(context: context),
                child: Column(
                  children: itemsList.map((item) => _buildCartSummaryTile(item, isDark)).toList(),
                ),
              ),

            const SizedBox(height: 20),

            // Payment Methods
            Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: AppTheme.bentoBoxDecoration(context: context),
              child: Column(
                children: [
                  RadioListTile<String>(
                    activeColor: AppTheme.primaryBlue,
                    title: Text(
                      'QRIS / E-Wallet (GoPay, OVO, ShopeePay)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Pembayaran instan verifikasi otomatis 24/7',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                    value: 'QRIS / E-Wallet',
                    groupValue: _selectedMethod,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMethod = val);
                    },
                  ),
                  Divider(height: 1, color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                  RadioListTile<String>(
                    activeColor: AppTheme.primaryBlue,
                    title: Text(
                      'Virtual Account (BCA, Mandiri, BNI, BRI)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Transfer via Mobile Banking, Internet Banking & ATM',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                    ),
                    value: 'Virtual Account',
                    groupValue: _selectedMethod,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMethod = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cost Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.bentoBoxDecoration(context: context),
              child: Column(
                children: [
                  _priceRow('Subtotal', Formatter.currency(effectiveTotal), isDark),
                  const SizedBox(height: 8),
                  _priceRow('Biaya Layanan Midtrans', 'GRATIS', isDark, isGreen: true),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Bayar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        Formatter.currency(effectiveTotal),
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

            const SizedBox(height: 28),

            PrimaryButton(
              text: 'Bayar Sekarang (${Formatter.currency(effectiveTotal)}) ➔',
              isLoading: _isProcessing,
              onPressed: () => _handlePayment(pkg, effectiveTotal, itemsList),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleItemCard(PackageModel pkg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pkg.kelas} ${pkg.jenjang} • ${pkg.activeDays} Hari Akses',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            Formatter.currency(pkg.effectivePrice),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummaryTile(PackageModel item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatter.currency(item.effectivePrice),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, bool isDark, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isGreen ? AppTheme.accentGreen : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}

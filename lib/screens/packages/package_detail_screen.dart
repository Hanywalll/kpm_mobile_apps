import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/package_model.dart';
import '../../providers/package_provider.dart';
import '../../widgets/auth_guard_bottom_sheet.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../checkout/checkout_screen.dart';

class PackageDetailScreen extends StatelessWidget {
  const PackageDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packageProvider = Provider.of<PackageProvider>(context);
    final routeArg = ModalRoute.of(context)?.settings.arguments;

    PackageModel pkg;
    if (routeArg is PackageModel) {
      pkg = routeArg;
    } else if (packageProvider.selectedPackage != null) {
      pkg = packageProvider.selectedPackage!;
    } else if (packageProvider.packages.isNotEmpty) {
      pkg = packageProvider.packages.first;
    } else {
      pkg = PackageModel(
        id: 'pkg_kpm_1',
        title: 'Paket Intensif Matematika Nalaria & Sains',
        description: 'Lengkap dengan Live Class, Bank Soal CBT & Tanya AI Tutor 24/7.',
        price: 150000,
        discountPrice: 120000,
        isDiscountActive: true,
        membershipDurationDays: 90,
      );
    }

    final bool isAlreadyInCart = packageProvider.isInCart(pkg.id);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Detail Paket Belajar'),
        actions: [
          // Cart Icon in AppBar with Badge
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: Badge(
              isLabelVisible: packageProvider.cartCount > 0,
              label: Text('${packageProvider.cartCount}'),
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryBlue),
            ),
            tooltip: 'Keranjang Belajar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact Elegant Top Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.ruangguruGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${pkg.jenjang} • ${pkg.kelas}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (pkg.hasDiscount)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentYellow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'DISKON SPESIAL',
                                        style: TextStyle(
                                          color: Color(0xFF78350F),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pkg.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pkg.description.isNotEmpty ? pkg.description : 'Akses penuh seluruh materi dan tryout CBT KPM.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, size: 28, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Compact Stats Summary
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: AppTheme.bentoBoxDecoration(context: context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailStat(label: 'Rating', value: '⭐ ${pkg.rating}', isDark: isDark),
                        _verticalDivider(isDark),
                        _DetailStat(label: 'Modul', value: '${pkg.totalModules} Modul', isDark: isDark),
                        _verticalDivider(isDark),
                        _DetailStat(label: 'Bank Soal', value: '${pkg.totalQuestions} Soal', isDark: isDark),
                        _verticalDivider(isDark),
                        _DetailStat(label: 'Masa Aktif', value: '${pkg.activeDays} Hari', isDark: isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Keunggulan & Fitur Paket',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _featureItem(context, Icons.video_library_rounded, 'Video Pembelajaran HD', 'Penjelasan konsep step-by-step dari Master Tutor KPM.', isDark),
                  _featureItem(context, Icons.assignment_turned_in_rounded, 'Simulasi Tryout CBT Interaktif', 'Sistem penilaian akurat dengan analisis kompetensi mendalam.', isDark),
                  _featureItem(context, Icons.smart_toy_rounded, 'AI Tutor Cerdas 24/7', 'Bantu konsultasi dan selesaikan soal latihan kapan saja.', isDark),
                  _featureItem(context, Icons.analytics_rounded, 'Analisis Rapor & Progres Belajar', 'Kalkulasi penguasaan materi dan peningkatan skor berkala.', isDark),

                  const SizedBox(height: 14),

                  Text(
                    'Deskripsi Paket:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pkg.description.isNotEmpty
                        ? pkg.description
                        : 'Paket ini dirancang khusus bagi siswa yang ingin menguasai konsep Matematika Nalaria & Sains secara mendalam dan berprestasi unggul.',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Sleek Compact Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Total Price Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                      ),
                      if (pkg.hasDiscount)
                        Text(
                          Formatter.currency(pkg.price),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      Text(
                        Formatter.currency(pkg.effectivePrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Compact Cart Toggle Button
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: isAlreadyInCart
                          ? AppTheme.accentGreen.withValues(alpha: 0.12)
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAlreadyInCart ? AppTheme.accentGreen : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        final added = packageProvider.toggleCart(pkg);
                        if (added) {
                          AppModal.showCartSuccess(
                            context,
                            package: pkg,
                            onGoToCart: () => Navigator.pushNamed(context, '/cart'),
                          );
                        } else {
                          AppModal.showInfo(
                            context,
                            title: 'Dihapus dari Keranjang',
                            message: '${pkg.title} telah dihapus dari keranjang belajar Anda.',
                          );
                        }
                      },
                      icon: Icon(
                        isAlreadyInCart ? Icons.shopping_cart_rounded : Icons.add_shopping_cart_rounded,
                        color: isAlreadyInCart ? AppTheme.accentGreen : AppTheme.primaryBlue,
                        size: 20,
                      ),
                      tooltip: isAlreadyInCart ? 'Hapus dari Keranjang' : 'Tambah ke Keranjang',
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Compact Beli Sekarang Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      AuthGuard.check(
                        context,
                        featureName: pkg.title,
                        onAuthenticated: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(cartPackage: pkg),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_rounded, size: 17),
                    label: const Text(
                      'Beli Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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

  Widget _verticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
    );
  }

  Widget _featureItem(BuildContext context, IconData icon, String title, String subtitle, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailStat({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.primaryBlue),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
        ),
      ],
    );
  }
}

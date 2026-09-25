import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/package_model.dart';
import '../../providers/package_provider.dart';
import '../../widgets/custom_alert_dialog.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  final List<String> _categories = ['Semua', 'SD', 'SMP', 'SMA', 'Olimpiade'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PackageProvider>(context, listen: false).fetchPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packageProvider = Provider.of<PackageProvider>(context);
    final packages = packageProvider.packages;
    final selectedJenjang = packageProvider.selectedJenjang;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Katalog Paket Belajar'),
        actions: [
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
          // Minimalist Compact Grey Horizontal Category Tabs
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == selectedJenjang;

                return GestureDetector(
                  onTap: () => packageProvider.setSelectedJenjang(cat),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF475569) : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: packageProvider.isLoading && packages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : packages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey),
                            const SizedBox(height: 10),
                            const Text('Belum ada paket untuk kategori ini.', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => packageProvider.setSelectedJenjang('Semua'),
                              child: const Text('Lihat Semua Paket'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => packageProvider.fetchPackages(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const ClampingScrollPhysics(),
                          itemCount: packages.length,
                          itemBuilder: (context, index) {
                            final pkg = packages[index];
                            return _buildPackageCard(context, pkg, packageProvider, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, PackageModel pkg, PackageProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pkg.hasDiscount ? 'DISKON SPESIAL' : 'PROGRAM UTAMA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppTheme.accentYellow, size: 16),
                    const SizedBox(width: 3),
                    Text(
                      '${pkg.rating}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                if (pkg.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    pkg.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Specs Chips
                Row(
                  children: [
                    _detailBadge(Icons.auto_stories_outlined, '${pkg.kelas}', isDark),
                    const SizedBox(width: 6),
                    _detailBadge(Icons.quiz_outlined, '${pkg.totalQuestions} Soal', isDark),
                    const SizedBox(width: 6),
                    _detailBadge(Icons.timer_outlined, '${pkg.activeDays} Hari', isDark),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                ),
                const SizedBox(height: 10),

                // Price & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pkg.hasDiscount)
                          Text(
                            Formatter.currency(pkg.price),
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        Text(
                          Formatter.currency(pkg.effectivePrice),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Cart button
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: provider.isInCart(pkg.id)
                                ? AppTheme.accentGreen.withValues(alpha: 0.12)
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: provider.isInCart(pkg.id)
                                  ? AppTheme.accentGreen
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              final added = provider.toggleCart(pkg);
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
                              provider.isInCart(pkg.id) ? Icons.shopping_cart_rounded : Icons.add_shopping_cart_rounded,
                              size: 18,
                              color: provider.isInCart(pkg.id) ? AppTheme.accentGreen : AppTheme.primaryBlue,
                            ),
                            tooltip: provider.isInCart(pkg.id) ? 'Hapus dari Keranjang' : 'Tambah ke Keranjang',
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                          onPressed: () {
                            provider.fetchPackageDetail(pkg.id);
                            Navigator.pushNamed(context, '/package_detail', arguments: pkg);
                          },
                          child: const Text('Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                          onPressed: () {
                            provider.fetchPackageDetail(pkg.id);
                            Navigator.pushNamed(context, '/checkout', arguments: pkg);
                          },
                          child: const Text('Beli', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBadge(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

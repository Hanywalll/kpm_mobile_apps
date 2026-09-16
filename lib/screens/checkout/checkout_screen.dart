import 'package:flutter/material.dart';
import '../../core/utils/formatter.dart';
import '../../widgets/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'QRIS / E-Wallet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Paket Intensif SNBT Complete 2025'),
                subtitle: Text(Formatter.currency(150000)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('QRIS / E-Wallet (GoPay, OVO, ShopeePay)'),
              value: 'QRIS / E-Wallet',
              groupValue: _selectedMethod,
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
            RadioListTile<String>(
              title: const Text('Virtual Account (BCA, Mandiri, BRI)'),
              value: 'Virtual Account',
              groupValue: _selectedMethod,
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Bayar Sekarang (${Formatter.currency(150000)})',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memproses transaksi Midtrans...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

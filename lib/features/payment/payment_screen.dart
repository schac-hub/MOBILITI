import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../tracking/tracking_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String? tripId;
  final double? amount;
  const PaymentScreen({super.key, this.tripId, this.amount});

  static const route = '/payment';

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'MTN'; // MTN, Orange, Wave
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) _phoneController.text = user.phoneNumber;
  }

  void _processPayment() async {
    if (_phoneController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone invalide')),
      );
      return;
    }

    // Simulation de paiement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context); // Close loading

    Navigator.pushNamed(context, TrackingScreen.route, arguments: widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.amount ?? 1500.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Paiement sécurisé', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Résumé ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total à payer', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                        Text('${amount.toInt()} FCFA', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Choisir un moyen de paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            // ── Méthodes ────────────────────────────────────────────────
            _PaymentMethodTile(
              title: 'MTN Mobile Money',
              image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/MTN_Logo.svg/2048px-MTN_Logo.svg.png',
              isSelected: _selectedMethod == 'MTN',
              onTap: () => setState(() => _selectedMethod = 'MTN'),
            ),
            _PaymentMethodTile(
              title: 'Orange Money',
              image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Orange_logo.svg/1200px-Orange_logo.svg.png',
              isSelected: _selectedMethod == 'Orange',
              onTap: () => setState(() => _selectedMethod = 'Orange'),
            ),
            _PaymentMethodTile(
              title: 'Wave Côte d\'Ivoire',
              image: 'https://play-lh.googleusercontent.com/6S3rNIsYF8-M6_33u3f-2Xy3-8q-X-M5v5F6yR9_4o-6X9-2-8Z3-4O3V_Y_Z-0=s200',
              isSelected: _selectedMethod == 'Wave',
              onTap: () => setState(() => _selectedMethod = 'Wave'),
            ),

            const SizedBox(height: 32),
            const Text('Numéro de débit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '07 00 00 00 00',
                prefixIcon: const Icon(Icons.phone_android_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('PAYER ${amount.toInt()} FCFA', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('Vos données sont cryptées et sécurisées', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title, image;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({required this.title, required this.image, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.3) : Colors.white,
        ),
        child: Row(
          children: [
            Image.network(image, height: 30, width: 30, errorBuilder: (_, _, _) => const Icon(Icons.payment)),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

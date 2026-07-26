import 'package:flutter/material.dart';
import '../tracking/tracking_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'MTN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Paiement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth > 600 ? 500 : double.infinity;
            return Center(
              child: SizedBox(
                width: maxWidth,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryCard(),
                            const SizedBox(height: 32),
                            const Text(
                              'Mode de paiement',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPaymentOption(
                              id: 'MTN',
                              name: 'MTN Mobile Money',
                              image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/MTN_Logo.svg/1200px-MTN_Logo.svg.png',
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentOption(
                              id: 'Orange',
                              name: 'Orange Money',
                              image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Orange_logo.svg/1200px-Orange_logo.svg.png',
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentOption(
                              id: 'Wave',
                              name: 'Wave',
                              image: 'https://play-lh.googleusercontent.com/9n9_p_n7N0_v_R_V8p_r7N0_v_R_V8p_r7N0_v_R_V8p_r7N0_v_R_V8p_r7N0_v_R_V8p_r7N0_v_R_V8p_r7N0', // Placeholder for Wave
                            ),
                            const SizedBox(height: 32),
                            _buildSecurityNote(),
                          ],
                        ),
                      ),
                    ),
                    _buildPayButton(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0EFE0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_filled,
              color: Color(0xFF1B5E38),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trajet Yopougon → Plateau',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Total 1 650 FCFA',
                  style: TextStyle(
                    color: Color(0xFF1B5E38),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String name,
    required String image,
  }) {
    final bool isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B5E38) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {}, // Handle error if image fails
                ),
              ),
              child: isSelected ? null : null, // Placeholder if no image
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1B5E38),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Paiement sécurisé, commission 10% incluse',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: () {
          _showPaymentProcessing(context);
        },
        child: const Text('Confirmer et payer 1 650 FCFA'),
      ),
    );
  }

  void _showPaymentProcessing(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1B5E38)),
                  SizedBox(height: 24),
                  Text(
                    'Traitement du paiement...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Simulate payment delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const TrackingScreen()),
      );
    });
  }
}

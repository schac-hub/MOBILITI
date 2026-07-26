import 'package:flutter/material.dart';
import '../payment/payment_screen.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map Placeholder
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE0E0E0),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 100,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                  // Mock Route
                  CustomPaint(
                    size: Size.infinite,
                    painter: RoutePainter(),
                  ),
                ],
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDriverRow(),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    _buildTimeline(),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    _buildEcoAndSecurityBadges(),
                    const SizedBox(height: 24),
                    _buildPriceBreakdown(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentScreen()),
                        );
                      },
                      child: const Text('Réserver ma place'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDriverRow() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=konan'),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konan Yao',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Toyota Corolla • Blanc',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text('245 trajets', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _buildTimelineItem(
          time: '07:15',
          location: 'Andokoi, Yopougon',
          description: 'Point de ramassage (Pharmacie)',
          icon: Icons.radio_button_checked,
          iconColor: const Color(0xFF1B5E38),
          showLine: true,
        ),
        _buildTimelineItem(
          time: '07:50',
          location: 'Sorbonne, Plateau',
          description: 'Point d\'arrivée',
          icon: Icons.location_on,
          iconColor: Colors.red,
          showLine: false,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String location,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool showLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEcoAndSecurityBadges() {
    return Row(
      children: [
        _badge(
          icon: Icons.eco,
          color: const Color(0xFF4CAF50),
          label: '-3.2 kg CO2',
        ),
        const SizedBox(width: 12),
        _badge(
          icon: Icons.verified_user,
          color: const Color(0xFF2196F3),
          label: 'Assuré',
        ),
      ],
    );
  }

  Widget _badge({required IconData icon, required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Détails du prix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _priceRow('Place (1)', '1 500 FCFA'),
        const SizedBox(height: 8),
        _priceRow('Frais de service', '150 FCFA'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
        _priceRow('Total', '1 650 FCFA', isTotal: true),
      ],
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF1B5E38) : Colors.black,
          ),
        ),
      ],
    );
  }
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B5E38)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width * 0.7,
        size.height * 0.2,
      );

    canvas.drawPath(path, paint);

    final startPaint = Paint()..color = const Color(0xFF1B5E38);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 8, startPaint);

    final endPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.2), 8, endPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

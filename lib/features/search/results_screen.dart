import 'package:flutter/material.dart';
import 'trip_detail_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yopougon → Plateau',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '12 trajets disponibles',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildResultCard(
                  context,
                  driverName: 'Diallo M.',
                  driverImage: 'https://i.pravatar.cc/150?u=diallo',
                  time: '07:15',
                  route: 'Sicogi → Plateau',
                  price: '1 200 FCFA',
                  isEco: true,
                  rating: '4.7',
                ),
                const SizedBox(height: 16),
                _buildResultCard(
                  context,
                  driverName: 'Konan Yao',
                  driverImage: 'https://i.pravatar.cc/150?u=konan',
                  time: '07:30',
                  route: 'Selmer → Sorbonne',
                  price: '1 500 FCFA',
                  isEco: false,
                  rating: '4.9',
                ),
                const SizedBox(height: 16),
                _buildResultCard(
                  context,
                  driverName: 'Bamba A.',
                  driverImage: 'https://i.pravatar.cc/150?u=bamba',
                  time: '07:45',
                  route: 'Andokoi → Plateau',
                  price: '1 000 FCFA',
                  isEco: true,
                  rating: '4.5',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1B5E38),
        child: const Icon(Icons.tune, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _filterChip('Prix ↓', isSelected: true),
          _filterChip('Heure'),
          _filterChip('Note'),
          _filterChip('Places'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5E38) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF1B5E38) : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String driverName,
    required String driverImage,
    required String time,
    required String route,
    required String price,
    required bool isEco,
    required String rating,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(driverImage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            driverName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Text(' $rating', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Text(
                        'Toyota Corolla • Noir',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isEco)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.eco, color: Color(0xFF4CAF50), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Éco',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.radio_button_checked, size: 16, color: Color(0xFF1B5E38)),
                    Container(width: 2, height: 20, color: Colors.grey.shade300),
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E38))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        route,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

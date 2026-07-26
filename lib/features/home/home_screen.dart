import 'package:flutter/material.dart';
import '../search/results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
              _buildSearchCard(context),
              const SizedBox(height: 32),
              _buildSuggestedTrips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=aya'),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, Aya 👋',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Où allez-vous aujourd\'hui ?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_outlined, color: Color(0xFF1B5E38)),
        ),
      ],
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildSearchInput(
            icon: Icons.radio_button_checked,
            iconColor: const Color(0xFF1B5E38),
            label: 'D\'où partez-vous?',
            value: 'Yopougon Selmer',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 32, color: Colors.white, thickness: 1),
          ),
          _buildSearchInput(
            icon: Icons.location_on,
            iconColor: Colors.red,
            label: 'Où allez-vous?',
            value: 'Plateau, Abidjan',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF1B5E38)),
                    SizedBox(width: 8),
                    Text(
                      'Aujourd\'hui, 07:30',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Color(0xFF1B5E38)),
                    SizedBox(width: 8),
                    Text(
                      '1',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResultsScreen()),
              );
            },
            child: const Text('Rechercher un trajet'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestedTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trajets suggérés',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Voir tout',
              style: TextStyle(color: Color(0xFF1B5E38), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTripCard(
          driverName: 'Kouassi B.',
          driverImage: 'https://i.pravatar.cc/150?u=kouassi',
          price: '1 500 FCFA',
          time: '07:45',
          route: 'Selmer → Plateau',
          rating: '4.8',
        ),
        const SizedBox(height: 12),
        _buildTripCard(
          driverName: 'Traoré S.',
          driverImage: 'https://i.pravatar.cc/150?u=traore',
          price: '1 200 FCFA',
          time: '08:15',
          route: 'Wassakara → Plateau',
          rating: '4.9',
        ),
      ],
    );
  }

  Widget _buildTripCard({
    required String driverName,
    required String driverImage,
    required String price,
    required String time,
    required String route,
    required String rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(driverImage),
          ),
          const SizedBox(width: 16),
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
                    Text(
                      ' $rating',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  route,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF1B5E38),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B5E38),
            ),
          ),
        ],
      ),
    );
  }
}

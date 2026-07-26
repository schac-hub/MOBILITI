import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profil',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.settings_outlined),
                ],
              ),
              const SizedBox(height: 24),
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildBadgesSection(),
              const SizedBox(height: 24),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=aya'),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aya Kouamé',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Membre depuis Mars 2024',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E38),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('128', 'Trajets', Icons.directions_car_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('4.9', 'Note', Icons.star_outline)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('12kg', 'CO2', Icons.eco_outlined)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1B5E38)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildBadge(Colors.amber),
              _buildBadge(Colors.blue),
              _buildBadge(Colors.green),
              _buildBadge(Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(Color color) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.military_tech, color: color, size: 30),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Historique récent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildHistoryItem('Plateau - Cocody', 'Aujourd\'hui, 14:30', '2 500 FCFA'),
        _buildHistoryItem('Yopougon - Adjame', 'Hier, 08:15', '1 800 FCFA'),
      ],
    );
  }

  Widget _buildHistoryItem(String route, String date, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.history, color: Color(0xFF1B5E38)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E38))),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../chat/conversations_screen.dart';
import '../profile/profile_screen.dart';
import '../search/results_screen.dart';
import '../search/publish_trip_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static const route = '/main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const ResultsScreen(embedded: true),
      const SizedBox(), // placeholder pour Publier (modal)
      const ConversationsScreen(embedded: true),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _index == 2 ? 0 : _index,
        children: [
          pages[0], pages[1], pages[0], pages[3], pages[4],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home,
                    label: 'Accueil', index: 0, current: _index,
                    onTap: () => setState(() => _index = 0)),
                _NavItem(icon: Icons.directions_car_outlined,
                    activeIcon: Icons.directions_car,
                    label: 'Mes trajets', index: 1, current: _index,
                    onTap: () => setState(() => _index = 1)),

                // Bouton Publier central
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openPublish(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 2),
                        const Text('Publier',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),

                _NavItem(icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: 'Messages', index: 3, current: _index,
                    onTap: () => setState(() => _index = 3)),
                _NavItem(icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profil', index: 4, current: _index,
                    onTap: () => setState(() => _index = 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPublish(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PublishTripScreen(),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.current, required this.onTap,
  });
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? activeIcon : icon,
                color: active ? AppColors.primary : AppColors.muted,
                size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? AppColors.primary : AppColors.muted,
                )),
            if (active)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 20, height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedded = false});
  static const route = '/profile';
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final body = user == null
        ? _buildGuest(context)
        : _buildProfile(context, user);

    if (embedded) return body;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _buildGuest(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_outline, size: 64, color: AppColors.muted),
        const SizedBox(height: 16),
        const Text('Connectez-vous pour voir votre profil',
            style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, LoginScreen.route),
          child: const Text('Se connecter'),
        ),
      ],
    ),
  );

  Widget _buildProfile(BuildContext context, UserModel user) {
    final joinedMonth = _fmtDate(user.createdAt);
    final co2 = (user.totalTripsCompleted * 2.5).toStringAsFixed(0);
    final trips = user.totalTripsCompleted;
    final rating = user.rating.toStringAsFixed(1);

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: ClipOval(
                    child: user.profilePicture != null
                        ? Image.network(user.profilePicture!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _avatarFallback(user))
                        : _avatarFallback(user),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: AppColors.text)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Membre depuis $joinedMonth',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
          ),

          // ── Stats ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _StatCard(
                    icon: Icons.directions_car_rounded,
                    value: '$trips', label: 'Trajets')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                    icon: Icons.star_rounded,
                    value: rating, label: 'Note moyenne',
                    valueColor: AppColors.star)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                    icon: Icons.eco_rounded,
                    value: '$co2 kg', label: 'CO₂ sauvés')),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Badges ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Récompenses Éco',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.text)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Badge(icon: Icons.eco, label: 'Éco-héros', unlocked: trips >= 1),
                    _Badge(icon: Icons.verified_user, label: 'Vérifié', unlocked: user.isVerified),
                    _Badge(icon: Icons.workspace_premium, label: 'Pionnier', unlocked: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Historique ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Derniers trajets',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.text)),
                const SizedBox(height: 12),
                StreamBuilder<List<TripModel>>(
                  stream: TripService().getActiveTrips(),
                  builder: (_, snap) {
                    final items = snap.data?.take(3).toList() ?? [];
                    if (items.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(child: Text('Aucun trajet récent', style: TextStyle(color: AppColors.muted))),
                      );
                    }
                    return Column(
                      children: items.map((t) => _HistoryItem(trip: t)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Menu ─────────────────────────────────────────────────────
          const Divider(height: 1),
          _MenuItem(icon: Icons.settings_outlined, label: 'Paramètres du compte', onTap: () {}),
          _MenuItem(icon: Icons.notifications_none_rounded, label: 'Notifications', onTap: () {}),
          _MenuItem(icon: Icons.security_rounded, label: 'Sécurité et confidentialité', onTap: () {}),
          _MenuItem(
            icon: Icons.logout_rounded,
            label: 'Se déconnecter',
            color: AppColors.danger,
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, LoginScreen.route, (_) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(UserModel user) => Container(
    color: AppColors.primaryLight,
    child: Center(
      child: Text(user.initials,
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 36)),
    ),
  );

  String _fmtDate(DateTime d) {
    const m = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${m[d.month - 1]} ${d.year}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color? valueColor;
  const _StatCard({required this.icon, required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
    ),
    child: Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: valueColor ?? AppColors.text)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10), textAlign: TextAlign.center),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool unlocked;
  const _Badge({required this.icon, required this.label, required this.unlocked});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          color: unlocked ? AppColors.primaryLight : AppColors.surface,
          shape: BoxShape.circle,
          border: unlocked ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Icon(icon, color: unlocked ? AppColors.primary : AppColors.muted, size: 30),
      ),
      const SizedBox(height: 8),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: unlocked ? FontWeight.w700 : FontWeight.w500, color: unlocked ? AppColors.text : AppColors.muted)),
    ],
  );
}

class _HistoryItem extends StatelessWidget {
  final TripModel trip;
  const _HistoryItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: AppColors.muted),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${trip.departure.address.split(',').first} → ${trip.destination.address.split(',').first}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${trip.departureTime.day}/${trip.departureTime.month}/${trip.departureTime.year}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          Text('${trip.pricePerSeat.toInt()} F', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? AppColors.text.withValues(alpha: 0.7)),
    title: Text(label, style: TextStyle(color: color ?? AppColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    onTap: onTap,
  );
}

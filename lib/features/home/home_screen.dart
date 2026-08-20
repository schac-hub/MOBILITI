import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../search/results_screen.dart';
import '../search/trip_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _departure = 'Yopougon Selmer';
  String _arrival = 'Plateau, Abidjan';
  DateTime _date = DateTime.now();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _search() {
    Navigator.pushNamed(context, ResultsScreen.route, arguments: {
      'departure': _departure,
      'arrival': _arrival,
      'date': _date,
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _fmtDate() {
    final now = DateTime.now();
    final diff = _date.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return "Aujourd'hui, ${_fmtHour()}";
    if (diff == 1) return "Demain, ${_fmtHour()}";
    const m = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
                'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${_date.day} ${m[_date.month - 1]}, ${_fmtHour()}';
  }

  String _fmtHour() => '07:30';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = user?.firstName ?? 'Aya';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── Header ───────────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: user?.profilePicture != null
                      ? NetworkImage(user!.profilePicture!)
                      : null,
                  child: user?.profilePicture == null
                      ? Text(firstName[0],
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bonjour, $firstName 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: AppColors.text, size: 26),
                      onPressed: () {},
                    ),
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Carte recherche ───────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Départ
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      children: [
                        _LocationRow(
                          icon: Icons.circle,
                          iconColor: AppColors.primary,
                          label: "D'où partez-vous ?",
                          value: _departure,
                          onTap: () async {
                            final v = await _showLocationPicker(
                                context, 'Départ', _departure);
                            if (v != null) setState(() => _departure = v);
                          },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16,
                            color: AppColors.border),
                        _LocationRow(
                          icon: Icons.location_on,
                          iconColor: AppColors.primary,
                          label: 'Où allez-vous ?',
                          value: _arrival,
                          onTap: () async {
                            final v = await _showLocationPicker(
                                context, 'Arrivée', _arrival);
                            if (v != null) setState(() => _arrival = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Date
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Text(_fmtDate(),
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.muted, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bouton Rechercher
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const Text(
                        'Rechercher un trajet',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Trajets suggérés ──────────────────────────────────────────
            const Text('Trajets suggérés',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text)),
            const SizedBox(height: 14),

            StreamBuilder<List<TripModel>>(
              stream: TripService().getActiveTrips(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  ));
                }
                final trips = snap.data ?? _mockTrips();
                return Column(
                  children: trips
                      .take(4)
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TripCard(trip: t),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showLocationPicker(
      BuildContext ctx, String title, String current) async {
    final ctrl = TextEditingController(text: current);
    List<String> currentSuggestions = _suggestions(title);

    return showModalBottomSheet<String>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 16, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.text)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                onChanged: (value) {
                  setModalState(() {
                    currentSuggestions = _suggestions(title)
                        .where((s) => s.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Ex: Yopougon Niangon',
                  prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 12),
              if (currentSuggestions.isEmpty && ctrl.text.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
                  title: Text('Utiliser "${ctrl.text}"'),
                  onTap: () => Navigator.pop(ctx, ctrl.text),
                ),
              ...currentSuggestions.map((s) => ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: AppColors.primary),
                    title: Text(s),
                    onTap: () => Navigator.pop(ctx, s),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _suggestions(String type) {
    if (type == 'Départ') {
      return ['Yopougon Selmer', 'Yopougon Andokoi', 'Yopougon Niangon',
              'Yopougon Siporex', 'Yopougon Maroc'];
    }
    return ['Plateau, Abidjan', 'Adjamé', 'Cocody', 'Marcory', 'Treichville'];
  }

  List<TripModel> _mockTrips() => [
    TripModel(
      id: 'mock1', driverId: 'd1',
      driverName: 'Kouassi B.', driverPhoto: '',
      driverRating: 4.8,
      departure: Location(address: 'Niangon', latitude: 5.355, longitude: -4.028),
      destination: Location(address: 'Adjamé', latitude: 5.369, longitude: -4.019),
      departureTime: DateTime.now().copyWith(hour: 7, minute: 15),
      availableSeats: 3, bookedSeats: 1, pricePerSeat: 1500,
      createdAt: DateTime.now(), carModel: 'Toyota Corolla',
      carColor: 'Gris', licensePlate: 'AB-1234-XY',
    ),
    TripModel(
      id: 'mock2', driverId: 'd2',
      driverName: 'Kouassi B.', driverPhoto: '',
      driverRating: 4.8,
      departure: Location(address: 'Niangon', latitude: 5.355, longitude: -4.028),
      destination: Location(address: 'Adjamé', latitude: 5.369, longitude: -4.019),
      departureTime: DateTime.now().copyWith(hour: 7, minute: 30),
      availableSeats: 2, bookedSeats: 0, pricePerSeat: 1500,
      createdAt: DateTime.now(), carModel: 'Honda Civic',
      carColor: 'Blanc', licensePlate: 'CD-5678-XY',
    ),
  ];
}

// ─── Widget ligne localisation ─────────────────────────────────────────────────
class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon, required this.iconColor,
    required this.label, required this.value, required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.muted, size: 20),
        ],
      ),
    ),
  );
}

// ─── TripCard réutilisé dans ResultsScreen ─────────────────────────────────────
class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip});
  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final hh = trip.departureTime.hour.toString().padLeft(2, '0');
    final mm = trip.departureTime.minute.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context, TripDetailScreen.route, arguments: trip.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Photo conducteur
            Column(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    trip.driverName.isNotEmpty ? trip.driverName[0] : 'K',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(height: 4),
                Text(trip.driverName.split(' ').first,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.star, size: 11),
                    Text(' ${trip.driverRating.toStringAsFixed(1)}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Heure + route
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$hh:$mm',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle),
                          ),
                          Container(
                            width: 1, height: 18,
                            color: AppColors.muted,
                          ),
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.text,
                                shape: BoxShape.circle),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip.departure.address,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.text)),
                          const SizedBox(height: 10),
                          Text(trip.destination.address,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.text)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('~${trip.estimatedDuration} min',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),

            // Prix + places + badge Éco
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${trip.pricePerSeat.toInt()} FCFA',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                const SizedBox(height: 4),
                Text('${trip.availableSeatsNow} places',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 8),
                if (trip.isEcoFriendly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Éco',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

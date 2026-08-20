import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../home/home_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, this.embedded = false});
  static const route = '/results';
  final bool embedded;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _filterIndex = 0;
  final _filters = ['Prix ↓', 'Heure', 'Note', 'Places'];
  String _departure = 'Yopougon';
  String _arrival = 'Plateau';
  DateTime? _date;
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
      if (mounted) setState(() {}); // Force rebuild of StreamBuilder
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      _departure = args['departure'] ?? 'Yopougon';
      _arrival = args['arrival'] ?? 'Plateau';
      _date = args['date'] as DateTime?;
    }
  }

  List<TripModel> _filterAndSortTrips(List<TripModel> trips) {
    var filtered = trips.where((t) {
      final fromMatch = t.departure.address.toLowerCase().contains(_departure.toLowerCase());
      final toMatch = t.destination.address.toLowerCase().contains(_arrival.toLowerCase());
      
      bool dateMatch = true;
      if (_date != null) {
        dateMatch = t.departureTime.year == _date!.year &&
                    t.departureTime.month == _date!.month &&
                    t.departureTime.day == _date!.day;
      }
      
      return fromMatch && toMatch && dateMatch;
    }).toList();

    switch (_filterIndex) {
      case 0: filtered.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
      case 1: filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      case 2: filtered.sort((a, b) => b.driverRating.compareTo(a.driverRating));
      case 3: filtered.sort((a, b) => b.availableSeatsNow.compareTo(a.availableSeatsNow));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            if (!widget.embedded)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.text),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('$_departure → $_arrival',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.text)),
                          StreamBuilder<List<TripModel>>(
                            stream: TripService().getActiveTrips(),
                            builder: (_, snap) {
                              final count = _filterAndSortTrips(snap.data ?? []).length;
                              return Text('$count trajets disponibles',
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 12));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

            // ── Filtres ──────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: List.generate(_filters.length, (i) {
                  final active = i == _filterIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: active ? AppColors.primary : AppColors.border,
                            width: active ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_filters[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: active ? AppColors.primary : AppColors.text,
                            )),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // ── Liste trajets ─────────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<TripModel>>(
                stream: TripService().getActiveTrips(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2));
                  }
                  final trips = _filterAndSortTrips(snap.data ?? []);

                  if (trips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: AppColors.muted),
                          const SizedBox(height: 16),
                          Text('Aucun trajet trouvé pour cette route.',
                              style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: trips.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => TripCard(trip: trips[i]),
                  );
                },
              ),
            ),
          ],
        ),

        // ── Bouton filtre flottant ────────────────────────────────────────
        Positioned(
          bottom: 20,
          left: 0, right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(backgroundColor: Colors.white, body: SafeArea(child: body));
  }
}

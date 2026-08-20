import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../payment/payment_screen.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});
  static const route = '/trip-detail';
  final String tripId;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  TripModel? _trip;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    try {
      final t = await TripService().getTripById(widget.tripId);
      if (mounted) setState(() { _trip = t ?? _mockTrip(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _trip = _mockTrip(); _loading = false; });
    }
  }

  TripModel _mockTrip() => TripModel(
    id: widget.tripId, driverId: 'd1',
    driverName: 'Konan Yao', driverPhoto: '',
    driverRating: 4.9,
    departure: Location(address: 'Yopougon Andokoi', latitude: 5.362, longitude: -4.042),
    destination: Location(address: 'Plateau Sorbonne', latitude: 5.317, longitude: -4.013),
    departureTime: DateTime.now().copyWith(hour: 7, minute: 15),
    arrivalTime: DateTime.now().copyWith(hour: 7, minute: 50),
    availableSeats: 3, bookedSeats: 0, pricePerSeat: 1500,
    estimatedDuration: 35, distance: 12.4,
    carModel: 'Toyota Corolla', carColor: 'Gris',
    licensePlate: 'AB-1234-XY',
    createdAt: DateTime.now(), isEcoFriendly: true,
    totalTripsAsDriver: 128,
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final trip = _trip!;
    final dep = LatLng(trip.departure.latitude, trip.departure.longitude);
    final arr = LatLng(trip.destination.latitude, trip.destination.longitude);
    final midLat = (dep.latitude + arr.latitude) / 2;
    final midLng = (dep.longitude + arr.longitude) / 2;

    final commission = (trip.pricePerSeat * 0.10).round();
    final total = trip.pricePerSeat.toInt() + commission;
    final co2 = (trip.distance * 0.21 * 0.8).toStringAsFixed(1);

    final depH = trip.departureTime.hour.toString().padLeft(2, '0');
    final depM = trip.departureTime.minute.toString().padLeft(2, '0');
    final arrH = (trip.arrivalTime ?? trip.departureTime.add(
        Duration(minutes: trip.estimatedDuration))).hour.toString().padLeft(2, '0');
    final arrM = (trip.arrivalTime ?? trip.departureTime.add(
        Duration(minutes: trip.estimatedDuration))).minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Carte Google Maps ──────────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(midLat, midLng), zoom: 13),
              onMapCreated: (c) {
              },
              markers: {
                Marker(markerId: const MarkerId('A'), position: dep,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                    infoWindow: const InfoWindow(title: 'A')),
                Marker(markerId: const MarkerId('B'), position: arr,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                    infoWindow: const InfoWindow(title: 'B')),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [dep, arr],
                  color: AppColors.primary,
                  width: 5,
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),

          // ── Header flottant ────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16,
            child: Row(
              children: [
                _FloatBtn(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context)),
                const Spacer(),
                const Text('Mobiliti',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20)),
                const Spacer(),
                _FloatBtn(
                    icon: Icons.share_outlined, onTap: () {}),
              ],
            ),
          ),

          // ── Bottom Sheet ───────────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.55,
            maxChildSize: 0.95,
            builder: (_, ctrl) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
              ),
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          trip.driverName.isNotEmpty ? trip.driverName[0] : 'K',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip.driverName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 19,
                                    color: AppColors.text)),
                            Text(
                              '${trip.carModel ?? ''} · ${trip.carColor ?? ''} · ${trip.licensePlate ?? ''}',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 13),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: AppColors.star, size: 14),
                                Text(
                                  ' ${trip.driverRating.toStringAsFixed(1)} (${trip.totalTripsAsDriver} trajets)',
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2))),
                          Container(width: 1, height: 30, color: AppColors.primary),
                          Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(text: TextSpan(children: [TextSpan(text: '$depH:$depM  ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.text)), TextSpan(text: trip.departure.address, style: const TextStyle(fontSize: 15, color: AppColors.text))])),
                          const SizedBox(height: 24),
                          RichText(text: TextSpan(children: [TextSpan(text: '$arrH:$arrM  ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.text)), TextSpan(text: trip.destination.address, style: const TextStyle(fontSize: 15, color: AppColors.text))])),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  _PriceLine(label: 'Prix trajet', value: '${trip.pricePerSeat.toInt()} FCFA'),
                  const SizedBox(height: 6),
                  _PriceLine(label: 'Commission (10%)', value: '$commission FCFA'),
                  const Divider(height: 16, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.text)),
                      Text('$total FCFA', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.text)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _BadgeSmall(icon: Icons.eco, label: '-$co2 kg CO₂', color: AppColors.primary),
                      const SizedBox(width: 10),
                      _BadgeSmall(icon: Icons.shield_outlined, label: 'Assuré', color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        PaymentScreen.route,
                        arguments: {
                          'tripId': trip.id,
                          'amount': total.toDouble(),
                        },
                      ),
                      child: const Text('Réserver ma place', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatBtn extends StatelessWidget {
  const _FloatBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)]),
      child: Icon(icon, color: AppColors.text, size: 20),
    ),
  );
}

class _PriceLine extends StatelessWidget {
  final String label, value;
  const _PriceLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
      Text(value, style: const TextStyle(color: AppColors.text, fontSize: 14)),
    ],
  );
}

class _BadgeSmall extends StatelessWidget {
  const _BadgeSmall({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

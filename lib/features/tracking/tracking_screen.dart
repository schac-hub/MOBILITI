import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../chat/chat_screen.dart';
import '../home/main_screen.dart';

class TrackingScreen extends StatefulWidget {
  final String? tripId;
  const TrackingScreen({super.key, this.tripId});

  static const route = '/tracking';

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  LatLng _currentPos = const LatLng(5.3484, -4.0305); // Abidjan
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPos = LatLng(pos.latitude, pos.longitude);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
  }

  void _callSOS() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('APPEL D\'URGENCE'),
        content: const Text('Voulez-vous appeler les secours et alerter vos proches ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('ALERTER'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────────────────────────
          _loading
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: CameraPosition(target: _currentPos, zoom: 15),
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: {
                  Marker(markerId: const MarkerId('driver'), position: _currentPos),
                },
              ),

          // ── Header Overlay ──────────────────────────────────────────
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Arrivée dans 12 min', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── SOS Button ──────────────────────────────────────────────
          Positioned(
            right: 20, bottom: 280,
            child: FloatingActionButton(
              onPressed: _callSOS,
              backgroundColor: AppColors.danger,
              child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),

          // ── Info Bottom Sheet ────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 260,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 25, backgroundColor: AppColors.primaryLight, child: Icon(Icons.person)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Kouassi Bakary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            Text('Toyota Corolla • Gris • AB-123-XY', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, ChatScreen.route),
                        icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Stat(label: 'Prix', value: '1 500 F'),
                      _Stat(label: 'Places', value: '1/3'),
                      _Stat(label: 'Distance', value: '4.2 km'),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, MainScreen.route, (_) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.text,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('TERMINER LE TRAJET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ],
    );
  }
}

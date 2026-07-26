import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late GoogleMapController mapController;

  static const LatLng _start = LatLng(5.348, -4.053); // Siporex
  static const LatLng _end = LatLng(5.337, -4.062); // Carrefour Yopougon
  static const LatLng _currentPos = LatLng(5.342, -4.058); // Somewhere in between

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('start'),
      position: _start,
      infoWindow: InfoWindow(title: 'Siporex'),
    ),
    const Marker(
      markerId: MarkerId('end'),
      position: _end,
      infoWindow: InfoWindow(title: 'Carrefour Yopougon'),
    ),
    Marker(
      markerId: const MarkerId('car'),
      position: _currentPos,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ),
  };

  final Set<Polyline> _polylines = {
    const Polyline(
      polylineId: PolylineId('route'),
      points: [_start, _currentPos, _end],
      color: Color(0xFF1B5E38),
      width: 5,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 55% Top Map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: _buildMap(),
          ),

          // Back Button on Map
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
          ),

          // Bottom Sheet Content
          _buildBottomSheet(context),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (controller) => mapController = controller,
      initialCameraPosition: const CameraPosition(
        target: _currentPos,
        zoom: 14.5,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth > 600 ? 500 : double.infinity;
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: maxWidth,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
              ],
            ),
            child: Column(
              children: [
                // Handle
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusPill(),
                            const Text(
                              'Arrivée dans 18 min · 07:48',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildDriverCard(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
                _buildBottomProgressBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car, color: Color(0xFF4CAF50), size: 16),
          SizedBox(width: 6),
          Text(
            'En route',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=konan'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konan Yao',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Toyota Corolla • Gris',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  'AB-1234-XY',
                  style: TextStyle(
                    color: Color(0xFF1B5E38),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _iconButton(Icons.call, Colors.blue),
              const SizedBox(width: 8),
              _iconButton(Icons.message, const Color(0xFF1B5E38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            label: const Text('SOS Urgence', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Partager position'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomProgressBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF1B5E38),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trajet en cours',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == 2 ? Colors.white : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

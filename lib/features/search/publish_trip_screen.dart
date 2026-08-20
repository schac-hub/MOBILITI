import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';

class PublishTripScreen extends StatefulWidget {
  const PublishTripScreen({super.key});
  static const route = '/publish';

  @override
  State<PublishTripScreen> createState() => _PublishTripScreenState();
}

class _PublishTripScreenState extends State<PublishTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _departureCtrl = TextEditingController(text: 'Yopougon Selmer');
  final _arrivalCtrl = TextEditingController(text: 'Plateau, Abidjan');
  final _priceCtrl = TextEditingController(text: '1500');
  final _seatsCtrl = TextEditingController(text: '3');
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 15);
  bool _loading = false;

  final _departures = [
    'Yopougon Selmer', 'Yopougon Andokoi', 'Yopougon Niangon',
    'Yopougon Siporex', 'Yopougon Maroc', 'Yopougon Toits Rouges',
  ];
  final _arrivals = [
    'Plateau, Abidjan', 'Adjamé', 'Cocody', 'Marcory',
    'Treichville', 'Zone Industrielle Vridi',
  ];

  @override
  void dispose() {
    _departureCtrl.dispose();
    _arrivalCtrl.dispose();
    _priceCtrl.dispose();
    _seatsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // Vérification conducteur
    if (user.userType == 'passenger') {
      _showError('Vous devez être inscrit comme conducteur pour publier un trajet.');
      return;
    }

    setState(() => _loading = true);
    try {
      final dt = DateTime(
          _date.year, _date.month, _date.day, _time.hour, _time.minute);

      final trip = TripModel(
        id: const Uuid().v4(),
        driverId: user.id,
        driverName: user.fullName,
        driverPhoto: user.profilePicture ?? '',
        driverRating: user.rating,
        totalTripsAsDriver: user.totalTripsCompleted,
        departure: Location(
          address: _departureCtrl.text.trim(),
          latitude: 5.3477, longitude: -4.0382,
        ),
        destination: Location(
          address: _arrivalCtrl.text.trim(),
          latitude: 5.3196, longitude: -4.0167,
        ),
        departureTime: dt,
        availableSeats: int.tryParse(_seatsCtrl.text) ?? 3,
        pricePerSeat: double.tryParse(_priceCtrl.text) ?? 1500,
        carModel: user.carModel,
        carColor: user.carColor,
        licensePlate: user.licensePlate,
        createdAt: DateTime.now(),
        isEcoFriendly: true,
      );

      await TripService().createTrip(trip);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trajet publié avec succès !'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  String _fmtDate() {
    const m = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
                'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${_date.day} ${m[_date.month - 1]} ${_date.year}';
  }

  String _fmtTime() =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Publier un trajet',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.text, fontSize: 18)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Départ ────────────────────────────────────────────────
            const _Label('Point de départ'),
            _DropField(
              controller: _departureCtrl,
              hint: 'Yopougon Selmer',
              items: _departures,
              icon: Icons.circle,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: 14),

            // ── Arrivée ───────────────────────────────────────────────
            const _Label('Point d\'arrivée'),
            _DropField(
              controller: _arrivalCtrl,
              hint: 'Plateau, Abidjan',
              items: _arrivals,
              icon: Icons.location_on,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: 14),

            // ── Date + Heure ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Date'),
                      GestureDetector(
                        onTap: _pickDate,
                        child: _InfoBox(
                            icon: Icons.calendar_today_outlined,
                            text: _fmtDate()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Heure'),
                      GestureDetector(
                        onTap: _pickTime,
                        child: _InfoBox(
                            icon: Icons.access_time_outlined,
                            text: _fmtTime()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Places + Prix ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Places disponibles'),
                      TextFormField(
                        controller: _seatsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDeco('3', Icons.event_seat_outlined),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Requis'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Prix par place (FCFA)'),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            _inputDeco('1500', Icons.monetization_on_outlined),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Requis'
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Note transparence CO2 ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ce trajet partagé économisera environ '
                      '${(_computeDistance() * 0.21 * 0.8).toStringAsFixed(1)} kg CO₂.',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Bouton Publier ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Publier le trajet',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _computeDistance() => 12.0; // distance fixe Yopougon→Plateau MVP

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 18, color: AppColors.muted),
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
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.text)),
  );
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: AppColors.text)),
      ],
    ),
  );
}

class _DropField extends StatelessWidget {
  const _DropField({
    required this.controller, required this.hint,
    required this.items, required this.icon, required this.iconColor,
  });
  final TextEditingController controller;
  final String hint;
  final List<String> items;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: items.contains(controller.text) ? controller.text : null,
    hint: Text(hint),
    items: items
        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
        .toList(),
    onChanged: (v) { if (v != null) controller.text = v; },
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: iconColor, size: 14),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
    validator: (v) => v == null ? 'Sélectionnez une option' : null,
  );
}

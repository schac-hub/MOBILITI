import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class TripService {
  final _db = FirebaseFirestore.instance;

  // Stream trajets actifs (accueil + résultats)
  Stream<List<TripModel>> getActiveTrips() => _db
      .collection('trips')
      .where('status', whereIn: ['scheduled', 'active'])
      .orderBy('departureTime')
      .snapshots()
      .map((s) => s.docs.map((d) => TripModel.fromMap(d.data(), d.id)).toList());

  // Récupère un trajet par ID  ← alias pour compatibilité
  Future<TripModel?> getTrip(String tripId) => getTripById(tripId);

  Future<TripModel?> getTripById(String tripId) async {
    final doc = await _db.collection('trips').doc(tripId).get();
    if (doc.exists && doc.data() != null) {
      return TripModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Trajets d'un utilisateur (passager) — pour l'historique profil
  Future<List<TripModel>> getUserTrips(String userId) async {
    try {
      final snap = await _db
          .collection('trips')
          .where('passengerIds', arrayContains: userId)
          .orderBy('departureTime', descending: true)
          .limit(10)
          .get();
      return snap.docs.map((d) => TripModel.fromMap(d.data(), d.id)).toList();
    } catch (_) {
      return [];
    }
  }

  // Trajets d'un conducteur
  Future<List<TripModel>> getDriverTrips(String driverId) async {
    final snap = await _db
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .orderBy('departureTime', descending: true)
        .get();
    return snap.docs.map((d) => TripModel.fromMap(d.data(), d.id)).toList();
  }

  // Recherche par départ/arrivée/date
  Future<List<TripModel>> searchTrips({
    String? from, String? to, DateTime? date,
  }) async {
    Query q = _db.collection('trips')
        .where('status', whereIn: ['scheduled', 'active']);
    final snap = await q.get();
    var trips = snap.docs
        .map((d) => TripModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    if (from != null && from.isNotEmpty) {
      trips = trips
          .where((t) => t.departure.address
              .toLowerCase()
              .contains(from.toLowerCase()))
          .toList();
    }
    if (to != null && to.isNotEmpty) {
      trips = trips
          .where((t) => t.destination.address
              .toLowerCase()
              .contains(to.toLowerCase()))
          .toList();
    }
    if (date != null) {
      trips = trips
          .where((t) =>
              t.departureTime.year == date.year &&
              t.departureTime.month == date.month &&
              t.departureTime.day == date.day)
          .toList();
    }
    return trips;
  }

  // Créer un trajet (conducteur)
  Future<String> createTrip(TripModel trip) async {
    final ref = _db.collection('trips').doc();
    final t = trip.copyWith(id: ref.id);
    await ref.set(t.toMap());
    return ref.id;
  }

  // Réserver une place (transaction atomique)
  Future<void> bookTrip(String tripId, String passengerId) async {
    await _db.runTransaction((tx) async {
      final ref = _db.collection('trips').doc(tripId);
      final doc = await tx.get(ref);
      if (!doc.exists) throw 'Trajet non trouvé';
      final available = doc.data()?['availableSeats'] ?? 0;
      final booked = doc.data()?['bookedSeats'] ?? 0;
      if (available - booked <= 0) throw 'Plus de places disponibles';

      tx.update(ref, {
        'bookedSeats': booked + 1,
        'passengerIds': FieldValue.arrayUnion([passengerId]),
      });

      final resRef = _db.collection('reservations').doc();
      tx.set(resRef, {
        'tripId': tripId, 'passengerId': passengerId,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Annuler un trajet
  Future<void> cancelTrip(String tripId) async {
    await _db.collection('trips').doc(tripId)
        .update({'status': 'cancelled'});
  }
}

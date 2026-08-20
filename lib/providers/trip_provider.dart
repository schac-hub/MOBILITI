import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_model.dart';
import '../services/firebase_service.dart';

class TripProvider extends ChangeNotifier {
  final _firebaseService = FirebaseService();

  List<TripModel> _availableTrips = [];
  final List<TripModel> _myTrips = [];
  TripModel? _selectedTrip;
  bool _isLoading = false;
  String? _error;

  TripProvider() {
    _loadInitialTrips();
  }

  List<TripModel> get availableTrips => _availableTrips;
  List<TripModel> get myTrips => _myTrips;
  TripModel? get selectedTrip => _selectedTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadInitialTrips() async {
    try {
      _isLoading = true;
      _availableTrips = await _firebaseService.getAvailableTrips(
        latitude: 0,
        longitude: 0,
        date: DateTime.now(),
        passengers: 1,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> searchTrips({
    required double latitude,
    required double longitude,
    required DateTime date,
    required int passengers,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _availableTrips = await _firebaseService.getAvailableTrips(
        latitude: latitude,
        longitude: longitude,
        date: date,
        passengers: passengers,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createTrip({
    required String driverId,
    required String driverName,
    required String driverPhoto,
    required double driverRating,
    required Location departure,
    required Location destination,
    required DateTime departureTime,
    required int availableSeats,
    required double pricePerSeat,
    String? carModel,
    String? carColor,
    String? licensePlate,
    String? notes,
    bool isEcoFriendly = true,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final tripId = const Uuid().v4();
      final trip = TripModel(
        id: tripId,
        driverId: driverId,
        driverName: driverName,
        driverPhoto: driverPhoto,
        driverRating: driverRating,
        departure: departure,
        destination: destination,
        departureTime: departureTime,
        availableSeats: availableSeats,
        pricePerSeat: pricePerSeat,
        carModel: carModel,
        carColor: carColor,
        licensePlate: licensePlate,
        notes: notes,
        isEcoFriendly: isEcoFriendly,
        createdAt: DateTime.now(),
      );

      await _firebaseService.createTrip(trip);
      _myTrips.add(trip);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectTrip(TripModel trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  void clearSelection() {
    _selectedTrip = null;
    notifyListeners();
  }

  Future<void> cancelTrip(String tripId) async {
    try {
      final index = _availableTrips.indexWhere((t) => t.id == tripId);
      if (index != -1) {
        final updatedTrip = _availableTrips[index].copyWith(status: 'cancelled');
        await _firebaseService.updateTrip(updatedTrip);
        _availableTrips.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

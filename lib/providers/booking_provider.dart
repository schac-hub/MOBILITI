import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_model.dart';
import '../services/firebase_service.dart';

class BookingProvider extends ChangeNotifier {
  final _firebaseService = FirebaseService();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> bookTrip({
    required String tripId,
    required String passengerId,
    required int seatsCount,
    required double totalPrice,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final bookingId = const Uuid().v4();
      final booking = Booking(
        id: bookingId,
        tripId: tripId,
        passengerId: passengerId,
        seatsBooked: seatsCount,
        totalPrice: totalPrice,
        status: 'pending',
        bookedAt: DateTime.now(),
      );

      await _firebaseService.createBooking(booking);
      _bookings.add(booking);

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

  Future<void> loadUserBookings(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _bookings = await _firebaseService.getUserBookings(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
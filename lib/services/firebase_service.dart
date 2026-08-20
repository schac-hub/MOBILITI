import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../core/constants/app_constants.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== USER METHODS ====================
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  Future<String?> getEmailByPhone(String phone) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('phoneNumber', isEqualTo: phone)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['email'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // ==================== TRIP METHODS ====================
  Future<void> createTrip(TripModel trip) async {
    try {
      await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(trip.id)
          .set(trip.toMap());
    } catch (e) {
      throw Exception('Error creating trip: $e');
    }
  }

  Future<TripModel?> getTrip(String tripId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(tripId)
          .get();

      if (doc.exists) {
        return TripModel.fromMap(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      throw Exception('Error getting trip: $e');
    }
  }

  Future<List<TripModel>> getAvailableTrips({
    required double latitude,
    required double longitude,
    required DateTime date,
    required int passengers,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(AppConstants.tripsCollection)
          .where('status', isEqualTo: 'scheduled')
          .where('departureTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('departureTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs
          .map((doc) => TripModel.fromMap(doc.data()))
          .where((trip) => trip.availableSeatsNow >= passengers)
          .toList();
    } catch (e) {
      throw Exception('Error getting trips: $e');
    }
  }

  Future<List<TripModel>> getDriverTrips(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.tripsCollection)
          .where('driverId', isEqualTo: driverId)
          .orderBy('departureTime', descending: true)
          .get();

      return snapshot.docs.map((doc) => TripModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Error getting driver trips: $e');
    }
  }

  Future<void> updateTrip(TripModel trip) async {
    try {
      await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(trip.id)
          .update(trip.toMap());
    } catch (e) {
      throw Exception('Error updating trip: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore
          .collection(AppConstants.tripsCollection)
          .doc(tripId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting trip: $e');
    }
  }

  // ==================== BOOKING METHODS ====================
  Future<void> createBooking(Booking booking) async {
    try {
      await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('passengerId', isEqualTo: userId)
          .orderBy('bookedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Booking.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Error getting bookings: $e');
    }
  }

  // ==================== STREAM METHODS ====================
  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data() ?? {}) : null);
  }

  Stream<List<TripModel>> tripsStream() {
    return _firestore
        .collection(AppConstants.tripsCollection)
        .where('status', isEqualTo: 'scheduled')
        .orderBy('departureTime')
        .limit(50)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TripModel.fromMap(doc.data())).toList());
  }
}

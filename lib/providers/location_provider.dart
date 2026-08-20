import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import '../models/trip_model.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  Location? _selectedDeparture;
  Location? _selectedDestination;
  final List<Location> _suggestedLocations = [];
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  Location? get selectedDeparture => _selectedDeparture;
  Location? get selectedDestination => _selectedDestination;
  List<Location> get suggestedLocations => _suggestedLocations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> requestLocationPermission() async {
    try {
      final status = await Geolocator.requestPermission();
      return status == LocationPermission.always ||
          status == LocationPermission.whileInUse;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> getCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentPosition = position;

      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address =
            '${placemark.street}, ${placemark.postalCode} ${placemark.locality}';

        _selectedDeparture = Location(
          address: address,
          latitude: position.latitude,
          longitude: position.longitude,
          city: placemark.locality,
        );
      }

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

  Future<void> setDestination(Location location) async {
    _selectedDestination = location;
    notifyListeners();
  }

  void setDeparture(Location location) {
    _selectedDeparture = location;
    notifyListeners();
  }

  void swapLocations() {
    if (_selectedDeparture != null && _selectedDestination != null) {
      final temp = _selectedDeparture;
      _selectedDeparture = _selectedDestination;
      _selectedDestination = temp;
      notifyListeners();
    }
  }

  void clearLocations() {
    _selectedDeparture = null;
    _selectedDestination = null;
    _suggestedLocations.clear();
    notifyListeners();
  }
}
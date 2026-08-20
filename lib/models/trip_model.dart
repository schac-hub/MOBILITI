import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;
  final String? city;

  Location({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.city,
  });

  Map<String, dynamic> toMap() => {
    'address': address, 'latitude': latitude,
    'longitude': longitude, 'placeId': placeId, 'city': city,
  };

  factory Location.fromMap(Map<String, dynamic> map) => Location(
    address: map['address'] ?? '',
    latitude: (map['latitude'] ?? 0).toDouble(),
    longitude: (map['longitude'] ?? 0).toDouble(),
    placeId: map['placeId'],
    city: map['city'],
  );
}

class TripModel {
  final String id;
  final String driverId;
  final String driverName;
  final String driverPhoto;
  final double driverRating;
  final int totalTripsAsDriver;   // ← AJOUTÉ
  final Location departure;
  final Location destination;
  final DateTime departureTime;
  final DateTime? arrivalTime;
  final int availableSeats;
  final int bookedSeats;
  final double pricePerSeat;
  final String status;
  final double distance;
  final int estimatedDuration;
  final String? carModel;
  final String? carColor;
  final String? licensePlate;
  final List<String> passengerIds;
  final DateTime createdAt;
  final String? notes;
  final bool isEcoFriendly;

  TripModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhoto,
    required this.driverRating,
    this.totalTripsAsDriver = 0,
    required this.departure,
    required this.destination,
    required this.departureTime,
    this.arrivalTime,
    this.availableSeats = 4,
    this.bookedSeats = 0,
    this.pricePerSeat = 1500,
    this.status = 'scheduled',
    this.distance = 0,
    this.estimatedDuration = 35,
    this.carModel,
    this.carColor,
    this.licensePlate,
    this.passengerIds = const [],
    required this.createdAt,
    this.notes,
    this.isEcoFriendly = true,
  });

  int get availableSeatsNow => availableSeats - bookedSeats;
  bool get isFull => availableSeatsNow <= 0;
  String get from => departure.address;
  String get to => destination.address;

  Map<String, dynamic> toMap() => {
    'id': id, 'driverId': driverId,
    'driverName': driverName, 'driverPhoto': driverPhoto,
    'driverRating': driverRating, 'totalTripsAsDriver': totalTripsAsDriver,
    'departure': departure.toMap(), 'destination': destination.toMap(),
    'departureTime': Timestamp.fromDate(departureTime),
    'arrivalTime': arrivalTime != null ? Timestamp.fromDate(arrivalTime!) : null,
    'availableSeats': availableSeats, 'bookedSeats': bookedSeats,
    'pricePerSeat': pricePerSeat, 'status': status,
    'distance': distance, 'estimatedDuration': estimatedDuration,
    'carModel': carModel, 'carColor': carColor, 'licensePlate': licensePlate,
    'passengerIds': passengerIds, 'createdAt': Timestamp.fromDate(createdAt),
    'notes': notes, 'isEcoFriendly': isEcoFriendly,
  };

  factory TripModel.fromMap(Map<String, dynamic> map, [String? docId]) => TripModel(
    id: docId ?? map['id'] ?? '',
    driverId: map['driverId'] ?? '',
    driverName: map['driverName'] ?? '',
    driverPhoto: map['driverPhoto'] ?? '',
    driverRating: (map['driverRating'] ?? 5.0).toDouble(),
    totalTripsAsDriver: map['totalTripsAsDriver'] ?? 0,
    departure: Location.fromMap(map['departure'] ?? {}),
    destination: Location.fromMap(map['destination'] ?? {}),
    departureTime: (map['departureTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    arrivalTime: (map['arrivalTime'] as Timestamp?)?.toDate(),
    availableSeats: map['availableSeats'] ?? 4,
    bookedSeats: map['bookedSeats'] ?? 0,
    pricePerSeat: (map['pricePerSeat'] ?? 1500).toDouble(),
    status: map['status'] ?? 'scheduled',
    distance: (map['distance'] ?? 0).toDouble(),
    estimatedDuration: map['estimatedDuration'] ?? 35,
    carModel: map['carModel'],
    carColor: map['carColor'],
    licensePlate: map['licensePlate'],
    passengerIds: List<String>.from(map['passengerIds'] ?? []),
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    notes: map['notes'],
    isEcoFriendly: map['isEcoFriendly'] ?? true,
  );

  TripModel copyWith({
    String? id, String? driverId, String? driverName, String? driverPhoto,
    double? driverRating, int? totalTripsAsDriver,
    Location? departure, Location? destination,
    DateTime? departureTime, DateTime? arrivalTime,
    int? availableSeats, int? bookedSeats, double? pricePerSeat,
    String? status, double? distance, int? estimatedDuration,
    String? carModel, String? carColor, String? licensePlate,
    List<String>? passengerIds, DateTime? createdAt,
    String? notes, bool? isEcoFriendly,
  }) => TripModel(
    id: id ?? this.id, driverId: driverId ?? this.driverId,
    driverName: driverName ?? this.driverName,
    driverPhoto: driverPhoto ?? this.driverPhoto,
    driverRating: driverRating ?? this.driverRating,
    totalTripsAsDriver: totalTripsAsDriver ?? this.totalTripsAsDriver,
    departure: departure ?? this.departure,
    destination: destination ?? this.destination,
    departureTime: departureTime ?? this.departureTime,
    arrivalTime: arrivalTime ?? this.arrivalTime,
    availableSeats: availableSeats ?? this.availableSeats,
    bookedSeats: bookedSeats ?? this.bookedSeats,
    pricePerSeat: pricePerSeat ?? this.pricePerSeat,
    status: status ?? this.status, distance: distance ?? this.distance,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    carModel: carModel ?? this.carModel, carColor: carColor ?? this.carColor,
    licensePlate: licensePlate ?? this.licensePlate,
    passengerIds: passengerIds ?? this.passengerIds,
    createdAt: createdAt ?? this.createdAt,
    notes: notes ?? this.notes, isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
  );
}

class Booking {
  final String id;
  final String tripId;
  final String passengerId;
  final int seatsBooked;
  final double totalPrice;
  final String status;
  final DateTime bookedAt;

  Booking({
    required this.id, required this.tripId,
    required this.passengerId, required this.seatsBooked,
    required this.totalPrice, this.status = 'pending',
    required this.bookedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'tripId': tripId, 'passengerId': passengerId,
    'seatsBooked': seatsBooked, 'totalPrice': totalPrice,
    'status': status, 'bookedAt': Timestamp.fromDate(bookedAt),
  };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
    id: map['id'] ?? '', tripId: map['tripId'] ?? '',
    passengerId: map['passengerId'] ?? '',
    seatsBooked: map['seatsBooked'] ?? 1,
    totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    status: map['status'] ?? 'pending',
    bookedAt: (map['bookedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

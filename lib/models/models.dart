import 'package:cloud_firestore/cloud_firestore.dart';

// ======================== USER MODELS ========================
class User {
  final String id;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String userType; // 'passenger' ou 'driver'
  final double rating;
  final int reviewCount;
  final List<String> savedLocations;
  final DateTime createdAt;
  final bool isVerified;
  final String? carModel;
  final String? licensePlate;
  final String? carColor;

  User({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.userType = 'passenger',
    this.rating = 5.0,
    this.reviewCount = 0,
    this.savedLocations = const [],
    required this.createdAt,
    this.isVerified = false,
    this.carModel,
    this.licensePlate,
    this.carColor,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
      'userType': userType,
      'rating': rating,
      'reviewCount': reviewCount,
      'savedLocations': savedLocations,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
      'carModel': carModel,
      'licensePlate': licensePlate,
      'carColor': carColor,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      profilePicture: map['profilePicture'],
      userType: map['userType'] ?? 'passenger',
      rating: (map['rating'] ?? 5.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      savedLocations: List<String>.from(map['savedLocations'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      carModel: map['carModel'],
      licensePlate: map['licensePlate'],
      carColor: map['carColor'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? userType,
    double? rating,
    int? reviewCount,
    List<String>? savedLocations,
    DateTime? createdAt,
    bool? isVerified,
    String? carModel,
    String? licensePlate,
    String? carColor,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      userType: userType ?? this.userType,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      savedLocations: savedLocations ?? this.savedLocations,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      carModel: carModel ?? this.carModel,
      licensePlate: licensePlate ?? this.licensePlate,
      carColor: carColor ?? this.carColor,
    );
  }
}

// ======================== TRIP MODELS ========================
class Trip {
  final String id;
  final String driverId;
  final String passengerId;
  final Location departure;
  final Location destination;
  final DateTime departureTime;
  final DateTime? arrivalTime;
  final int availableSeats;
  final int bookedSeats;
  final double pricePerSeat;
  final String status; // 'scheduled', 'in_progress', 'completed', 'cancelled'
  final double distance;
  final int estimatedDuration; // en minutes
  final String? vehicleId;
  final List<String> passengerIds;
  final DateTime createdAt;
  final String? notes;
  final List<Map<String, dynamic>> waypoints;

  Trip({
    required this.id,
    required this.driverId,
    required this.passengerId,
    required this.departure,
    required this.destination,
    required this.departureTime,
    this.arrivalTime,
    this.availableSeats = 4,
    this.bookedSeats = 0,
    this.pricePerSeat = 5.0,
    this.status = 'scheduled',
    this.distance = 0,
    this.estimatedDuration = 30,
    this.vehicleId,
    this.passengerIds = const [],
    required this.createdAt,
    this.notes,
    this.waypoints = const [],
  });

  double get totalPrice => pricePerSeat * bookedSeats;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'passengerId': passengerId,
      'departure': departure.toMap(),
      'destination': destination.toMap(),
      'departureTime': Timestamp.fromDate(departureTime),
      'arrivalTime': arrivalTime != null ? Timestamp.fromDate(arrivalTime!) : null,
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'pricePerSeat': pricePerSeat,
      'status': status,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'vehicleId': vehicleId,
      'passengerIds': passengerIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'waypoints': waypoints,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      driverId: map['driverId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      departure: Location.fromMap(map['departure'] ?? {}),
      destination: Location.fromMap(map['destination'] ?? {}),
      departureTime: (map['departureTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      arrivalTime: (map['arrivalTime'] as Timestamp?)?.toDate(),
      availableSeats: map['availableSeats'] ?? 4,
      bookedSeats: map['bookedSeats'] ?? 0,
      pricePerSeat: (map['pricePerSeat'] ?? 5.0).toDouble(),
      status: map['status'] ?? 'scheduled',
      distance: (map['distance'] ?? 0).toDouble(),
      estimatedDuration: map['estimatedDuration'] ?? 30,
      vehicleId: map['vehicleId'],
      passengerIds: List<String>.from(map['passengerIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      waypoints: List<Map<String, dynamic>>.from(map['waypoints'] ?? []),
    );
  }
}

// ======================== LOCATION MODEL ========================
class Location {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;

  Location({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      placeId: map['placeId'],
    );
  }
}

// ======================== BOOKING MODEL ========================
class Booking {
  final String id;
  final String tripId;
  final String passengerId;
  final int seatsBooked;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime bookedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  Booking({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.seatsBooked,
    required this.totalPrice,
    this.status = 'pending',
    required this.bookedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'passengerId': passengerId,
      'seatsBooked': seatsBooked,
      'totalPrice': totalPrice,
      'status': status,
      'bookedAt': Timestamp.fromDate(bookedAt),
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      tripId: map['tripId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      seatsBooked: map['seatsBooked'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      bookedAt: (map['bookedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cancelledAt: (map['cancelledAt'] as Timestamp?)?.toDate(),
      cancellationReason: map['cancellationReason'],
    );
  }
}

// ======================== REVIEW MODEL ========================
class Review {
  final String id;
  final String tripId;
  final String authorId;
  final String targetId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? tags;

  Review({
    required this.id,
    required this.tripId,
    required this.authorId,
    required this.targetId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'authorId': authorId,
      'targetId': targetId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      tripId: map['tripId'] ?? '',
      authorId: map['authorId'] ?? '',
      targetId: map['targetId'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

// ======================== MESSAGE MODEL ========================
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }
}

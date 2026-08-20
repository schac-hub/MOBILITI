import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String userType; // 'passenger', 'driver', 'both'
  final double rating;
  final int reviewCount;
  final List<String> savedLocations;
  final DateTime createdAt;
  final bool isVerified;
  final bool isPhoneVerified;
  final bool isEmailVerified;

  // Driver specific
  final String? carModel;
  final String? licensePlate;
  final String? carColor;
  final String? licenseNumber;
  final String? insuranceNumber;
  final DateTime? licenseExpiryDate;
  final DateTime? insuranceExpiryDate;
  final String? bankAccount;
  final double totalEarnings;
  final int totalTripsCompleted;
  final int totalPassengersServed;

  UserModel({
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
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.carModel,
    this.licensePlate,
    this.carColor,
    this.licenseNumber,
    this.insuranceNumber,
    this.licenseExpiryDate,
    this.insuranceExpiryDate,
    this.bankAccount,
    this.totalEarnings = 0.0,
    this.totalTripsCompleted = 0,
    this.totalPassengersServed = 0,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => firstName;
  String get initials => (firstName.isNotEmpty ? firstName[0] : '') + (lastName.isNotEmpty ? lastName[0] : '');
  String get phone => phoneNumber;

  // Mock stats for UI
  double get co2Saved => totalTripsCompleted * 2.5; // Example calculation
  int get tripsCount => totalTripsCompleted;

  bool get isDriveVerified =>
      isPhoneVerified && isEmailVerified &&
          licenseExpiryDate != null &&
          insuranceExpiryDate != null;

  Map<String, dynamic> toMap() => {
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
    'isPhoneVerified': isPhoneVerified,
    'isEmailVerified': isEmailVerified,
    'carModel': carModel,
    'licensePlate': licensePlate,
    'carColor': carColor,
    'licenseNumber': licenseNumber,
    'insuranceNumber': insuranceNumber,
    'licenseExpiryDate': licenseExpiryDate != null ? Timestamp.fromDate(licenseExpiryDate!) : null,
    'insuranceExpiryDate': insuranceExpiryDate != null ? Timestamp.fromDate(insuranceExpiryDate!) : null,
    'bankAccount': bankAccount,
    'totalEarnings': totalEarnings,
    'totalTripsCompleted': totalTripsCompleted,
    'totalPassengersServed': totalPassengersServed,
  };

  factory UserModel.fromMap(Map<String, dynamic> map, [String? docId]) => UserModel(
    id: docId ?? map['id'] ?? '',
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
    isPhoneVerified: map['isPhoneVerified'] ?? false,
    isEmailVerified: map['isEmailVerified'] ?? false,
    carModel: map['carModel'],
    licensePlate: map['licensePlate'],
    carColor: map['carColor'],
    licenseNumber: map['licenseNumber'],
    insuranceNumber: map['insuranceNumber'],
    licenseExpiryDate: (map['licenseExpiryDate'] as Timestamp?)?.toDate(),
    insuranceExpiryDate: (map['insuranceExpiryDate'] as Timestamp?)?.toDate(),
    bankAccount: map['bankAccount'],
    totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
    totalTripsCompleted: map['totalTripsCompleted'] ?? 0,
    totalPassengersServed: map['totalPassengersServed'] ?? 0,
  );

  UserModel copyWith({
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
    bool? isPhoneVerified,
    bool? isEmailVerified,
    String? carModel,
    String? licensePlate,
    String? carColor,
    String? licenseNumber,
    String? insuranceNumber,
    DateTime? licenseExpiryDate,
    DateTime? insuranceExpiryDate,
    String? bankAccount,
    double? totalEarnings,
    int? totalTripsCompleted,
    int? totalPassengersServed,
  }) => UserModel(
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
    isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    carModel: carModel ?? this.carModel,
    licensePlate: licensePlate ?? this.licensePlate,
    carColor: carColor ?? this.carColor,
    licenseNumber: licenseNumber ?? this.licenseNumber,
    insuranceNumber: insuranceNumber ?? this.insuranceNumber,
    licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
    insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
    bankAccount: bankAccount ?? this.bankAccount,
    totalEarnings: totalEarnings ?? this.totalEarnings,
    totalTripsCompleted: totalTripsCompleted ?? this.totalTripsCompleted,
    totalPassengersServed: totalPassengersServed ?? this.totalPassengersServed,
  );
}

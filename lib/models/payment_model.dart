import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String userId;
  final String tripId;
  final int amount;
  final String method;
  final String phoneNumber;
  final String status; // 'pending', 'completed', 'failed'
  final String? transactionId;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.amount,
    required this.method,
    required this.phoneNumber,
    this.status = 'pending',
    this.transactionId,
    required this.createdAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      userId: data['userId'] ?? '',
      tripId: data['tripId'] ?? '',
      amount: data['amount'] ?? 0,
      method: data['method'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      status: data['status'] ?? 'pending',
      transactionId: data['transactionId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tripId': tripId,
      'amount': amount,
      'method': method,
      'phoneNumber': phoneNumber,
      'status': status,
      'transactionId': transactionId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

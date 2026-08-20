import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createPayment(PaymentModel payment) async {
    final docRef = _db.collection('payments').doc();
    await docRef.set(payment.toMap());
    return docRef.id;
  }

  Future<void> updatePaymentStatus(String paymentId, String status, {String? transactionId}) async {
    final data = {'status': status};
    if (transactionId != null) data['transactionId'] = transactionId;
    await _db.collection('payments').doc(paymentId).update(data);
  }

  Stream<List<PaymentModel>> getUserPayments(String userId) {
    return _db
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

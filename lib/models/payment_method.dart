import 'package:flutter/material.dart';

enum PaymentMethodType {
  orangeMoney,
  mtnMoney,
  moovMoney,
  card,
  cash,
}

extension PaymentMethodTypeX on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.orangeMoney:
        return 'Orange Money';
      case PaymentMethodType.mtnMoney:
        return 'MTN Money';
      case PaymentMethodType.moovMoney:
        return 'Moov Money';
      case PaymentMethodType.card:
        return 'Carte bancaire';
      case PaymentMethodType.cash:
        return 'Espèces';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethodType.orangeMoney:
        return 'Paiement rapide via Orange Money';
      case PaymentMethodType.mtnMoney:
        return 'Paiement rapide via MTN MoMo';
      case PaymentMethodType.moovMoney:
        return 'Paiement rapide via Moov Money';
      case PaymentMethodType.card:
        return 'Paiement sécurisé par carte';
      case PaymentMethodType.cash:
        return 'Payer au conducteur';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.orangeMoney:
        return Icons.phone_iphone;
      case PaymentMethodType.mtnMoney:
        return Icons.smartphone;
      case PaymentMethodType.moovMoney:
        return Icons.mobile_friendly;
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.cash:
        return Icons.payments_outlined;
    }
  }

  bool get requiresPhone {
    switch (this) {
      case PaymentMethodType.orangeMoney:
      case PaymentMethodType.mtnMoney:
      case PaymentMethodType.moovMoney:
        return true;
      case PaymentMethodType.card:
      case PaymentMethodType.cash:
        return false;
    }
  }
}

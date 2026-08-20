import 'package:flutter/foundation.dart';

import '../models/payment_method.dart';
import '../models/payment_model.dart';
import '../services/payment_gateway_service.dart';
import '../services/payment_service.dart';

/// Provider pour gérer l'état des paiements dans l'application
class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentGatewayService? gatewayService})
      : _gatewayService = gatewayService ?? PaymentGatewayService();

  final PaymentGatewayService _gatewayService;
  final PaymentService _paymentService = PaymentService();

  // État du formulaire
  PaymentMethodType _selectedMethod = PaymentMethodType.orangeMoney;
  String _phone = '';
  double _amount = 1500;
  bool _isProcessing = false;
  String? _lastMessage;
  String? _lastTransactionId;
  bool? _lastPaymentSuccess;
  bool _isPending = false;

  // Getters
  PaymentMethodType get selectedMethod => _selectedMethod;
  String get phone => _phone;
  double get amount => _amount;
  bool get isProcessing => _isProcessing;
  String? get lastMessage => _lastMessage;
  String? get lastTransactionId => _lastTransactionId;
  bool? get lastPaymentSuccess => _lastPaymentSuccess;
  bool get isPending => _isPending;

  // Sélecteur de méthode de paiement
  void selectPaymentMethod(PaymentMethodType method) {
    _selectedMethod = method;
    _phone = '';
    _lastMessage = null;
    notifyListeners();
  }

  // Mise à jour du numéro de téléphone
  void setPhone(String value) {
    _phone = value;
    _lastMessage = null;
    notifyListeners();
  }

  // Mise à jour du montant
  void setAmount(double value) {
    _amount = value > 0 ? value : 1500;
    notifyListeners();
  }

  /// Valide les données du formulaire
  String? validateForm() {
    if (_selectedMethod.requiresPhone) {
      final cleanPhone = _phone.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.isEmpty) {
        return 'Veuillez entrer un numéro de téléphone.';
      }
      if (cleanPhone.length < 8) {
        return 'Le numéro de téléphone doit contenir au moins 8 chiffres.';
      }
    }

    if (_amount <= 0) {
      return 'Le montant doit être supérieur à zéro.';
    }

    return null;
  }

  /// Traite un paiement avec l'opérateur sélectionné
  Future<bool> processPayment({
    required String userId,
    required String tripId,
    required String tripDescription,
  }) async {
    // Valider le formulaire
    final validationError = validateForm();
    if (validationError != null) {
      _lastMessage = validationError;
      _lastPaymentSuccess = false;
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _isPending = false;
    _lastMessage = null;
    _lastTransactionId = null;
    _lastPaymentSuccess = null;
    notifyListeners();

    try {
      final reference = 'TRIP-${DateTime.now().millisecondsSinceEpoch}';
      PaymentGatewayResult result;

      // Appeler la passerelle de paiement appropriée
      switch (_selectedMethod) {
        case PaymentMethodType.orangeMoney:
          result = await _gatewayService.processOrangeMoneyPayment(
            phoneNumber: _phone,
            amount: _amount,
            reference: reference,
            description: tripDescription,
          );
          break;
        case PaymentMethodType.mtnMoney:
          result = await _gatewayService.processMTNMoneyPayment(
            phoneNumber: _phone,
            amount: _amount,
            reference: reference,
            description: tripDescription,
          );
          break;
        case PaymentMethodType.moovMoney:
          result = await _gatewayService.processMoovMoneyPayment(
            phoneNumber: _phone,
            amount: _amount,
            reference: reference,
            description: tripDescription,
          );
          break;
        case PaymentMethodType.card:
          _lastMessage = 'Les paiements par carte ne sont pas encore disponibles.';
          _lastPaymentSuccess = false;
          _isProcessing = false;
          notifyListeners();
          return false;
        case PaymentMethodType.cash:
          // Le paiement en espèces ne nécessite pas de validation
          _lastMessage = 'Paiement en espèces confirmé. Veuillez payer le conducteur.';
          _lastPaymentSuccess = true;
          _lastTransactionId = 'CASH-${DateTime.now().millisecondsSinceEpoch}';
          
          await _recordPayment(userId, tripId, 'completed');
          
          _isProcessing = false;
          notifyListeners();
          return true;
      }

      // Gérer le résultat
      _lastMessage = result.message;
      _lastTransactionId = result.transactionId;
      _lastPaymentSuccess = result.success;
      _isPending = result.isPending;

      if (result.success || result.isPending) {
        await _recordPayment(
          userId, 
          tripId, 
          result.success ? 'completed' : 'pending',
          transactionId: result.transactionId
        );
      }

      _isProcessing = false;
      notifyListeners();
      return result.success;
    } catch (e) {
      _lastMessage = 'Erreur lors du paiement: ${e.toString()}';
      _lastPaymentSuccess = false;
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _recordPayment(String userId, String tripId, String status, {String? transactionId}) async {
    final payment = PaymentModel(
      id: '',
      userId: userId,
      tripId: tripId,
      amount: _amount.toInt(),
      method: _selectedMethod.label,
      phoneNumber: _phone,
      status: status,
      transactionId: transactionId,
      createdAt: DateTime.now(),
    );
    await _paymentService.createPayment(payment);
  }

  /// Réinitialise l'état du paiement
  void reset() {
    _selectedMethod = PaymentMethodType.orangeMoney;
    _phone = '';
    _amount = 1500;
    _isProcessing = false;
    _lastMessage = null;
    _lastTransactionId = null;
    _lastPaymentSuccess = null;
    _isPending = false;
    notifyListeners();
  }
}

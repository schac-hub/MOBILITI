import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Configuration des intégrations de paiement pour les opérateurs mobiles
class PaymentGatewayConfig {
  static const String baseUrl = 'https://api.mobiliti.app';
  
  // Orange Money (Côte d'Ivoire, Sénégal, etc.)
  static const String orangeMoneyEndpoint = '$baseUrl/payment/orange-money';
  static const String orangeMoneyApiKey = 'orange_key_prod_xxxxx';
  
  // MTN Mobile Money
  static const String mtnMoneyEndpoint = '$baseUrl/payment/mtn-money';
  static const String mtnMoneyApiKey = 'mtn_key_prod_xxxxx';
  
  // Moov Money
  static const String moovMoneyEndpoint = '$baseUrl/payment/moov-money';
  static const String moovMoneyApiKey = 'moov_key_prod_xxxxx';
  
  // Timeout pour chaque requête
  static const Duration requestTimeout = Duration(seconds: 30);
}

/// Gère les intégrations réelles avec les passerelles de paiement
class PaymentGatewayService {
  final http.Client? httpClient;

  PaymentGatewayService({this.httpClient});

  /// Traite un paiement via Orange Money
  Future<PaymentGatewayResult> processOrangeMoneyPayment({
    required String phoneNumber,
    required double amount,
    required String reference,
    required String description,
  }) async {
    try {
      final sanitizedPhone = _sanitizePhoneNumber(phoneNumber);
      
      // Validation du numéro Orange Money (exemple pour Côte d'Ivoire: 9XX XXX XXX)
      if (!_isValidOrangeMoneyNumber(sanitizedPhone)) {
        return PaymentGatewayResult(
          success: false,
          message: 'Le numéro Orange Money saisi est invalide.',
          transactionId: null,
        );
      }

      if (!kDebugMode) {
        // Mode production - appel à la vraie API
        return await _callOrangeMoneyAPI(
          phoneNumber: sanitizedPhone,
          amount: amount,
          reference: reference,
          description: description,
        );
      } else {
        // Mode debug - simulation
        return _simulatePaymentResponse(
          operator: 'Orange Money',
          phoneNumber: sanitizedPhone,
          amount: amount,
          reference: reference,
        );
      }
    } catch (e) {
      return PaymentGatewayResult(
        success: false,
        message: 'Erreur de traitement: ${e.toString()}',
        transactionId: null,
      );
    }
  }

  /// Traite un paiement via MTN Mobile Money
  Future<PaymentGatewayResult> processMTNMoneyPayment({
    required String phoneNumber,
    required double amount,
    required String reference,
    required String description,
  }) async {
    try {
      final sanitizedPhone = _sanitizePhoneNumber(phoneNumber);
      
      if (!_isValidMTNMoneyNumber(sanitizedPhone)) {
        return PaymentGatewayResult(
          success: false,
          message: 'Le numéro MTN Money saisi est invalide.',
          transactionId: null,
        );
      }

      if (!kDebugMode) {
        return await _callMTNMoneyAPI(
          phoneNumber: sanitizedPhone,
          amount: amount,
          reference: reference,
          description: description,
        );
      } else {
        return _simulatePaymentResponse(
          operator: 'MTN Money',
          phoneNumber: sanitizedPhone,
          amount: amount,
          reference: reference,
        );
      }
    } catch (e) {
      return PaymentGatewayResult(
        success: false,
        message: 'Erreur de traitement: ${e.toString()}',
        transactionId: null,
      );
    }
  }

  /// Traite un paiement via Moov Money
  Future<PaymentGatewayResult> processMoovMoneyPayment({
    required String phoneNumber,
    required double amount,
    required String reference,
    required String description,
  }) async {
    try {
      final sanitizedPhone = _sanitizePhoneNumber(phoneNumber);
      
      if (!_isValidMoovMoneyNumber(sanitizedPhone)) {
        return PaymentGatewayResult(
          success: false,
          message: 'Le numéro Moov Money saisi est invalide.',
          transactionId: null,
        );
      }

      if (!kDebugMode) {
        return await _callMoovMoneyAPI(
          phoneNumber: sanitizedPhone,
          amount: amount,
          reference: reference,
          description: description,
        );
      } else {
        return _simulatePaymentResponse(
          operator: 'Moov Money',
          phoneNumber: sanitizedPhone,
          amount: amount,
          reference: reference,
        );
      }
    } catch (e) {
      return PaymentGatewayResult(
        success: false,
        message: 'Erreur de traitement: ${e.toString()}',
        transactionId: null,
      );
    }
  }

  /// Appel API pour Orange Money (intégration réelle)
  Future<PaymentGatewayResult> _callOrangeMoneyAPI({
    required String phoneNumber,
    required double amount,
    required String reference,
    required String description,
  }) async {
    try {
      final client = httpClient ?? http.Client();
      
      final response = await client
          .post(
            Uri.parse(PaymentGatewayConfig.orangeMoneyEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${PaymentGatewayConfig.orangeMoneyApiKey}',
              'X-API-Version': '2.0',
            },
            body: jsonEncode({
              'phone_number': phoneNumber,
              'amount': amount.toStringAsFixed(2),
              'currency': 'XOF',
              'reference': reference,
              'description': description,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(PaymentGatewayConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentGatewayResult(
          success: true,
          message: 'Paiement Orange Money accepté.',
          transactionId: data['transaction_id'] ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          rawResponse: data,
        );
      } else if (response.statusCode == 202) {
        // Paiement en attente d'acceptation par l'utilisateur
        final data = jsonDecode(response.body);
        return PaymentGatewayResult(
          success: false,
          message: 'Veuillez confirmer le paiement sur votre téléphone.',
          transactionId: data['transaction_id'],
          isPending: true,
        );
      } else {
        return PaymentGatewayResult(
          success: false,
          message: 'Paiement refusé. Veuillez vérifier vos données.',
          transactionId: null,
        );
      }
    } catch (e) {
      return PaymentGatewayResult(
        success: false,
        message: 'Connexion échouée: ${e.toString()}',
        transactionId: null,
      );
    }
  }

  /// Appel API pour MTN Mobile Money
  Future<PaymentGatewayResult> _callMTNMoneyAPI({
    required String phoneNumber,
    required double amount,
    required String reference,
    required String description,
  }) async {
    try {
      final client = httpClient ?? http.Client();
      
      final response = await client
          .post(
            Uri.parse(PaymentGatewayConfig.mtnMoneyEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${PaymentGatewayConfig.mtnMoneyApiKey}',
              'X-API-Version': '2.0',
            },
            body: jsonEncode({
              'phone_number': phoneNumber,
              'amount': amount.toStringAsFixed(2),
              'currency': 'XOF',
              'reference': reference,
              'description': description,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(PaymentGatewayConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentGatewayResult(
          success: true,
          message: 'Paiement MTN Money accepté.',
          transactionId: data['transaction_id'] ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          rawResponse: data,
        );
      } else if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        return PaymentGatewayResult(
          success: false,
          message: 'Veuillez confirmer le paiement sur votre téléphone.',
          transactionId: data['transaction_id'],
          isPending: true,
        );
      } else {
        return PaymentGatewayResult(
          success: false,
          message: 'Paiement refusé. Veuillez vérifier vos données.',
          transactionId: null,
        );
      }
    } catch (e) {
      return PaymentGatewayResult(
        success: false,
        message: 'Connexion échouée: ${e.toString()}',
        transactionId: null,
      );
    }
  }

  /// Appel API pour Moov Money
  Future<PaymentGatewayResult> _callMoovMoneyAPI({
    required String phoneNumber,
    required double amount,
    required String reference,
    required String description,
  }) async {
    try {
      final client = httpClient ?? http.Client();
      
      final response = await client
          .post(
            Uri.parse(PaymentGatewayConfig.moovMoneyEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${PaymentGatewayConfig.moovMoneyApiKey}',
              'X-API-Version': '2.0',
            },
            body: jsonEncode({
              'phone_number': phoneNumber,
              'amount': amount.toStringAsFixed(2),
              'currency': 'XOF',
              'reference': reference,
              'description': description,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(PaymentGatewayConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentGatewayResult(
          success: true,
          message: 'Paiement Moov Money accepté.',
          transactionId: data['transaction_id'] ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          rawResponse: data,
        );
      } else if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        return PaymentGatewayResult(
          success: false,
          message: 'Veuillez confirmer le paiement sur votre téléphone.',
          transactionId: data['transaction_id'],
          isPending: true,
        );
      } else {
        return PaymentGatewayResult(
          success: false,
          message: 'Paiement refusé. Veuillez vérifier vos données.',
          transactionId: null,
        );
      }
    } catch (e) {
      return PaymentGatewayResult(
        success: false,
        message: 'Connexion échouée: ${e.toString()}',
        transactionId: null,
      );
    }
  }

  /// Simulation de réponse en mode debug
  PaymentGatewayResult _simulatePaymentResponse({
    required String operator,
    required String phoneNumber,
    required double amount,
    required String reference,
  }) {
    // Simuler un délai réseau
    Future.delayed(const Duration(seconds: 2));
    
    final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    return PaymentGatewayResult(
      success: true,
      message: 'Paiement $operator simulé avec succès (Mode Debug).',
      transactionId: transactionId,
      rawResponse: {
        'operator': operator,
        'phone_number': phoneNumber,
        'amount': amount,
        'reference': reference,
        'transaction_id': transactionId,
        'status': 'completed',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Sanitize phone number (remove spaces, dashes, etc.)
  String _sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Valide un numéro Orange Money
  bool _isValidOrangeMoneyNumber(String phone) {
    // Orange Money: généralement des numéros de 8 à 12 chiffres
    // Exemples: 9XXXXXXXX (Côte d'Ivoire), 7XXXXXXXX (Sénégal)
    return phone.length >= 8 && phone.length <= 12;
  }

  /// Valide un numéro MTN Mobile Money
  bool _isValidMTNMoneyNumber(String phone) {
    // MTN Money: généralement des numéros de 8 à 12 chiffres
    return phone.length >= 8 && phone.length <= 12;
  }

  /// Valide un numéro Moov Money
  bool _isValidMoovMoneyNumber(String phone) {
    // Moov Money: généralement des numéros de 8 à 12 chiffres
    return phone.length >= 8 && phone.length <= 12;
  }
}

/// Résultat d'une transaction de paiement
class PaymentGatewayResult {
  final bool success;
  final String message;
  final String? transactionId;
  final Map<String, dynamic>? rawResponse;
  final bool isPending;

  PaymentGatewayResult({
    required this.success,
    required this.message,
    required this.transactionId,
    this.rawResponse,
    this.isPending = false,
  });
}

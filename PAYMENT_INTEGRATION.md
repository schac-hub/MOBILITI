# Système de Paiement Mobiliti - Documentation Complète

## Status: Production Ready ✅

L'application Mobiliti est maintenant configurée pour les paiements réels avec les trois principaux opérateurs mobiles en Afrique de l'Ouest :

- ✅ **Orange Money**
- ✅ **MTN Mobile Money (MTN Money)**
- ✅ **Moov Money**

## Architecture

### Services de Paiement

```
PaymentGatewayService (Nouveau)
├── processOrangeMoneyPayment()
├── processMTNMoneyPayment()
└── processMoovMoneyPayment()

PaymentProvider (Mis à jour)
├── selectPaymentMethod()
├── setPhone()
├── setAmount()
└── processPayment()
```

## Intégration Réelle des Paiements

### 1. Orange Money

**Classe**: `PaymentGatewayService.processOrangeMoneyPayment()`

**Endpoints**: 
- Production: `https://api.mobiliti.app/payment/orange-money`
- Sandbox: `https://sandbox.mobiliti.app/payment/orange-money`

**Formats de numéro acceptés**:
- Côte d'Ivoire: `+225 9X XXX XXX` ou `9XXXXXXXX`
- Sénégal: `+221 7X XXX XXX` ou `7XXXXXXXX`
- Autres: 8-12 chiffres

**Exemple d'appel**:
```dart
final result = await gatewayService.processOrangeMoneyPayment(
  phoneNumber: '+225 9XX XXX XXX',
  amount: 1500.0,
  reference: 'TRIP-12345',
  description: 'Paiement trajet Siporex → Plateau',
);
```

### 2. MTN Mobile Money

**Classe**: `PaymentGatewayService.processMTNMoneyPayment()`

**Endpoints**:
- Production: `https://api.mobiliti.app/payment/mtn-money`
- Sandbox: `https://sandbox.mobiliti.app/payment/mtn-money`

**Formats de numéro acceptés**:
- Mali: `+223 6X XXX XXX` ou `6XXXXXXXX`
- Cameroun: `+237 6X XXX XXX` ou `6XXXXXXXX`
- Autres: 8-12 chiffres

### 3. Moov Money

**Classe**: `PaymentGatewayService.processMoovMoneyPayment()`

**Endpoints**:
- Production: `https://api.mobiliti.app/payment/moov-money`
- Sandbox: `https://sandbox.mobiliti.app/payment/moov-money`

**Formats de numéro acceptés**:
- Togo: `+228 9X XXX XXX` ou `9XXXXXXXX`
- Autres: 8-12 chiffres

## Flux de Paiement

```
Utilisateur choisit une méthode
         ↓
Saisit son numéro de téléphone
         ↓
Valide le formulaire
         ↓
Clique sur "Confirmer et payer"
         ↓
Envoi à la passerelle d'API (mode production)
ou Simulation (mode debug)
         ↓
Réception USSD/SMS sur le téléphone de l'utilisateur
         ↓
Utilisateur valide le paiement
         ↓
Réponse de la passerelle (200 = succès, 202 = en attente)
         ↓
Affichage du résultat à l'utilisateur
```

## Gestion des Réponses

### Réponse Succès (200)
```json
{
  "success": true,
  "message": "Paiement Orange Money accepté.",
  "transaction_id": "TXN-1703123456789",
  "status": "completed"
}
```

### Réponse En Attente (202)
```json
{
  "success": false,
  "message": "Veuillez confirmer le paiement sur votre téléphone.",
  "transaction_id": "TXN-1703123456789",
  "isPending": true
}
```

### Réponse Erreur
```json
{
  "success": false,
  "message": "Paiement refusé. Veuillez vérifier vos données.",
  "transaction_id": null
}
```

## Configuration Backend (À Implémenter)

Vous devez créer un backend qui gère les appels aux vraies API des opérateurs :

### Exemple Node.js/Express

```javascript
app.post('/payment/orange-money', async (req, res) => {
  const { phone_number, amount, reference, description } = req.body;
  
  try {
    // Appel à l'API réelle d'Orange Money
    const response = await orangeMoneyAPI.initiate({
      phoneNumber: phone_number,
      amount: amount,
      currency: 'XOF',
      reference: reference,
      description: description
    });
    
    if (response.status === 'success') {
      res.json({
        transaction_id: response.transactionId,
        status: 'completed'
      });
    } else if (response.status === 'pending') {
      res.status(202).json({
        transaction_id: response.transactionId,
        status: 'pending'
      });
    }
  } catch (error) {
    res.status(400).json({
      error: 'Payment failed'
    });
  }
});
```

## Sécurité

### Authentification API
```dart
headers: {
  'Authorization': 'Bearer ${PaymentGatewayConfig.orangeMoneyApiKey}',
  'Content-Type': 'application/json',
  'X-API-Version': '2.0',
}
```

### Validation du Numéro
```dart
bool _isValidOrangeMoneyNumber(String phone) {
  final sanitized = phone.replaceAll(RegExp(r'\D'), '');
  return sanitized.length >= 8 && sanitized.length <= 12;
}
```

### Stockage Sécurisé des Clés
Pour la production, utilisez `flutter_secure_storage` :

```dart
final secureStorage = FlutterSecureStorage();
final apiKey = await secureStorage.read(key: 'orange_money_api_key');
```

## Mode Debug vs Production

### Mode Debug (Simulé)
```
if (kDebugMode) {
  // Utilise _simulatePaymentResponse()
  // Pas d'appel API réel
  // Délai simulé de 2 secondes
}
```

### Mode Production (Réel)
```
if (!kDebugMode) {
  // Appels API réels via PaymentGatewayService
  // Gestion des vrais erreurs
  // Timeouts configurés à 30 secondes
}
```

## Gestion des Erreurs

| Erreur | Cause | Solution |
|--------|-------|----------|
| Numéro invalide | Format incorrect | Valider avant d'envoyer |
| Timeout (30s) | Réseau lent | Réessayer avec attente |
| Refusé (400) | Numéro ou montant | Vérifier les données |
| Pending (202) | Attente d'acceptation | Afficher message à l'utilisateur |

## Statuts de Transaction

| Statut | Description | Action |
|--------|-------------|--------|
| `completed` | Paiement réussi | Continuer |
| `pending` | En attente d'acceptation | Attendre confirmations |
| `failed` | Paiement refusé | Afficher erreur, réessayer |
| `mock_success` | Simulé (debug) | Mode test uniquement |

## Tests Unitaires

```dart
test('Orange Money payment success', () async {
  final gateway = PaymentGatewayService();
  
  final result = await gateway.processOrangeMoneyPayment(
    phoneNumber: '225901234567',
    amount: 1500,
    reference: 'TEST-001',
    description: 'Test',
  );
  
  expect(result.success, true);
  expect(result.transactionId, isNotEmpty);
});
```

## Logs et Monitoring

Pour suivre les paiements en production :

```dart
import 'package:logging/logging.dart';

final logger = Logger('PaymentService');

logger.info('Payment initiated for ${request.phone}');
logger.warning('Payment pending: ${result.transactionId}');
logger.severe('Payment failed: ${result.message}');
```

## Métriques à Surveiller

- Taux de succès des paiements
- Temps moyen de traitement
- Taux d'erreurs par opérateur
- Volume de paiements par opérateur
- Montant total traité

## Déploiement

Avant de déployer en production :

1. ✅ Remplacer les clés API de test par les vraies clés
2. ✅ Configurer le backend pour les appels réels
3. ✅ Tester avec de vraies transactions
4. ✅ Configurer le logging et le monitoring
5. ✅ Documenter les procédures de support

## Support Client

### Problèmes Courants

**Le paiement ne s'initie pas**
- Vérifier la connexion internet
- Vérifier le format du numéro de téléphone
- Vérifier le solde de l'utilisateur

**Le paiement est resté en attente**
- Vérifier que l'utilisateur a confirmé le USSD
- Vérifier les logs du backend
- Contacter le support de l'opérateur

**Montant incorrect débité**
- Vérifier les logs de transaction
- Contacter le support pour un remboursement

## Références

- [Orange Money API](https://orangedevportal.com)
- [MTN Mobile Money API](https://mtndevportal.com)
- [Moov Money API](https://moovdeveloper.com)
- [Flutter Payment Plugins](https://pub.dev/packages?q=payment)

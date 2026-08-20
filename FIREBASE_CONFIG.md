# Configuration Firebase - Mobiliti

## Status: Production Ready ✅

Cette application est configurée pour fonctionner avec Firebase sur les plateformes :
- ✅ Web
- ✅ Android
- ✅ iOS
- ✅ macOS

## Configuration Actuelle

Le projet utilise le projet Firebase : `mobiliti-b`

### API Keys (Production)

Les clés API sont configurées pour chaque plateforme :

- **Web**: `AIzaSyAaiLyPhBbT1y4A7NSRTUsBRCcDridK4dI`
- **Android**: `AIzaSyAZLTjiW_dFBos8sxWVp7bqEp3HBBrr2ao`
- **iOS**: `AIzaSyASFLtd6zVPEqMfAVfAy7Gd8qPVZ5mWp7E`
- **macOS**: `AIzaSyASFLtd6zVPEqMfAVfAy7Gd8qPVZ5mWp7E`

### Services Activés

- ✅ Authentication (Email, Google, Facebook)
- ✅ Firestore Database
- ✅ Cloud Storage
- ✅ Cloud Messaging
- ✅ Analytics

## Mise à Jour des Clés

Pour mettre à jour les clés Firebase :

1. Allez sur la [Console Firebase](https://console.firebase.google.com)
2. Sélectionnez le projet `mobiliti-b`
3. Pour chaque plateforme (Android, iOS, Web) :
   - Allez dans Paramètres du projet
   - Copiez les clés API correspondantes
   - Mettez à jour les fichiers :
     - `lib/firebase_options.dart`
     - `ios/Runner/GoogleService-Info.plist`
     - `android/app/google-services.json`

## Configuration Locale (Dev/Debug)

Pour le développement local, créez un fichier `.env` à la racine du projet :

```env
FIREBASE_API_KEY=votre_cle_de_debug
FIREBASE_PROJECT_ID=mobiliti-b
```

## Règles Firestore (Sécurité)

Les règles Firestore sont définies dans la console Firebase. Voici un exemple de règles sécurisées :

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, update, delete: if request.auth.uid == userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
    
    match /trips/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        (request.auth.uid == resource.data.driverId || 
         request.auth.uid == resource.data.passengerId);
    }
    
    match /payments/{document=**} {
      allow read, create, update: if request.auth != null;
      allow delete: if false;
    }
  }
}
```

## Tests

Pour tester l'authentification Firebase en mode debug :

```dart
// Dans le fichier PaymentProvider ou ailleurs
if (kDebugMode) {
  // Mode debug - utilise les clés de test
  print('Utilisation des clés de test Firebase');
}
```

## Déploiement

Avant de déployer en production :

1. ✅ Vérifiez que les clés API sont correctes
2. ✅ Testez sur tous les appareils et émulateurs
3. ✅ Vérifiez les règles Firestore pour la sécurité
4. ✅ Configurez les règles Cloud Storage
5. ✅ Testez tous les flux d'authentification

## Support

Pour toute question sur la configuration Firebase :
- Consultez la [documentation officielle](https://firebase.flutter.dev/)
- Vérifiez les logs Firebase dans la console

class AppConstants {
  // API
  static const String baseUrl = 'https://api.mobiliti.app';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Validation
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[0-9]{10,13}$';
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String tripsCollection = 'trips';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';
  static const String messagesCollection = 'messages';
  static const String conversationsCollection = 'conversations';
  static const String paymentsCollection = 'payments';

  // Storage paths
  static const String profilePicturesPath = 'profile_pictures';
  static const String documentsPicPath = 'documents';

  // UI
  static const int defaultAnimationDuration = 300;
  static const double defaultElevation = 4.0;

  // Payment
  static const double minTripPrice = 1.0;
  static const double maxTripPrice = 500.0;
  static const double platformFeePercentage = 0.15;

  // Trip defaults
  static const int defaultAvailableSeats = 4;
  static const int minPassengers = 1;
  static const int maxPassengers = 4;

  // Geolocation
  static const double defaultMapZoom = 15.0;
  static const double tripAccuracyThreshold = 100.0; // meters

  // Time limits
  static const Duration tripCancellationDeadline = Duration(minutes: 30);
  static const Duration autoAcceptTimeout = Duration(minutes: 2);

  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}

class RegexPatterns {
  static final emailRegex = RegExp(AppConstants.emailPattern);
  static final phoneRegex = RegExp(AppConstants.phonePattern);
  static final passwordRegex = RegExp(AppConstants.passwordPattern);
}

class ErrorMessages {
  static const String invalidEmail = 'Veuillez entrer un email valide';
  static const String invalidPhone = 'Veuillez entrer un numéro valide';
  static const String weakPassword = 'Le mot de passe doit contenir au moins 8 caractères, une majuscule et un chiffre';
  static const String passwordMismatch = 'Les mots de passe ne correspondent pas';
  static const String fieldRequired = 'Ce champ est obligatoire';
  static const String networkError = 'Erreur de connexion. Vérifiez votre internet';
  static const String serverError = 'Erreur serveur. Veuillez réessayer';
  static const String unknownError = 'Une erreur est survenue';
  static const String termsNotAccepted = 'Vous devez accepter les conditions';
}

class SuccessMessages {
  static const String registrationSuccessful = 'Inscription réussie!';
  static const String loginSuccessful = 'Connexion réussie!';
  static const String tripBooked = 'Voyage réservé avec succès!';
  static const String paymentSuccessful = 'Paiement effectué!';
}
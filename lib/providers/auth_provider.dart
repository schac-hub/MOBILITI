import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final _firebaseService = FirebaseService();
  final _googleSignIn = GoogleSignIn();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  // Getters
  UserModel? get user => _user;
  UserModel? get userProfile => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isDriver => _user?.userType == 'driver' || _user?.userType == 'both';
  bool get isPassenger => _user?.userType == 'passenger' || _user?.userType == 'both';

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      await _loadUser(fbUser.uid);
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String userType = 'passenger',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate inputs
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Email invalide');
      }
      if (phoneNumber.isEmpty || phoneNumber.length < 10) {
        throw Exception('Numéro de téléphone invalide');
      }
      if (password.isEmpty || password.length < 6) {
        throw Exception('Le mot de passe doit contenir au moins 6 caractères');
      }

      // Firebase registration
      final fbUser = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user model
      final now = DateTime.now();
      final newUser = UserModel(
        id: fbUser.user!.uid,
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        userType: userType,
        createdAt: now,
        isEmailVerified: false,
        isPhoneVerified: false,
      );

      // Save to Firestore
      await _firebaseService.createUser(newUser);

      _user = newUser;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fbUser = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _loadUser(fbUser.user!.uid);
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Erreur de connexion';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fbUser = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      
      // Check if user exists in Firestore
      final existingUser = await _firebaseService.getUser(fbUser.user!.uid);
      
      if (existingUser == null) {
        // Create new user in Firestore
        final newUser = UserModel(
          id: fbUser.user!.uid,
          email: fbUser.user!.email ?? '',
          phoneNumber: fbUser.user!.phoneNumber ?? '',
          firstName: fbUser.user!.displayName?.split(' ').first ?? 'User',
          lastName: fbUser.user!.displayName?.split(' ').skip(1).join(' ') ?? '',
          profilePicture: fbUser.user!.photoURL,
          userType: 'passenger',
          createdAt: DateTime.now(),
          isEmailVerified: true,
          isPhoneVerified: false,
        );
        await _firebaseService.createUser(newUser);
        _user = newUser;
      } else {
        _user = existingUser;
      }

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadUser(String uid) async {
    try {
      _user = await _firebaseService.getUser(uid);
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<String?> getEmailByPhone(String phone) async {
    return await _firebaseService.getEmailByPhone(phone);
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await fb.FirebaseAuth.instance.signOut();
      _user = null;
      _isLoggedIn = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    try {
      if (_user == null) return false;

      _user = _user!.copyWith(
        firstName: firstName ?? _user!.firstName,
        lastName: lastName ?? _user!.lastName,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
        profilePicture: profilePicture ?? _user!.profilePicture,
      );

      await _firebaseService.updateUser(_user!);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> switchToDriver({
    required String carModel,
    required String licensePlate,
    required String carColor,
    required String licenseNumber,
    required String insuranceNumber,
  }) async {
    try {
      if (_user == null) return false;

      _user = _user!.copyWith(
        userType: 'both',
        carModel: carModel,
        licensePlate: licensePlate,
        carColor: carColor,
        licenseNumber: licenseNumber,
        insuranceNumber: insuranceNumber,
      );

      await _firebaseService.updateUser(_user!);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
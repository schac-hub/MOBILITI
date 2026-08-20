import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    String? photoUrl,
  }) async {
    final user = UserModel(
      id: uid,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phone,
      email: email,
      profilePicture: photoUrl,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(uid).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<String> uploadProfilePicture(String uid, File image) async {
    final ref = _storage.ref().child('user_photos').child('$uid.jpg');
    final uploadTask = await ref.putFile(image);
    final photoUrl = await uploadTask.ref.getDownloadURL();
    
    await updateUser(uid, {'photoUrl': photoUrl});
    return photoUrl;
  }
}

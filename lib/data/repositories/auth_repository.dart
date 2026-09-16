import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_defaults.dart';
import '../models/app_user.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser> login({
    required String name,
    required String password,
    required UserRole expectedRole,
  }) async {
    final email = EmailHelper.fromName(name);
    if (email == AppDefaults.gmailSuffix) {
      throw Exception('Please enter your login name.');
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('Login failed. Please try again.');
      }

      final user = await fetchUser(uid);
      if (user.role != expectedRole) {
        await _auth.signOut();
        throw Exception(
          expectedRole == UserRole.student
              ? 'This account is not a student login.'
              : 'This account is not a school login.',
        );
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapAuthError(error));
    }
  }

  Future<AppUser> fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('Profile not found for this account.');
    }
    return AppUser.fromDoc(doc);
  }

  Future<AppUser> updateStudentProfile({
    required String uid,
    required String studentName,
    required String parentName,
    required String parentRelation,
    required String senderName,
    required String senderRelation,
    required String contact,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'studentName': studentName.trim(),
      'parentName': parentName.trim(),
      'parentRelation': parentRelation.trim(),
      'senderName': senderName.trim(),
      'senderRelation': senderRelation.trim(),
      'contact': contact.trim(),
    }, SetOptions(merge: true));
    return fetchUser(uid);
  }

  Future<void> logout() => _auth.signOut();

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid name or password.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return error.message ?? 'Login failed. Please try again.';
    }
  }
}

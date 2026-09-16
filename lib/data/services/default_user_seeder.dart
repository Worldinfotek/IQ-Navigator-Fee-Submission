import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_defaults.dart';
import '../models/app_user.dart';

class DefaultUserSeeder {
  DefaultUserSeeder({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> seedIfNeeded() async {
    if (_auth.currentUser != null) return;

    await _ensureAccount(
      email: EmailHelper.fromName(AppDefaults.studentLoginName),
      password: AppDefaults.defaultPassword,
      profile: AppUser(
        id: '',
        email: EmailHelper.fromName(AppDefaults.studentLoginName),
        role: UserRole.student,
        studentName: AppDefaults.studentName,
        parentName: AppDefaults.parentName,
        parentRelation: AppDefaults.parentRelation,
        senderName: AppDefaults.senderName,
        senderRelation: AppDefaults.senderRelation,
        contact: AppDefaults.contact,
      ),
    );

    await _ensureAccount(
      email: EmailHelper.fromName(AppDefaults.schoolLoginName),
      password: AppDefaults.defaultPassword,
      profile: AppUser(
        id: '',
        email: EmailHelper.fromName(AppDefaults.schoolLoginName),
        role: UserRole.school,
        schoolName: AppDefaults.schoolName,
      ),
    );
  }

  Future<void> _ensureAccount({
    required String email,
    required String password,
    required AppUser profile,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          ...profile.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        try {
          final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          final uid = credential.user?.uid;
          if (uid != null) {
            final doc = await _firestore.collection('users').doc(uid).get();
            if (!doc.exists) {
              await _firestore.collection('users').doc(uid).set({
                ...profile.toMap(),
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
          await _auth.signOut();
        } on FirebaseAuthException {
          await _auth.signOut();
        }
        return;
      }
      await _auth.signOut();
    } catch (_) {
      await _auth.signOut();
    }
  }
}

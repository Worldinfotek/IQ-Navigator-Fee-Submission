import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/fee_voucher.dart';

class FeeRepository {
  FeeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<FeeVoucher>> watchVouchers({String? studentId}) {
    Query<Map<String, dynamic>> query = _firestore.collection('vouchers');
    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    return query.snapshots().map((snapshot) {
      final vouchers = snapshot.docs.map(FeeVoucher.fromDoc).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return vouchers;
    });
  }

  Future<void> createVoucher({
    required AppUser student,
    required String feeMonth,
    required double amount,
    required String details,
  }) async {
    await _firestore.collection('vouchers').add({
      'studentId': student.id,
      'studentName': student.studentName,
      'parentName': student.parentName,
      'senderName': student.senderName,
      'contact': student.contact,
      'feeMonth': feeMonth,
      'amount': amount,
      'details': details.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

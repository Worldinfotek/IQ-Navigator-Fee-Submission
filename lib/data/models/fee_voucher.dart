import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class FeeVoucher extends Equatable {
  const FeeVoucher({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.parentName,
    required this.senderName,
    required this.contact,
    required this.feeMonth,
    required this.amount,
    required this.details,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String parentName;
  final String senderName;
  final String contact;
  final String feeMonth;
  final double amount;
  final String details;
  final DateTime createdAt;

  String get formattedAmount {
    final format = NumberFormat.currency(
      locale: 'en',
      symbol: 'Rs ',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return format.format(amount);
  }

  String get formattedDate => DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

  factory FeeVoucher.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final created = data['createdAt'];
    return FeeVoucher(
      id: doc.id,
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      parentName: data['parentName'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      contact: data['contact'] as String? ?? '',
      feeMonth: data['feeMonth'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      details: data['details'] as String? ?? '',
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'parentName': parentName,
      'senderName': senderName,
      'contact': contact,
      'feeMonth': feeMonth,
      'amount': amount,
      'details': details,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        parentName,
        senderName,
        contact,
        feeMonth,
        amount,
        details,
        createdAt,
      ];
}

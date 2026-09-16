import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole { student, school }

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.studentName = '',
    this.parentName = '',
    this.parentRelation = '',
    this.senderName = '',
    this.senderRelation = '',
    this.contact = '',
    this.schoolName = '',
  });

  final String id;
  final String email;
  final UserRole role;
  final String studentName;
  final String parentName;
  final String parentRelation;
  final String senderName;
  final String senderRelation;
  final String contact;
  final String schoolName;

  bool get isStudent => role == UserRole.student;
  bool get hasCompleteProfile =>
      studentName.trim().isNotEmpty &&
      parentName.trim().isNotEmpty &&
      senderName.trim().isNotEmpty &&
      contact.trim().isNotEmpty;

  String get displayName =>
      isStudent ? studentName : (schoolName.isEmpty ? 'School Admin' : schoolName);

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      role: (data['role'] as String? ?? 'student') == 'school'
          ? UserRole.school
          : UserRole.student,
      studentName: data['studentName'] as String? ?? '',
      parentName: data['parentName'] as String? ?? '',
      parentRelation: data['parentRelation'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      senderRelation: data['senderRelation'] as String? ?? '',
      contact: data['contact'] as String? ?? '',
      schoolName: data['schoolName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.name,
      'studentName': studentName,
      'parentName': parentName,
      'parentRelation': parentRelation,
      'senderName': senderName,
      'senderRelation': senderRelation,
      'contact': contact,
      'schoolName': schoolName,
    };
  }

  AppUser copyWith({
    String? studentName,
    String? parentName,
    String? parentRelation,
    String? senderName,
    String? senderRelation,
    String? contact,
    String? schoolName,
  }) {
    return AppUser(
      id: id,
      email: email,
      role: role,
      studentName: studentName ?? this.studentName,
      parentName: parentName ?? this.parentName,
      parentRelation: parentRelation ?? this.parentRelation,
      senderName: senderName ?? this.senderName,
      senderRelation: senderRelation ?? this.senderRelation,
      contact: contact ?? this.contact,
      schoolName: schoolName ?? this.schoolName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        studentName,
        parentName,
        parentRelation,
        senderName,
        senderRelation,
        contact,
        schoolName,
      ];
}

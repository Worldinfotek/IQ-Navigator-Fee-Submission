import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late final TextEditingController _studentName;
  late final TextEditingController _parentName;
  late final TextEditingController _parentRelation;
  late final TextEditingController _senderName;
  late final TextEditingController _senderRelation;
  late final TextEditingController _contact;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _studentName = TextEditingController(text: widget.user.studentName);
    _parentName = TextEditingController(text: widget.user.parentName);
    _parentRelation = TextEditingController(text: widget.user.parentRelation);
    _senderName = TextEditingController(text: widget.user.senderName);
    _senderRelation = TextEditingController(text: widget.user.senderRelation);
    _contact = TextEditingController(text: widget.user.contact);
  }

  @override
  void dispose() {
    _studentName.dispose();
    _parentName.dispose();
    _parentRelation.dispose();
    _senderName.dispose();
    _senderRelation.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = await context.read<AuthRepository>().updateStudentProfile(
            uid: widget.user.id,
            studentName: _studentName.text,
            parentName: _parentName.text,
            parentRelation: _parentRelation.text,
            senderName: _senderName.text,
            senderRelation: _senderRelation.text,
            contact: _contact.text,
          );
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthProfileUpdated(updated));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Profile',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            Text(
              'This information is saved once and attached to every voucher.',
              style: TextStyle(fontSize: 14.5.sp, color: AppColors.muted),
            ),
            SizedBox(height: 2.h),
            _field('Student name', _studentName),
            _field('Parent name', _parentName),
            _field('Parent relation', _parentRelation),
            _field('Sender name', _senderName),
            _field('Sender relation', _senderRelation),
            _field('Contact', _contact, keyboard: TextInputType.phone),
            SizedBox(height: 2.h),
            GradientButton(
              label: 'Save Profile',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5.sp,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 0.7.h),
          TextField(
            controller: controller,
            keyboardType: keyboard,
            decoration: InputDecoration(hintText: label),
          ),
        ],
      ),
    );
  }
}

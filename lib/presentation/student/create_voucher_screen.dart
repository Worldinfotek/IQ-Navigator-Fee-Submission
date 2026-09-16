import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../bloc/fee/fee_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/app_user.dart';

class CreateVoucherScreen extends StatefulWidget {
  const CreateVoucherScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<CreateVoucherScreen> createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends State<CreateVoucherScreen> {
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late String _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = _months[now.month - 1];
    _year = now.year;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!widget.user.hasCompleteProfile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your profile first.')),
      );
      return;
    }
    if (_formKey.currentState?.validate() != true) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;

    context.read<FeeBloc>().add(
          FeeCreateRequested(
            student: widget.user,
            feeMonth: '$_month $_year',
            amount: amount,
            details: _detailsController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(4, (index) => DateTime.now().year - 1 + index);

    return SafeArea(
      child: BlocListener<FeeBloc, FeeState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            _amountController.clear();
            _detailsController.clear();
            context.read<FeeBloc>().add(const FeeMessageCleared());
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
            context.read<FeeBloc>().add(const FeeMessageCleared());
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Fee Voucher',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  'Profile details are attached automatically.',
                  style: TextStyle(fontSize: 14.5.sp, color: AppColors.muted),
                ),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '${widget.user.studentName}\n'
                    'Parent: ${widget.user.parentName} (${widget.user.parentRelation})\n'
                    'Sender: ${widget.user.senderName} (${widget.user.senderRelation})\n'
                    'Contact: ${widget.user.contact}',
                    style: TextStyle(
                      height: 1.5,
                      fontSize: 14.5.sp,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Fee month',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5.sp,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _month,
                        items: _months
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text(month),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) _month = value;
                        },
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: _year,
                        items: years
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text('$year'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) _year = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5.sp,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 0.8.h),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(hintText: '7000'),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Other details',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5.sp,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 0.8.h),
                TextFormField(
                  controller: _detailsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Bank name, transaction ID, notes...',
                  ),
                ),
                SizedBox(height: 3.h),
                BlocBuilder<FeeBloc, FeeState>(
                  builder: (context, state) {
                    return GradientButton(
                      label: 'Submit Voucher',
                      loading: state.submitting,
                      onPressed: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

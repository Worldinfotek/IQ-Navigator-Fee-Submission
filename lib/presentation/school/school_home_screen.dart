import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/fee/fee_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/fee_tile.dart';
import '../../data/models/app_user.dart';
import '../shared/fee_detail_screen.dart';

class SchoolHomeScreen extends StatefulWidget {
  const SchoolHomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<SchoolHomeScreen> createState() => _SchoolHomeScreenState();
}

class _SchoolHomeScreenState extends State<SchoolHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FeeBloc>().add(const FeeWatchStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.displayName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          'Submitted fee vouchers',
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthLogoutRequested()),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              BlocBuilder<FeeBloc, FeeState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          'Total received',
                          'Rs ${state.totalAmount.toStringAsFixed(0)}',
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _statCard(
                          'Vouchers',
                          '${state.vouchers.length}',
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: BlocBuilder<FeeBloc, FeeState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error != null && state.vouchers.isEmpty) {
                      return Center(
                        child: Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 15.sp,
                          ),
                        ),
                      );
                    }
                    if (state.vouchers.isEmpty) {
                      return Center(
                        child: Text(
                          'No fee submissions yet.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 15.sp,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: state.vouchers.length,
                      separatorBuilder: (_, _) => SizedBox(height: 1.4.h),
                      itemBuilder: (context, index) {
                        final voucher = state.vouchers[index];
                        return FeeTile(
                          voucher: voucher,
                          showStudentName: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    FeeDetailScreen(voucher: voucher),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

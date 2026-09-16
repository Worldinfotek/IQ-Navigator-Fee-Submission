import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/fee/fee_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/fee_tile.dart';
import '../../data/models/app_user.dart';
import '../shared/fee_detail_screen.dart';
import 'create_voucher_screen.dart';
import 'student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<FeeBloc>().add(FeeWatchStarted(studentId: widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _StudentFeesTab(user: widget.user),
      CreateVoucherScreen(user: widget.user),
      StudentProfileScreen(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'My Fees',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_card_outlined),
            selectedIcon: Icon(Icons.add_card_rounded),
            label: 'Submit',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _StudentFeesTab extends StatelessWidget {
  const _StudentFeesTab({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                        'Hi, ${user.studentName.split(' ').first}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        'Your submitted fee vouchers',
                        style: TextStyle(fontSize: 14.5.sp, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            BlocBuilder<FeeBloc, FeeState>(
              builder: (context, state) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.5.w),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total submitted',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14.5.sp,
                        ),
                      ),
                      Text(
                        'Rs ${state.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${state.vouchers.length} voucher(s)',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
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
                        style: TextStyle(color: AppColors.danger, fontSize: 15.sp),
                      ),
                    );
                  }
                  if (state.vouchers.isEmpty) {
                    return Center(
                      child: Text(
                        'No fee submitted yet.\nCreate a voucher from the Submit tab.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: 15.sp),
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
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => FeeDetailScreen(voucher: voucher),
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
    );
  }
}

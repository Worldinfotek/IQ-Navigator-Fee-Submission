part of 'fee_bloc.dart';

class FeeState extends Equatable {
  const FeeState({
    this.vouchers = const [],
    this.loading = false,
    this.submitting = false,
    this.error,
    this.successMessage,
  });

  final List<FeeVoucher> vouchers;
  final bool loading;
  final bool submitting;
  final String? error;
  final String? successMessage;

  double get totalAmount =>
      vouchers.fold<double>(0, (sum, voucher) => sum + voucher.amount);

  FeeState copyWith({
    List<FeeVoucher>? vouchers,
    bool? loading,
    bool? submitting,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return FeeState(
      vouchers: vouchers ?? this.vouchers,
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      error: clearMessages ? null : (error ?? this.error),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        vouchers,
        loading,
        submitting,
        error,
        successMessage,
      ];
}

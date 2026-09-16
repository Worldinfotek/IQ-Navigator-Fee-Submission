import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_user.dart';
import '../../data/models/fee_voucher.dart';
import '../../data/repositories/fee_repository.dart';

part 'fee_event.dart';
part 'fee_state.dart';

class FeeBloc extends Bloc<FeeEvent, FeeState> {
  FeeBloc({required this.feeRepository}) : super(const FeeState()) {
    on<FeeWatchStarted>(_onWatchStarted);
    on<FeeCreateRequested>(_onCreateRequested);
    on<FeeMessageCleared>(_onMessageCleared);
    on<_FeeUpdated>(_onUpdated);
    on<_FeeWatchFailed>(_onWatchFailed);
  }

  final FeeRepository feeRepository;
  StreamSubscription<List<FeeVoucher>>? _subscription;

  Future<void> _onWatchStarted(
    FeeWatchStarted event,
    Emitter<FeeState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearMessages: true));
    await _subscription?.cancel();
    _subscription = feeRepository
        .watchVouchers(studentId: event.studentId)
        .listen(
          (vouchers) => add(_FeeUpdated(vouchers)),
          onError: (Object error) => add(_FeeWatchFailed(error.toString())),
        );
  }

  void _onUpdated(_FeeUpdated event, Emitter<FeeState> emit) {
    emit(state.copyWith(vouchers: event.vouchers, loading: false));
  }

  void _onWatchFailed(_FeeWatchFailed event, Emitter<FeeState> emit) {
    emit(state.copyWith(loading: false, error: event.message));
  }

  Future<void> _onCreateRequested(
    FeeCreateRequested event,
    Emitter<FeeState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      await feeRepository.createVoucher(
        student: event.student,
        feeMonth: event.feeMonth,
        amount: event.amount,
        details: event.details,
      );
      emit(
        state.copyWith(
          submitting: false,
          successMessage: 'Fee voucher submitted successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          submitting: false,
          error: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onMessageCleared(FeeMessageCleared event, Emitter<FeeState> emit) {
    emit(state.copyWith(clearMessages: true));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _FeeUpdated extends FeeEvent {
  const _FeeUpdated(this.vouchers);

  final List<FeeVoucher> vouchers;

  @override
  List<Object?> get props => [vouchers];
}

class _FeeWatchFailed extends FeeEvent {
  const _FeeWatchFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

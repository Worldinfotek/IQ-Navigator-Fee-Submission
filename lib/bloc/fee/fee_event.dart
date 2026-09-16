part of 'fee_bloc.dart';

sealed class FeeEvent extends Equatable {
  const FeeEvent();

  @override
  List<Object?> get props => [];
}

class FeeWatchStarted extends FeeEvent {
  const FeeWatchStarted({this.studentId});

  final String? studentId;

  @override
  List<Object?> get props => [studentId];
}

class FeeCreateRequested extends FeeEvent {
  const FeeCreateRequested({
    required this.student,
    required this.feeMonth,
    required this.amount,
    required this.details,
  });

  final AppUser student;
  final String feeMonth;
  final double amount;
  final String details;

  @override
  List<Object?> get props => [student, feeMonth, amount, details];
}

class FeeMessageCleared extends FeeEvent {
  const FeeMessageCleared();
}

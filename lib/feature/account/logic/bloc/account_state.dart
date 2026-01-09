part of 'account_bloc.dart';

@immutable
abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<SavedAccountModel> accounts;
  final String? currentUserId;

  AccountLoaded(this.accounts, this.currentUserId);
}

class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
}

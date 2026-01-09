part of 'account_bloc.dart';

@immutable
abstract class AccountEvent {}

class LoadAccounts extends AccountEvent {}

class AddAccount extends AccountEvent {
}

class SwitchAccount extends AccountEvent {
  final SavedAccountModel account;
  SwitchAccount(this.account);
}

class RemoveAccount extends AccountEvent {
  final String uid;
  RemoveAccount(this.uid);
}

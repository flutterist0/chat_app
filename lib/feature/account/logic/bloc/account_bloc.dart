import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/account/data/models/saved_account_model.dart';
import 'package:test_app/feature/account/domain/repositories/account_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _repository;
  final FirebaseAuth _auth;

  AccountBloc(this._repository, this._auth) : super(AccountInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<AddAccount>(_onAddAccount);
    on<SwitchAccount>(_onSwitchAccount);
    on<RemoveAccount>(_onRemoveAccount);
  }

  Future<void> _onLoadAccounts(LoadAccounts event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final accounts = await _repository.getSavedAccounts();
      final currentUser = _auth.currentUser;
      emit(AccountLoaded(accounts, currentUser?.uid));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onAddAccount(AddAccount event, Emitter<AccountState> emit) async {
    add(LoadAccounts());
  }

  Future<void> _onSwitchAccount(SwitchAccount event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final currentAccounts = await _repository.getSavedAccounts();
      await _repository.switchAccount(event.account);
      emit(AccountLoaded(currentAccounts, event.account.uid));
    } catch (e) {
      emit(AccountError("Hesaba keçid zamanı xəta: $e"));
      add(LoadAccounts());
    }
  }

  Future<void> _onRemoveAccount(RemoveAccount event, Emitter<AccountState> emit) async {
    try {
      await _repository.removeAccount(event.uid);
      add(LoadAccounts());
    } catch (e) {
      emit(AccountError("Hesab silinərkən xəta: $e"));
    }
  }
}

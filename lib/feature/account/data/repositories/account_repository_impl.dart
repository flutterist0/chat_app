import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_app/feature/account/data/models/saved_account_model.dart';
import 'package:test_app/feature/account/domain/repositories/account_repository.dart';
import 'package:test_app/feature/auth/service/auth_service.dart';

class AccountRepositoryImpl implements AccountRepository {
  final FlutterSecureStorage _storage;
  final AuthService _authService;
  static const String _storageKey = 'saved_accounts';

  AccountRepositoryImpl(this._storage, this._authService);

  @override
  Future<void> saveAccount(SavedAccountModel account) async {
    List<SavedAccountModel> currentAccounts = await getSavedAccounts();
    
    currentAccounts.removeWhere((acc) => acc.uid == account.uid);
    currentAccounts.add(account);

    await _saveList(currentAccounts);
  }

  @override
  Future<List<SavedAccountModel>> getSavedAccounts() async {
    String? jsonString = await _storage.read(key: _storageKey);
    if (jsonString == null) return [];

    try {
      List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => SavedAccountModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> removeAccount(String uid) async {
    List<SavedAccountModel> currentAccounts = await getSavedAccounts();
    currentAccounts.removeWhere((acc) => acc.uid == uid);
    await _saveList(currentAccounts);
  }

  @override
  Future<void> switchAccount(SavedAccountModel account) async {
    await _authService.signOut(disconnectGoogle: false);
    
    if (account.password.isNotEmpty) {
       await _authService.signIn(account.email, account.password);
    } else {
       if (account.accessToken != null && account.idToken != null) {
         final credential = await _authService.signInWithGoogleTokens(account.accessToken!, account.idToken!);
         if (credential != null && credential.user?.email == account.email) {
           return; 
         }
       }

       final credential = await _authService.signInWithGoogleSilently();
       if (credential != null && credential.user?.email == account.email) {
         return;
       }
       await _authService.signInWithGoogle();
    }
  }

  Future<void> _saveList(List<SavedAccountModel> accounts) async {
    String jsonString = json.encode(accounts.map((e) => e.toMap()).toList());
    await _storage.write(key: _storageKey, value: jsonString);
  }
}

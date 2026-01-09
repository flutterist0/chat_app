import 'package:test_app/feature/account/data/models/saved_account_model.dart';

abstract class AccountRepository {
  Future<void> saveAccount(SavedAccountModel account);
  Future<List<SavedAccountModel>> getSavedAccounts();
  Future<void> removeAccount(String uid);
  Future<void> switchAccount(SavedAccountModel account);
}

import '../entities/bank_account.dart';
import '../repositories/account_repository.dart';

class GetBankList {
  final AccountRepository repository;
  GetBankList(this.repository);

  Future<List<BankInfo>> call({bool forceRefresh = false}) =>
      repository.getBankList(forceRefresh: forceRefresh);
}

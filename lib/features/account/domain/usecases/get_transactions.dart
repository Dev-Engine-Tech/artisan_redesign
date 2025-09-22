import '../entities/earnings.dart';
import '../repositories/account_repository.dart';

class GetTransactions {
  final AccountRepository repository;
  GetTransactions(this.repository);

  Future<List<TransactionItem>> call({int page = 1, int limit = 20}) =>
      repository.getTransactions(page: page, limit: limit);
}

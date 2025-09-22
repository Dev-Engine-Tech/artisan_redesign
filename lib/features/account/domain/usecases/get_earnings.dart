import '../entities/earnings.dart';
import '../repositories/account_repository.dart';

class GetEarnings {
  final AccountRepository repository;
  GetEarnings(this.repository);

  Future<Earnings> call() => repository.getEarnings();
}

import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomers {
  final CustomerRepository repository;
  GetCustomers(this.repository);

  Future<List<Customer>> call({
    int page = 1,
    int limit = 50,
    String? searchQuery,
  }) {
    return repository.getCustomers(
      page: page,
      limit: limit,
      searchQuery: searchQuery,
    );
  }
}

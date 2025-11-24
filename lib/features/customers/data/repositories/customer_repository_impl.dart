import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Customer>> getCustomers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    final customers = await remoteDataSource.getCustomers(
      page: page,
      searchQuery: searchQuery,
    );
    return customers.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Customer> getCustomerById(String id) async {
    final customer = await remoteDataSource.getCustomerById(id);
    return customer.toEntity();
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final data = CustomerModel.fromEntity(customer).toJson();
    final created = await remoteDataSource.createCustomer(data);
    return created.toEntity();
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final data = CustomerModel.fromEntity(customer).toJson();
    final updated = await remoteDataSource.updateCustomer(customer.id, data);
    return updated.toEntity();
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await remoteDataSource.deleteCustomer(id);
  }

  @override
  Stream<List<Customer>> watchCustomers() {
    throw UnimplementedError(
      'Stream watching is not supported for remote data source. '
      'Use getCustomers() instead and implement polling if needed.',
    );
  }
}

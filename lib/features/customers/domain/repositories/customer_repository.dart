import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  });

  Future<Customer> getCustomerById(String id);

  Future<Customer> createCustomer(Customer customer);

  Future<Customer> updateCustomer(Customer customer);

  Future<void> deleteCustomer(String id);

  Stream<List<Customer>> watchCustomers();
}

import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({
    int page = 1,
    String? searchQuery,
  });

  Future<CustomerModel> getCustomerById(String id);

  Future<CustomerModel> createCustomer(Map<String, dynamic> data);

  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data);

  Future<void> deleteCustomer(String id);
}

class CustomerRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CustomerRemoteDataSource {
  CustomerRemoteDataSourceImpl(super.dio);

  @override
  Future<List<CustomerModel>> getCustomers({
    int page = 1,
    String? searchQuery,
  }) =>
      getList(
        ApiEndpoints.customers,
        fromJson: CustomerModel.fromJson,
        queryParams: {
          'page': page,
          if (searchQuery != null && searchQuery.isNotEmpty)
            'search': searchQuery,
        },
      );

  @override
  Future<CustomerModel> getCustomerById(String id) => get(
        ApiEndpoints.customer(id),
        fromJson: CustomerModel.fromJson,
      );

  @override
  Future<CustomerModel> createCustomer(Map<String, dynamic> data) => post(
        ApiEndpoints.customers,
        data: data,
        fromJson: CustomerModel.fromJson,
      );

  @override
  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data) =>
      put(
        ApiEndpoints.customer(id),
        data: data,
        fromJson: CustomerModel.fromJson,
      );

  @override
  Future<void> deleteCustomer(String id) async {
    await deleteVoid(ApiEndpoints.customer(id));
  }
}

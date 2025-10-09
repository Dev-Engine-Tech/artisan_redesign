import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:artisans_circle/features/customers/domain/entities/customer.dart';
import 'package:artisans_circle/features/customers/domain/repositories/customer_repository.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late _MockCustomerRepository repo;
  late GetCustomers usecase;

  setUp(() {
    repo = _MockCustomerRepository();
    usecase = GetCustomers(repo);
  });

  test('calls repository with provided params and returns customers', () async {
    final customers = [
      Customer(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    when(() => repo.getCustomers(page: 2, limit: 10, searchQuery: 'john'))
        .thenAnswer((_) async => customers);

    final result =
        await usecase(page: 2, limit: 10, searchQuery: 'john');

    expect(result, customers);
    verify(() => repo.getCustomers(page: 2, limit: 10, searchQuery: 'john'))
        .called(1);
  });
}


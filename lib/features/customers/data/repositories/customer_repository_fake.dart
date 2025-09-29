import 'dart:async';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerRepositoryFake implements CustomerRepository {
  final List<Customer> _customers = [];
  final StreamController<List<Customer>> _streamController = StreamController.broadcast();

  CustomerRepositoryFake() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    final sampleCustomers = [
      Customer(
        id: '1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+234 801 234 5678',
        company: 'Tech Solutions Ltd',
        address: '123 Business Street',
        city: 'Lagos',
        state: 'Lagos',
        country: 'Nigeria',
        postalCode: '100001',
        notes: 'Preferred client for electrical work',
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 30)),
        totalInvoices: 8,
        totalAmount: 2450000,
        lastInvoiceDate: now.subtract(const Duration(days: 15)),
      ),
      Customer(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah.johnson@gmail.com',
        phone: '+234 802 345 6789',
        company: 'Creative Designs',
        address: '456 Art Avenue',
        city: 'Abuja',
        state: 'FCT',
        country: 'Nigeria',
        postalCode: '900001',
        notes: 'Interior design projects, pays on time',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 10)),
        totalInvoices: 5,
        totalAmount: 1800000,
        lastInvoiceDate: now.subtract(const Duration(days: 5)),
      ),
      Customer(
        id: '3',
        name: 'Michael Chen',
        email: 'michael.chen@business.com',
        phone: '+234 803 456 7890',
        company: 'Global Enterprises',
        address: '789 Corporate Plaza',
        city: 'Port Harcourt',
        state: 'Rivers',
        country: 'Nigeria',
        postalCode: '500001',
        notes: 'Large scale construction projects',
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 5)),
        totalInvoices: 12,
        totalAmount: 4200000,
        lastInvoiceDate: now.subtract(const Duration(days: 3)),
      ),
      Customer(
        id: '4',
        name: 'Amara Okafor',
        email: 'amara.okafor@startup.ng',
        phone: '+234 804 567 8901',
        company: 'StartupHub NG',
        address: '321 Innovation Drive',
        city: 'Ibadan',
        state: 'Oyo',
        country: 'Nigeria',
        postalCode: '200001',
        notes: 'Tech startup, quick decision maker',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 2)),
        totalInvoices: 3,
        totalAmount: 950000,
        lastInvoiceDate: now.subtract(const Duration(days: 8)),
      ),
      Customer(
        id: '5',
        name: 'David Smith',
        email: 'david.smith@retail.com',
        phone: '+234 805 678 9012',
        company: 'Retail Solutions',
        address: '654 Commerce Street',
        city: 'Kano',
        state: 'Kano',
        country: 'Nigeria',
        postalCode: '700001',
        notes: 'Retail chain, multiple locations',
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now.subtract(const Duration(days: 20)),
        totalInvoices: 15,
        totalAmount: 3600000,
        lastInvoiceDate: now.subtract(const Duration(days: 12)),
      ),
      Customer(
        id: '6',
        name: 'Fatima Abdullahi',
        email: 'fatima.abdullahi@consulting.ng',
        phone: '+234 806 789 0123',
        company: 'Northern Consulting',
        address: '987 Professional Way',
        city: 'Kaduna',
        state: 'Kaduna',
        country: 'Nigeria',
        postalCode: '800001',
        notes: 'Management consulting firm',
        createdAt: now.subtract(const Duration(days: 75)),
        updatedAt: now.subtract(const Duration(days: 1)),
        totalInvoices: 6,
        totalAmount: 2100000,
        lastInvoiceDate: now.subtract(const Duration(days: 7)),
      ),
    ];

    _customers.addAll(sampleCustomers);
    _streamController.add(_customers);
  }

  @override
  Future<List<Customer>> getCustomers({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    var filteredCustomers = _customers.where((customer) {
      if (searchQuery?.isEmpty ?? true) return true;
      
      final query = searchQuery!.toLowerCase();
      return customer.name.toLowerCase().contains(query) ||
             customer.email.toLowerCase().contains(query) ||
             (customer.company?.toLowerCase().contains(query) ?? false) ||
             (customer.phone?.contains(query) ?? false);
    }).toList();

    // Sort by last updated (newest first)
    filteredCustomers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // Pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredCustomers.length) {
      return [];
    }
    
    return filteredCustomers.sublist(
      startIndex,
      endIndex > filteredCustomers.length ? filteredCustomers.length : endIndex,
    );
  }

  @override
  Future<Customer> getCustomerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final customer = _customers.firstWhere(
      (customer) => customer.id == id,
      orElse: () => throw Exception('Customer not found'),
    );
    
    return customer;
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final newCustomer = customer.copyWith(
      id: 'CUST_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _customers.add(newCustomer);
    _streamController.add(_customers);
    
    return newCustomer;
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index == -1) {
      throw Exception('Customer not found');
    }
    
    final updatedCustomer = customer.copyWith(
      updatedAt: DateTime.now(),
    );
    
    _customers[index] = updatedCustomer;
    _streamController.add(_customers);
    
    return updatedCustomer;
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    _customers.removeWhere((customer) => customer.id == id);
    _streamController.add(_customers);
  }

  @override
  Stream<List<Customer>> watchCustomers() {
    return _streamController.stream;
  }

  void dispose() {
    _streamController.close();
  }
}
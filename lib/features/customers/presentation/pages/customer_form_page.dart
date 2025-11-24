import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/core/di.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerFormPage extends StatefulWidget {
  final Customer? customer;

  const CustomerFormPage({
    super.key,
    this.customer,
  });

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final CustomerRepository _customerRepository;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _notesController;

  bool _isLoading = false;
  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _customerRepository = getIt<CustomerRepository>();
    _initializeControllers();
  }

  void _initializeControllers() {
    final customer = widget.customer;

    _nameController = TextEditingController(text: customer?.name ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _companyController = TextEditingController(text: customer?.company ?? '');
    _addressController = TextEditingController(text: customer?.address ?? '');
    _cityController = TextEditingController(text: customer?.city ?? '');
    _stateController = TextEditingController(text: customer?.state ?? '');
    _countryController =
        TextEditingController(text: customer?.country ?? 'Nigeria');
    _postalCodeController =
        TextEditingController(text: customer?.postalCode ?? '');
    _notesController = TextEditingController(text: customer?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: AppSpacing.paddingXXL,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.subtleBorder.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.brownHeader,
            ),
          ),
          if (subtitle != null) ...[
            AppSpacing.spaceXS,
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
          AppSpacing.spaceXL,
          ...children,
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value!)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value?.isEmpty ?? true) return null; // Phone is optional

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value!)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customer = Customer(
        id: widget.customer?.id ?? '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        totalInvoices: widget.customer?.totalInvoices ?? 0,
        totalAmount: widget.customer?.totalAmount ?? 0.0,
        lastInvoiceDate: widget.customer?.lastInvoiceDate,
      );

      final savedCustomer = _isEditing
          ? await _customerRepository.updateCustomer(customer)
          : await _customerRepository.createCustomer(customer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Customer updated successfully!'
                  : 'Customer created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(savedCustomer);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving customer: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.brownHeader),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                title: Text(
                  _isEditing ? 'Edit Customer' : 'New Customer',
                  style: const TextStyle(
                    color: AppColors.brownHeader,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.lightPeach,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Form Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  AppSpacing.spaceLG,

                  // Basic Information Section
                  _buildSection(
                    title: 'Basic Information',
                    subtitle: 'Essential customer details',
                    children: [
                      CustomTextFormField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        hint: 'Enter customer\'s full name',
                        required: true,
                        style: CustomTextFieldStyle.outlined,
                      ),
                      CustomTextFormField(
                        controller: _emailController,
                        label: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        hint: 'customer@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        style: CustomTextFieldStyle.outlined,
                      ),
                      CustomTextFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone_outlined,
                        hint: '+234 801 234 5678',
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                        style: CustomTextFieldStyle.outlined,
                      ),
                      CustomTextFormField(
                        controller: _companyController,
                        label: 'Company (Optional)',
                        prefixIcon: Icons.business_outlined,
                        hint: 'Company or organization name',
                        style: CustomTextFieldStyle.outlined,
                      ),
                    ],
                  ),

                  // Address Information Section
                  _buildSection(
                    title: 'Address Information',
                    subtitle: 'Location and contact details',
                    children: [
                      CustomTextFormField(
                        controller: _addressController,
                        label: 'Street Address',
                        prefixIcon: Icons.home_outlined,
                        hint: 'Enter street address',
                        style: CustomTextFieldStyle.outlined,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: _cityController,
                              label: 'City',
                              prefixIcon: Icons.location_city_outlined,
                              hint: 'City',
                              style: CustomTextFieldStyle.outlined,
                            ),
                          ),
                          AppSpacing.spaceLG,
                          Expanded(
                            child: CustomTextFormField(
                              controller: _stateController,
                              label: 'State',
                              prefixIcon: Icons.map_outlined,
                              hint: 'State',
                              style: CustomTextFieldStyle.outlined,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: _countryController,
                              label: 'Country',
                              prefixIcon: Icons.public_outlined,
                              hint: 'Country',
                              style: CustomTextFieldStyle.outlined,
                            ),
                          ),
                          AppSpacing.spaceLG,
                          Expanded(
                            child: CustomTextFormField(
                              controller: _postalCodeController,
                              label: 'Postal Code',
                              prefixIcon: Icons.markunread_mailbox_outlined,
                              hint: '100001',
                              style: CustomTextFieldStyle.outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Additional Information Section
                  _buildSection(
                    title: 'Additional Information',
                    subtitle: 'Notes and special instructions',
                    children: [
                      CustomTextFormField(
                        controller: _notesController,
                        label: 'Notes (Optional)',
                        prefixIcon: Icons.note_outlined,
                        hint: 'Any special notes about this customer',
                        maxLines: 4,
                        style: CustomTextFieldStyle.outlined,
                      ),
                    ],
                  ),

                  AppSpacing.spaceXXXL,

                  // Save Button
                  Padding(
                    padding: AppSpacing.horizontalXXL,
                    child: PrimaryButton(
                      text: _isEditing ? 'Update Customer' : 'Create Customer',
                      onPressed: _saveCustomer,
                      isLoading: _isLoading,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

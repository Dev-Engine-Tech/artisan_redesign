import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/core/utils/responsive.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/account/presentation/pages/subscription_page.dart';
import '../../domain/entities/collaboration.dart';
import '../../domain/entities/artisan_search_result.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../../domain/usecases/search_artisans.dart';
import '../bloc/collaboration_bloc.dart';
import '../bloc/collaboration_event.dart';
import '../bloc/collaboration_state.dart';

/// Refactored invite collaborator page with:
/// - Proper Clean Architecture (no direct API calls)
/// - Performance optimizations (debouncing, const widgets)
/// - Security (input validation, sanitization)
/// - SOLID principles (SRP, DIP)
class InviteCollaboratorPageRefactored extends StatefulWidget {
  final Job job;

  const InviteCollaboratorPageRefactored({
    super.key,
    required this.job,
  });

  @override
  State<InviteCollaboratorPageRefactored> createState() =>
      _InviteCollaboratorPageRefactoredState();
}

class _InviteCollaboratorPageRefactoredState
    extends State<InviteCollaboratorPageRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  final _externalNameController = TextEditingController();
  final _externalContactController = TextEditingController();

  // Use case injection (Dependency Inversion Principle)
  late final SearchArtisans _searchArtisans;

  PaymentMethod _paymentMethod = PaymentMethod.percentage;
  ArtisanSearchResult? _selectedArtisan;
  List<ArtisanSearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;
  bool _inviteExternal = false; // Toggle between existing and external artisan

  // Performance: Debounce delay (prevents excessive API calls)
  static const _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _searchArtisans = getIt<SearchArtisans>();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    _externalNameController.dispose();
    _externalContactController.dispose();
    super.dispose();
  }

  /// Debounced search (Performance Optimization)
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () => _performSearch(query));
  }

  /// Perform search using use case (Clean Architecture)
  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Use case handles validation and business logic
      final results = await _searchArtisans(query);

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
      });

      // Security: Don't expose internal error details
      _showError('Unable to search artisans. Please try again.');
    }
  }

  void _inviteCollaborator() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;

    // Security: Validate amount based on payment method
    if (_paymentMethod == PaymentMethod.percentage && (amount < 0 || amount > 100)) {
      _showError('Percentage must be between 0 and 100');
      return;
    }

    if (_paymentMethod == PaymentMethod.fixed && amount <= 0) {
      _showError('Amount must be greater than 0');
      return;
    }

    if (_inviteExternal) {
      // Handle external artisan invitation
      _inviteExternalArtisan();
      return;
    }

    // Handle existing artisan invitation
    if (_selectedArtisan == null) {
      _showError('Please select an artisan to invite');
      return;
    }

    // Parse job ID safely
    final jobApplicationId = int.tryParse(widget.job.id);
    if (jobApplicationId == null) {
      _showError('Invalid job reference');
      return;
    }

    context.read<CollaborationBloc>().add(
          InviteCollaboratorEvent(
            jobApplicationId: jobApplicationId,
            collaboratorId: _selectedArtisan!.id,
            paymentMethod: _paymentMethod,
            paymentAmount: amount,
            message: _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
          ),
        );
  }

  void _inviteExternalArtisan() {
    // TODO: When backend API is ready, implement external invitation
    // For now, show a message that this feature is coming soon
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text(
          'The ability to invite artisans who are not yet on the platform will be available soon. '
          'They will receive an email/SMS invitation to join and collaborate on your job.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Security: Generic error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show upgrade dialog for subscription limitations
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upgrade Required'),
          content: const Text(
            'You need to upgrade your subscription plan to invite collaborators to your jobs.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close invite page
                // Navigate to subscription page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
              ),
              child: const Text('Upgrade Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollaborationBloc, CollaborationState>(
      listener: (context, state) {
        if (state is CollaborationInviteSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitation sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is CollaborationError) {
          if (state.isSubscriptionError) {
            // Show upgrade dialog for subscription errors
            _showUpgradeDialog();
          } else {
            // Security: Don't expose internal error details
            _showError('Unable to send invitation. Please try again.');
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightPeach,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.responsivePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _JobInfoCard(job: widget.job), // Extracted widget (SRP)
                  const SizedBox(height: 24),
                  _buildInviteTypeToggle(),
                  const SizedBox(height: 24),
                  if (_inviteExternal) ...[
                    _buildExternalInviteForm(),
                    const SizedBox(height: 24),
                    _buildPaymentTermsSection(),
                    const SizedBox(height: 24),
                    _buildInviteButton(),
                  ] else ...[
                    _buildSearchSection(),
                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _ArtisanSearchResults( // Extracted widget (SRP)
                        results: _searchResults,
                        selectedArtisan: _selectedArtisan,
                        onSelect: (artisan) {
                          setState(() {
                            _selectedArtisan = artisan;
                          });
                        },
                      ),
                    ],
                    if (_selectedArtisan != null) ...[
                      const SizedBox(height: 24),
                      _buildPaymentTermsSection(),
                      const SizedBox(height: 24),
                      _buildInviteButton(),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.softPink,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: const Text(
        'Invite Collaborator',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInviteTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _inviteExternal = false;
                  _selectedArtisan = null;
                  _searchResults = [];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !_inviteExternal ? AppColors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.search,
                      color: !_inviteExternal ? Colors.white : AppColors.brownHeader,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Existing Artisan',
                      style: TextStyle(
                        color: !_inviteExternal ? Colors.white : AppColors.brownHeader,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _inviteExternal = true;
                  _selectedArtisan = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _inviteExternal ? AppColors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      color: _inviteExternal ? Colors.white : AppColors.brownHeader,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'New Artisan',
                      style: TextStyle(
                        color: _inviteExternal ? Colors.white : AppColors.brownHeader,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalInviteForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invite New Artisan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brownHeader,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'They will receive an invitation to join the platform',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _externalNameController,
            decoration: InputDecoration(
              labelText: 'Artisan Name',
              hintText: 'Enter artisan\'s full name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter artisan name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _externalContactController,
            decoration: InputDecoration(
              labelText: 'Email or Phone',
              hintText: 'Enter email or phone number',
              prefixIcon: const Icon(Icons.contact_mail_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter email or phone';
              }
              // Basic validation
              if (!value.contains('@') && !RegExp(r'^\d{10,}$').hasMatch(value)) {
                return 'Please enter a valid email or phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Artisan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.brownHeader,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.softBorder),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or phone number...',
              hintStyle: const TextStyle(color: Colors.black38),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.orange,
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _onSearchChanged, // Debounced
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Terms',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.brownHeader,
          ),
        ),
        const SizedBox(height: 12),
        _PaymentMethodSelector( // Extracted widget (SRP)
          selectedMethod: _paymentMethod,
          onMethodChanged: (method) {
            setState(() {
              _paymentMethod = method;
              _amountController.clear();
            });
          },
        ),
        const SizedBox(height: 16),
        _AmountField( // Extracted widget (SRP)
          controller: _amountController,
          paymentMethod: _paymentMethod,
        ),
        const SizedBox(height: 16),
        _MessageField(controller: _messageController), // Extracted widget (SRP)
      ],
    );
  }

  Widget _buildInviteButton() {
    return BlocBuilder<CollaborationBloc, CollaborationState>(
      builder: (context, state) {
        final isLoading = state is CollaborationLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _inviteCollaborator,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Send Invitation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// EXTRACTED WIDGETS (Single Responsibility Principle)
// =============================================================================

/// Job info card widget (SRP - displays job information only)
class _JobInfoCard extends StatelessWidget {
  final Job job;

  const _JobInfoCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.brownHeader,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            job.category,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Artisan search results widget (SRP - displays search results only)
class _ArtisanSearchResults extends StatelessWidget {
  final List<ArtisanSearchResult> results;
  final ArtisanSearchResult? selectedArtisan;
  final ValueChanged<ArtisanSearchResult> onSelect;

  const _ArtisanSearchResults({
    required this.results,
    required this.selectedArtisan,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final artisan = results[index];
          final isSelected = selectedArtisan?.id == artisan.id;

          return _ArtisanListTile( // Further extracted
            artisan: artisan,
            isSelected: isSelected,
            onTap: () => onSelect(artisan),
          );
        },
      ),
    );
  }
}

/// Artisan list tile (SRP - displays single artisan)
class _ArtisanListTile extends StatelessWidget {
  final ArtisanSearchResult artisan;
  final bool isSelected;
  final VoidCallback onTap;

  const _ArtisanListTile({
    required this.artisan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColors.softPeach,
      leading: CircleAvatar(
        backgroundColor: AppColors.orange.withOpacity(0.2),
        child: Text(
          artisan.name[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.brownHeader,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        artisan.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artisan.occupation,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          if (artisan.phone != null) ...[
            const SizedBox(height: 2),
            Text(
              artisan.phone!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ],
        ],
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.orange)
          : null,
      onTap: onTap,
    );
  }
}

/// Payment method selector (SRP)
class _PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onMethodChanged;

  const _PaymentMethodSelector({
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        children: [
          RadioListTile<PaymentMethod>(
            title: const Text(
              'Percentage of Job Payment',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'e.g., 30% of total job payment',
              style: TextStyle(fontSize: 12),
            ),
            value: PaymentMethod.percentage,
            groupValue: selectedMethod,
            activeColor: AppColors.orange,
            onChanged: (value) => onMethodChanged(value!),
          ),
          const Divider(height: 1),
          RadioListTile<PaymentMethod>(
            title: const Text(
              'Fixed Amount',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Specific amount in Naira',
              style: TextStyle(fontSize: 12),
            ),
            value: PaymentMethod.fixed,
            groupValue: selectedMethod,
            activeColor: AppColors.orange,
            onChanged: (value) => onMethodChanged(value!),
          ),
        ],
      ),
    );
  }
}

/// Amount field with validation (SRP)
class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final PaymentMethod paymentMethod;

  const _AmountField({
    required this.controller,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText:
            paymentMethod == PaymentMethod.percentage ? 'Percentage (%)' : 'Amount (₦)',
        hintText: paymentMethod == PaymentMethod.percentage ? 'e.g., 30' : 'e.g., 50000',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.softBorder),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        if (paymentMethod == PaymentMethod.percentage && amount > 100) {
          return 'Percentage cannot exceed 100%';
        }
        return null;
      },
    );
  }
}

/// Message field (SRP)
class _MessageField extends StatelessWidget {
  final TextEditingController controller;

  const _MessageField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      maxLength: 500, // Security: Limit message length
      decoration: InputDecoration(
        labelText: 'Message (Optional)',
        hintText: 'Add a message to the collaborator...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.softBorder),
        ),
      ),
    );
  }
}

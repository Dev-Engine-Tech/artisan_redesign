import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/core/utils/responsive.dart';
import 'package:artisans_circle/core/api/endpoints.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import '../../domain/entities/collaboration.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../bloc/collaboration_bloc.dart';
import '../bloc/collaboration_event.dart';
import '../bloc/collaboration_state.dart';

/// Page to invite collaborators to a job
/// Allows artisans to search for other artisans and invite them with payment terms
class InviteCollaboratorPage extends StatefulWidget {
  final Job job;

  const InviteCollaboratorPage({
    super.key,
    required this.job,
  });

  @override
  State<InviteCollaboratorPage> createState() => _InviteCollaboratorPageState();
}

class _InviteCollaboratorPageState extends State<InviteCollaboratorPage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.percentage;
  int? _selectedArtisanId;
  String? _selectedArtisanName;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _searchArtisans(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final dio = getIt<Dio>();
      final response = await dio.get(
        ApiEndpoints.searchArtisans,
        queryParameters: {'q': query},
      );

      if (!mounted) return;

      // Parse the response
      final data = response.data;
      List<Map<String, dynamic>> artisans = [];

      if (data is Map && data['data'] != null) {
        final results = data['data'];
        if (results is List) {
          artisans = results.map((artisan) {
            return {
              'id': artisan['id'] ?? artisan['user_id'] ?? 0,
              'name': artisan['name'] ??
                     artisan['full_name'] ??
                     '${artisan['first_name'] ?? ''} ${artisan['last_name'] ?? ''}'.trim(),
              'occupation': artisan['occupation'] ??
                           artisan['category'] ??
                           artisan['expertise'] ??
                           'Artisan',
              'rating': artisan['rating'] is num
                  ? (artisan['rating'] as num).toDouble()
                  : 0.0,
              'profile_pic': artisan['profile_pic'] ??
                            artisan['profile_picture'] ??
                            artisan['avatar'],
              'phone': artisan['phone'] ?? artisan['phone_number'],
            };
          }).cast<Map<String, dynamic>>().toList();
        }
      }

      setState(() {
        _searchResults = artisans;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching artisans: $e');
      if (!mounted) return;

      setState(() {
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to search artisans: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _inviteCollaborator() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedArtisanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an artisan to invite'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;

    // Parse job ID to int (job.id is a String)
    final jobApplicationId = int.tryParse(widget.job.id);
    if (jobApplicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid job ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<CollaborationBloc>().add(
      InviteCollaboratorEvent(
        jobApplicationId: jobApplicationId,
        collaboratorId: _selectedArtisanId!,
        paymentMethod: _paymentMethod,
        paymentAmount: amount,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollaborationBloc, CollaborationState>(
      listener: (context, state) {
        if (state is CollaborationInviteSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Collaboration invite sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        } else if (state is CollaborationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightPeach,
        appBar: AppBar(
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.responsivePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job info card
                  Container(
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
                          widget.job.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.job.category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Search artisans
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _searchArtisans,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search results
                  if (_searchResults.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final artisan = _searchResults[index];
                          final isSelected = _selectedArtisanId == artisan['id'];

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: AppColors.softPeach,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.orange.withOpacity(0.2),
                              child: Text(
                                artisan['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.brownHeader,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: Text(
                              artisan['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artisan['occupation'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                if (artisan['phone'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    artisan['phone'],
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
                            onTap: () {
                              setState(() {
                                _selectedArtisanId = artisan['id'];
                                _selectedArtisanName = artisan['name'];
                              });
                            },
                          );
                        },
                      ),
                    ),

                  if (_selectedArtisanId != null) ...[
                    const SizedBox(height: 24),

                    // Payment method
                    const Text(
                      'Payment Terms',
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
                      child: Column(
                        children: [
                          RadioListTile<PaymentMethod>(
                            title: const Text(
                              'Percentage of Job Payment',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text(
                              'e.g., 30% of total job payment',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: PaymentMethod.percentage,
                            groupValue: _paymentMethod,
                            activeColor: AppColors.orange,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<PaymentMethod>(
                            title: const Text(
                              'Fixed Amount',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text(
                              'Specific amount in Naira',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: PaymentMethod.fixed,
                            groupValue: _paymentMethod,
                            activeColor: AppColors.orange,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Amount field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: _paymentMethod == PaymentMethod.percentage
                            ? 'Percentage (%)'
                            : 'Amount (₦)',
                        hintText: _paymentMethod == PaymentMethod.percentage
                            ? 'e.g., 30'
                            : 'e.g., 50000',
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
                        if (_paymentMethod == PaymentMethod.percentage && amount > 100) {
                          return 'Percentage cannot exceed 100%';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Optional message
                    TextFormField(
                      controller: _messageController,
                      maxLines: 3,
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
                    ),

                    const SizedBox(height: 24),

                    // Send invite button
                    BlocBuilder<CollaborationBloc, CollaborationState>(
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
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

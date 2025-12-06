import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../account/presentation/bloc/account_bloc.dart';
import '../../../account/presentation/bloc/account_state.dart';
import '../../../account/presentation/bloc/account_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'invoices_page.dart';
import '../../domain/entities/invoice.dart';
import '../../data/datasources/invoice_remote_data_source.dart';
import '../../data/models/invoice_dashboard_model.dart';
import '../../../customers/presentation/pages/customers_page.dart';
import 'create_invoice_page.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/image_url.dart';

class InvoiceMenuPage extends StatefulWidget {
  const InvoiceMenuPage({super.key});

  @override
  State<InvoiceMenuPage> createState() => _InvoiceMenuPageState();
}

class _InvoiceMenuPageState extends State<InvoiceMenuPage> {
  InvoiceDashboardModel? _dashboard;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    // Ensure profile is loaded to personalize greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final accountState = context.read<AccountBloc>().state;
        if (accountState is! AccountProfileLoaded) {
          context.read<AccountBloc>().add(AccountLoadProfile());
        }
      } catch (_) {}
    });
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dataSource = GetIt.I<InvoiceRemoteDataSource>();
      final dashboard = await dataSource.getDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: context.lightPeachColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Reduced padding and size
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<AccountBloc, AccountState>(
                            builder: (context, accountState) {
                              String greeting = 'Hi Artisan';
                              if (accountState is AccountProfileLoaded) {
                                final name = accountState.profile.fullName;
                                if (name.isNotEmpty) greeting = 'Hi $name';
                              } else {
                                final authState = context.watch<AuthBloc>().state;
                                if (authState is AuthAuthenticated) {
                                  final user = authState.user;
                                  final full = (user.firstName + ' ' + user.lastName).trim();
                                  if (full.isNotEmpty) {
                                    greeting = 'Hi $full';
                                  } else if (user.firstName.isNotEmpty) {
                                    greeting = 'Hi ${user.firstName}';
                                  } else if (user.lastName.isNotEmpty) {
                                    greeting = 'Hi ${user.lastName}';
                                  } else if (user.phone.isNotEmpty) {
                                    greeting = 'Hi ${user.phone}';
                                  }
                                }
                              }
                              return Text(
                                greeting,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.brownHeaderColor,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Take a look for your last activity',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.search,
                              color: colorScheme.onSurfaceVariant, size: 20),
                          padding: AppSpacing.paddingSM,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.notifications_outlined,
                              color: colorScheme.onSurfaceVariant, size: 20),
                          padding: AppSpacing.paddingSM,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.spaceLG,

              // Top Icon Grid (4 icons)
              Row(
                children: [
                  Expanded(
                    child: _buildTopIcon(
                      context,
                      'Draft',
                      Icons.description_outlined,
                      context.primaryColor,
                      () => _navigateToInvoiceList(
                          context, InvoiceStatus.draft, 'Draft'),
                    ),
                  ),
                  Expanded(
                    child: _buildTopIcon(
                      context,
                      'Validated',
                      Icons.check_circle_outline,
                      context.primaryColor,
                      () => _navigateToInvoiceList(
                          context, InvoiceStatus.validated, 'Validated'),
                    ),
                  ),
                  Expanded(
                    child: _buildTopIcon(
                      context,
                      'Paid',
                      Icons.payments_outlined,
                      context.primaryColor,
                      () => _navigateToInvoiceList(
                          context, InvoiceStatus.paid, 'Paid'),
                    ),
                  ),
                  Expanded(
                    child: _buildTopIcon(
                      context,
                      'Customers',
                      Icons.people_outline,
                      context.primaryColor,
                      () => _navigateToCustomers(context),
                    ),
                  ),
                ],
              ),

              AppSpacing.spaceLG,

              // Earnings Balance Card - Reduced size
              Container(
                width: double.infinity,
                padding: context.responsivePadding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.primaryColor,
                      context.primaryColor.withValues(alpha: 0.8)
                    ],
                  ),
                  borderRadius: AppRadius.radiusLG,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earnings balance',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSpacing.spaceXS,
                    Text(
                      _loading
                          ? 'Loading...'
                          : 'NGN ${(_dashboard?.earningsBalance ?? 0).toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.spaceMD,
                    // Simple chart representation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildChartBar(20),
                        const SizedBox(width: 3),
                        _buildChartBar(30),
                        const SizedBox(width: 3),
                        _buildChartBar(18),
                        const SizedBox(width: 3),
                        _buildChartBar(35),
                        const SizedBox(width: 3),
                        _buildChartBar(25),
                        const SizedBox(width: 3),
                        _buildChartBar(40),
                        const SizedBox(width: 3),
                        _buildChartBar(32),
                        const SizedBox(width: 3),
                        _buildChartBar(22),
                        const SizedBox(width: 3),
                        _buildChartBar(28),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.spaceLG,

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total outstanding',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpacing.spaceSM,
                        Text(
                          _loading
                              ? 'Loading...'
                              : 'NGN ${(_dashboard?.totalOutstanding ?? 0).toStringAsFixed(0)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: context.brownHeaderColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.spaceXS,
                        Text(
                          _loading
                              ? 'Loading...'
                              : '${_dashboard?.validatedCount ?? 0} Waiting invoice${(_dashboard?.validatedCount ?? 0) == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paid this month',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpacing.spaceSM,
                        Text(
                          _loading
                              ? 'Loading...'
                              : 'NGN ${(_dashboard?.paidThisMonth ?? 0).toStringAsFixed(0)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: context.brownHeaderColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.spaceXS,
                        Text(
                          _loading
                              ? 'Loading...'
                              : '${_dashboard?.paidCount ?? 0} Paid invoice${(_dashboard?.paidCount ?? 0) == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppSpacing.spaceXL,

              // Watch tutorial section
              Container(
                padding: AppSpacing.paddingXL,
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: AppRadius.radiusXL,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Watch tutorial',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.brownHeaderColor,
                            ),
                          ),
                          AppSpacing.spaceXS,
                          Text(
                            'How to send on invoice in 1 minute',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.lightPeachColor,
                        borderRadius: AppRadius.radiusLG,
                      ),
                      child: Icon(
                        Icons.play_circle_outline,
                        color: context.primaryColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.spaceLG,

              // Frequently client section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frequently client',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.brownHeaderColor,
                    ),
                  ),
                  Text(
                    'See more',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              AppSpacing.spaceLG,

              SizedBox(
                height: 100,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_dashboard?.frequentCustomers.isEmpty ?? true)
                        ? Center(
                            child: Text(
                              'No frequent customers yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _dashboard!.frequentCustomers.length,
                            itemBuilder: (context, index) {
                              final customer =
                                  _dashboard!.frequentCustomers[index];
                              return _buildClientAvatar(
                                customer.customerName,
                                null, // No avatar URL from API
                              );
                            },
                          ),
              ),

              AppSpacing.spaceLG,

              // Recent invoice section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent invoice',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.brownHeaderColor,
                    ),
                  ),
                  Text(
                    'See more',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              AppSpacing.spaceLG,

              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_dashboard?.recentInvoices.isEmpty ?? true)
                      ? Container(
                          padding: context.responsivePadding,
                          decoration: BoxDecoration(
                            color: context.cardBackgroundColor,
                            borderRadius: AppRadius.radiusXL,
                          ),
                          child: Center(
                            child: Text(
                              'No recent invoices',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _dashboard!.recentInvoices.length.clamp(0, 3),
                          separatorBuilder: (context, index) => AppSpacing.spaceSM,
                          itemBuilder: (context, index) {
                            final invoice = _dashboard!.recentInvoices[index];
                            final entity = invoice.toEntity();
                            return Container(
                              padding: context.responsivePadding,
                              decoration: BoxDecoration(
                                color: context.cardBackgroundColor,
                                borderRadius: AppRadius.radiusXL,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadius.radiusLG,
                                      color: context.primaryColor.withValues(alpha: 0.2),
                                    ),
                                    child: Icon(
                                      Icons.receipt,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                  AppSpacing.spaceMD,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entity.clientName,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: context.brownHeaderColor,
                                          ),
                                        ),
                                        AppSpacing.spaceXS,
                                        Text(
                                          'Invoice #${entity.invoiceNumber}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        AppSpacing.spaceSM,
                                        Text(
                                          'NGN ${entity.total.toStringAsFixed(0)}',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: context.brownHeaderColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(entity.status)
                                              .withValues(alpha: 0.2),
                                          borderRadius: AppRadius.radiusMD,
                                        ),
                                        child: Text(
                                          _getStatusText(entity.status),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: _getStatusColor(entity.status),
                                          ),
                                        ),
                                      ),
                                      AppSpacing.spaceSM,
                                      Text(
                                        _formatDate(entity.issueDate),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

              AppSpacing.spaceXL,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.primaryColor,
        onPressed: () => _navigateToCreateInvoice(context),
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildTopIcon(
      BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.horizontalXS,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(
            color: context.subtleBorderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMD,
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.brownHeaderColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(double height) {
    return Builder(
      builder: (context) => Container(
        width: 6,
        height: height,
        decoration: BoxDecoration(
          color: context.colorScheme.onPrimary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildClientAvatar(String name, String? imageUrl) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusLG,
                  color: imageUrl == null
                      ? context.primaryColor.withValues(alpha: 0.2)
                      : null,
                  image: (() {
                    final fixed = sanitizeImageUrl(imageUrl);
                    return fixed.startsWith('http')
                        ? DecorationImage(
                            image: NetworkImage(fixed),
                            fit: BoxFit.cover,
                          )
                        : null;
                  })(),
                ),
                child: (() {
                  final valid = sanitizeImageUrl(imageUrl).startsWith('http');
                  return !valid;
                })()
                    ? Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.primaryColor,
                          ),
                        ),
                      )
                    : null,
              ),
              AppSpacing.spaceSM,
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.brownHeaderColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.validated:
        return Colors.orange;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.pending:
        return Colors.blue;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.validated:
        return 'Validated';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToInvoiceList(
    BuildContext context,
    InvoiceStatus status,
    String title,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InvoicesPage(
          status: status,
          title: title,
        ),
      ),
    );
  }

  void _navigateToCustomers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CustomersPage(),
      ),
    );
  }

  void _navigateToCreateInvoice(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateInvoicePage(
          mode: InvoiceMode.create,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'invoices_page.dart';
import '../../domain/entities/invoice.dart';
import '../../../customers/presentation/pages/customers_page.dart';
import 'create_invoice_page.dart';
import '../../../../core/utils/responsive.dart';

class InvoiceMenuPage extends StatelessWidget {
  const InvoiceMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPeach,
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
                          const Text(
                            'Hi Olivia',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brownHeader,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Take a look for your last activity',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
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
                          icon: const Icon(Icons.search,
                              color: Colors.grey, size: 20),
                          padding: AppSpacing.paddingSM,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_outlined,
                              color: Colors.grey, size: 20),
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
                      'Draft',
                      Icons.description_outlined,
                      AppColors.orange,
                      () => _navigateToInvoiceList(
                          context, InvoiceStatus.draft, 'Draft'),
                    ),
                  ),
                  Expanded(
                    child: _buildTopIcon(
                      'Validated',
                      Icons.check_circle_outline,
                      AppColors.orange,
                      () => _navigateToInvoiceList(
                          context, InvoiceStatus.validated, 'Validated'),
                    ),
                  ),
                  Expanded(
                    child: _buildTopIcon(
                      'Paid',
                      Icons.payments_outlined,
                      AppColors.orange,
                      () => _navigateToInvoiceList(
                          context, InvoiceStatus.paid, 'Paid'),
                    ),
                  ),
                  Expanded(
                    child: _buildTopIcon(
                      'Customers',
                      Icons.people_outline,
                      AppColors.orange,
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
                      AppColors.orange,
                      AppColors.orange.withOpacity(0.8)
                    ],
                  ),
                  borderRadius: AppRadius.radiusLG,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Earnings balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSpacing.spaceXS,
                    const Text(
                      'NGN 6,326',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpacing.spaceSM,
                        const Text(
                          'NGN 2,326',
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.brownHeader,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.spaceXS,
                        Text(
                          '1 Waiting invoice',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpacing.spaceSM,
                        const Text(
                          'NGN 4,326',
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.brownHeader,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.spaceXS,
                        Text(
                          '5 Paid invoice',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.radiusXL,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Watch tutorial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brownHeader,
                            ),
                          ),
                          AppSpacing.spaceXS,
                          Text(
                            'How to send on invoice in 1 minute',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lightPeach,
                        borderRadius: AppRadius.radiusLG,
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: AppColors.orange,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.spaceLG,

              // Frequently client section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frequently client',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownHeader,
                    ),
                  ),
                  Text(
                    'See more',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              AppSpacing.spaceLG,

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildClientAvatar('Cooper',
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
                    _buildClientAvatar('Wilson',
                        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
                    _buildClientAvatar('Jacob',
                        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150'),
                    _buildClientAvatar('Albert',
                        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150'),
                    _buildClientAvatar('Robert',
                        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150'),
                  ],
                ),
              ),

              AppSpacing.spaceLG,

              // Recent invoice section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent invoice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownHeader,
                    ),
                  ),
                  Text(
                    'See more',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              AppSpacing.spaceLG,

              Container(
                padding: context.responsivePadding,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.radiusXL,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.radiusLG,
                        image: const DecorationImage(
                          image: NetworkImage(
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    AppSpacing.spaceMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jane Cooper',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brownHeader,
                            ),
                          ),
                          AppSpacing.spaceXS,
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppSpacing.spaceSM,
                              const Text(
                                'Acme Corporation',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.spaceSM,
                          const Text(
                            'NGN 250',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brownHeader,
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
                            color: Colors.green.shade100,
                            borderRadius: AppRadius.radiusMD,
                          ),
                          child: Text(
                            'Paid',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        AppSpacing.spaceSM,
                        Text(
                          '10/06/2020',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.spaceXL,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.orange,
        onPressed: () => _navigateToCreateInvoice(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTopIcon(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.horizontalXS,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(
            color: AppColors.subtleBorder,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brownHeader,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(double height) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildClientAvatar(String name, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusLG,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          AppSpacing.spaceSM,
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.brownHeader,
            ),
          ),
        ],
      ),
    );
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

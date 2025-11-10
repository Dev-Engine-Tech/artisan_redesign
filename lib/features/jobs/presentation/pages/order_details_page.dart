import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/utils/responsive.dart';

class OrderDetailsPage extends StatefulWidget {
  final Job job;

  const OrderDetailsPage({required this.job, super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final TextEditingController _deliveryChargeController =
      TextEditingController();

  @override
  void dispose() {
    _deliveryChargeController.dispose();
    super.dispose();
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.softPeach,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.brownHeader)),
    );
  }

  Widget _agreementsCard() {
    // These values are placeholders to match the design. In a real app
    // they'd be computed from the job/order data or API.
    const agreedPayment = 'NGN 20,000.00';
    const deliveryFee = 'NGN 10,000.00';
    const serviceCharge = 'NGN 4,000.00';
    const wht = 'NGN 4,000.00';
    const amountYouGet = 'NGN 2,000.00';

    return Container(
      margin: AppSpacing.verticalMD,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Agreements',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.spaceMD,
          _agreementRow('Agreed Payment:', agreedPayment),
          AppSpacing.spaceSM,
          _agreementRow('Delivery Fee:', deliveryFee),
          AppSpacing.spaceSM,
          _agreementRow('Service Charge:', serviceCharge),
          AppSpacing.spaceSM,
          _agreementRow('WHT (2%):', wht),
          AppSpacing.spaceSM,
          _agreementRow('Amount you will get:', amountYouGet),
          AppSpacing.spaceMD,
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.softPeach,
              borderRadius: AppRadius.radiusMD,
            ),
            child: const Text(
              'Note:\nWhatever the amount you have here needs to be agreed by the client before payments can be made.',
              style: TextStyle(color: AppColors.brownHeader),
            ),
          ),
        ],
      ),
    );
  }

  Widget _agreementRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text('Project Request',
            style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: context.maxContentWidth),
            child: ListView(
              padding: context.responsivePadding,
              children: [
                // Buyer info header (rounded card with avatar + view profile)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: AppColors.softBorder),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      AppSpacing.spaceXS,
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person,
                            color: AppColors.brownHeader),
                      ),
                      AppSpacing.spaceMD,
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Uwak Daniel',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                            AppSpacing.spaceXS,
                            Text('@danuwk',
                                style: TextStyle(color: Colors.black45)),
                          ],
                        ),
                      ),
                      PrimaryButton(
                        text: 'View Profile',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Large image banner
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: job.thumbnailUrl.isNotEmpty
                      ? Image.network(sanitizeImageUrl(job.thumbnailUrl),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              height: 200,
                              color: Colors.black12,
                              child: const Icon(Icons.image_not_supported)))
                      : Container(
                          width: double.infinity,
                          height: 200,
                          color: AppColors.softPink,
                          child: const Center(
                              child: Icon(Icons.home_repair_service_outlined,
                                  size: 56, color: AppColors.orange)),
                        ),
                ),

                const SizedBox(height: 14),

                // Title row + price badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text('Abbys Furniture',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.black45)),
                          ]),
                    ),
                    AppSpacing.spaceSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColors.softPeach,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Price Range',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.black45)),
                          const SizedBox(height: 6),
                          Text('₦${job.minBudget}k - ₦${job.maxBudget}k',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87)),
                        ],
                      ),
                    )
                  ],
                ),

                AppSpacing.spaceMD,

                // Delivery Option (address pill)
                Text('Delivery Option',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                AppSpacing.spaceSM,
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.softPeach,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                      '15a, oladipo diya street, Lekki phase 1 Ido LGA, Lagos state.'),
                ),

                AppSpacing.spaceMD,

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.softBorder),
                  ),
                  child: Text('Duration: ${job.duration}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.brownHeader)),
                ),

                const SizedBox(height: 18),

                // Description card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: AppColors.softBorder),
                  ),
                  padding: AppSpacing.paddingLG,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(
                          job.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                      ]),
                ),

                const SizedBox(height: 18),

                // Add delivery charge input
                Text('Add delivery charge',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                AppSpacing.spaceSM,
                TextField(
                  controller: _deliveryChargeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusLG,
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                ),

                AppSpacing.spaceMD,

                _agreementsCard(),

                AppSpacing.spaceSM,

                // Accept / Reject
                PrimaryButton(
                  text: 'Accept Request',
                  onPressed: () {
                    final amount = _deliveryChargeController.text.trim();
                    // For now just navigate to a summary screen with the values;
                    // in a real app this would call a service or show a confirmation.
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => OrderSummaryPage(
                        job: job,
                        deliveryFee: amount.isEmpty ? null : amount,
                      ),
                    ));
                  },
                ),

                AppSpacing.spaceMD,

                OutlinedAppButton(
                  text: 'Reject Request',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request rejected')));
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderSummaryPage extends StatelessWidget {
  final Job job;
  final String? deliveryFee;

  const OrderSummaryPage({required this.job, super.key, this.deliveryFee});

  @override
  Widget build(BuildContext context) {
    // compute placeholder totals
    final agreedPayment = 20000.00;
    final delivery = deliveryFee != null && deliveryFee!.isNotEmpty
        ? double.tryParse(deliveryFee!) ?? 0.0
        : 10000.0;
    final serviceCharge = 4000.0;
    final wht = 0.02 * agreedPayment;
    final amountYouGet = agreedPayment - (serviceCharge + wht + delivery);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text('Confirm Order',
            style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: context.maxContentWidth),
            child: ListView(
              padding: context.responsivePadding,
              children: [
                // brief summary
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: AppColors.softBorder),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(job.category,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black45)),
                        AppSpacing.spaceSM,
                        Text(job.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ]),
                ),

                AppSpacing.spaceMD,
                // Agreements block
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Agreements',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        AppSpacing.spaceSM,
                        _summaryRow(context, 'Agreed Payment',
                            'NGN ${agreedPayment.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _summaryRow(context, 'Delivery Fee',
                            'NGN ${delivery.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _summaryRow(context, 'Service Charge',
                            'NGN ${serviceCharge.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _summaryRow(context, 'WHT (2%)',
                            'NGN ${wht.toStringAsFixed(2)}'),
                        AppSpacing.spaceMD,
                        _summaryRow(context, 'Amount you will get',
                            'NGN ${amountYouGet.toStringAsFixed(2)}'),
                      ]),
                ),

                const SizedBox(height: 18),
                PrimaryButton(
                  text: 'Submit',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order confirmed')));
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                AppSpacing.spaceMD,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

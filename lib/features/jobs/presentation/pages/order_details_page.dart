import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';

class OrderDetailsPage extends StatefulWidget {
  final Job job;

  const OrderDetailsPage({super.key, required this.job});

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
        borderRadius: BorderRadius.circular(12),
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
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 12),
          _agreementRow('Agreed Payment:', agreedPayment),
          const SizedBox(height: 8),
          _agreementRow('Delivery Fee:', deliveryFee),
          const SizedBox(height: 8),
          _agreementRow('Service Charge:', serviceCharge),
          const SizedBox(height: 8),
          _agreementRow('WHT (2%):', wht),
          const SizedBox(height: 8),
          _agreementRow('Amount you will get:', amountYouGet),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.softPeach,
              borderRadius: BorderRadius.circular(8),
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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Buyer info header (rounded card with avatar + view profile)
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    child:
                        const Icon(Icons.person, color: AppColors.brownHeader),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Uwak Daniel',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('@danuwk',
                            style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF213447),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Profile'),
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
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

            const SizedBox(height: 12),

            // Delivery Option (address pill)
            Text('Delivery Option',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softPeach,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                  '15a, oladipo diya street, Lekki phase 1 Ido LGA, Lagos state.'),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            TextField(
              controller: _deliveryChargeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Amount',
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            _agreementsCard(),

            const SizedBox(height: 8),

            // Accept / Reject
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9A4B20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child:
                  const Text('Accept Request', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request rejected')));
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.softPink,
                foregroundColor: AppColors.brownHeader,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child:
                  const Text('Reject Request', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class OrderSummaryPage extends StatelessWidget {
  final Job job;
  final String? deliveryFee;

  const OrderSummaryPage({super.key, required this.job, this.deliveryFee});

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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // brief summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 8),
                    Text(job.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            ),

            const SizedBox(height: 12),
            // Agreements block
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agreements',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _summaryRow(context, 'Agreed Payment',
                        'NGN ${agreedPayment.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _summaryRow(context, 'Delivery Fee',
                        'NGN ${delivery.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _summaryRow(context, 'Service Charge',
                        'NGN ${serviceCharge.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _summaryRow(
                        context, 'WHT (2%)', 'NGN ${wht.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _summaryRow(context, 'Amount you will get',
                        'NGN ${amountYouGet.toStringAsFixed(2)}'),
                  ]),
            ),

            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order confirmed')));
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9A4B20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
          ],
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

import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';

/// Step 2 of upload catalogue: Pricing & preferences form
///
/// Collects:
/// - Price range (min/max)
/// - Project timeline
/// - Preferred skills
/// - Materials preference
/// - Instant selling options (brand, condition, warranty, delivery)
class UploadCatalogueStep2 extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final String? timeline;
  final List<String> timelines;
  final Set<String> selectedSkills;
  final List<String> skills;
  final bool materialsIncluded;
  final bool instantSelling;
  final TextEditingController brandController;
  final String? condition;
  final List<String> conditions;
  final TextEditingController salesCategoryController;
  final bool warranty;
  final bool delivery;
  final bool hotSale;
  final TextEditingController? discountController;
  final String? badge;
  final List<String>? badges;
  final ValueChanged<bool>? onHotSaleChanged;
  final ValueChanged<String?>? onBadgeChanged;
  final ValueChanged<String?> onTimelineChanged;
  final ValueChanged<String> onSkillToggled;
  final ValueChanged<bool> onMaterialsChanged;
  final ValueChanged<bool> onInstantSellingChanged;
  final ValueChanged<String?> onConditionChanged;
  final ValueChanged<bool> onWarrantyChanged;
  final ValueChanged<bool> onDeliveryChanged;
  final VoidCallback onNext;

  const UploadCatalogueStep2({
    required this.minPriceController,
    required this.maxPriceController,
    required this.timeline,
    required this.timelines,
    required this.selectedSkills,
    required this.skills,
    required this.materialsIncluded,
    required this.instantSelling,
    required this.brandController,
    required this.condition,
    required this.conditions,
    required this.salesCategoryController,
    required this.warranty,
    required this.delivery,
    this.hotSale = false,
    this.discountController,
    this.badge,
    this.badges,
    this.onHotSaleChanged,
    this.onBadgeChanged,
    required this.onTimelineChanged,
    required this.onSkillToggled,
    required this.onMaterialsChanged,
    required this.onInstantSellingChanged,
    required this.onConditionChanged,
    required this.onWarrantyChanged,
    required this.onDeliveryChanged,
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        AppSpacing.spaceSM,
        const Text('Price Range',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceMD,
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'NGN ',
                  filled: true,
                  fillColor: context.cardBackgroundColor,
                  hintText: '100,000',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
            ),
            AppSpacing.spaceMD,
            Expanded(
              child: TextField(
                controller: maxPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'NGN ',
                  filled: true,
                  fillColor: context.cardBackgroundColor,
                  hintText: '100,000',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Promotion', style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Hot sale'),
                value: hotSale,
                onChanged: onHotSaleChanged,
              ),
              AppSpacing.spaceSM,
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '',
                  suffixText: '%',
                  filled: true,
                  fillColor: context.cardBackgroundColor,
                  hintText: 'Discount percent (0 - 99.99)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
              AppSpacing.spaceSM,
              DropdownButtonFormField<String>(
                value: badge,
                items: (badges ?? const ['', 'new', 'hot', 'sale'])
                    .map((b) => DropdownMenuItem(
                        value: b, child: Text(b.isEmpty ? 'None' : b)))
                    .toList(),
                onChanged: onBadgeChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.cardBackgroundColor,
                  hintText: 'Badge',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Product Timeline',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        DropdownButtonFormField<String>(
          value: timeline,
          items: timelines
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: onTimelineChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.cardBackgroundColor,
            hintText: 'Select preferable timeline',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Select preferred skill',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(10)),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) {
              final selected = selectedSkills.contains(s);
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (v) => onSkillToggled(s),
                selectedColor: context.brownHeaderColor,
                backgroundColor: context.colorScheme.surface,
                labelStyle: TextStyle(
                    color: selected
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onSurface),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Materials Preference',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              // ignore: deprecated_member_use
              RadioListTile<bool>(
                value: true,
                // ignore: deprecated_member_use
                groupValue: materialsIncluded,
                // ignore: deprecated_member_use
                onChanged: (v) => onMaterialsChanged(v ?? true),
                title: const Text(
                    'Include a preliminary list of materials (names, sizes, quantities) with your application.'),
              ),
              // ignore: deprecated_member_use
              RadioListTile<bool>(
                value: false,
                // ignore: deprecated_member_use
                groupValue: materialsIncluded,
                // ignore: deprecated_member_use
                onChanged: (v) => onMaterialsChanged(v ?? false),
                title: const Text('No materials are needed for this project.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Instant Selling',
            style: TextStyle(fontWeight: FontWeight.w600)),
        AppSpacing.spaceSM,
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(10)),
          child: SwitchListTile(
            title: const Text('Enable instant selling'),
            subtitle: const Text('Allow buyers to purchase this item directly'),
            value: instantSelling,
            onChanged: onInstantSellingChanged,
          ),
        ),
        if (instantSelling) ...[
          const SizedBox(height: 18),
          const Text('Brand', style: TextStyle(fontWeight: FontWeight.w600)),
          AppSpacing.spaceSM,
          TextField(
            controller: brandController,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.cardBackgroundColor,
              hintText: 'Enter brand name',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Condition',
              style: TextStyle(fontWeight: FontWeight.w600)),
          AppSpacing.spaceSM,
          DropdownButtonFormField<String>(
            value: condition,
            items: conditions
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: onConditionChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.cardBackgroundColor,
              hintText: 'Select item condition',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Sales Category',
              style: TextStyle(fontWeight: FontWeight.w600)),
          AppSpacing.spaceSM,
          TextField(
            controller: salesCategoryController,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.cardBackgroundColor,
              hintText: 'e.g., Electronics, Furniture, etc.',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Additional Options',
              style: TextStyle(fontWeight: FontWeight.w600)),
          AppSpacing.spaceSM,
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text('Warranty included'),
                  value: warranty,
                  onChanged: (v) => onWarrantyChanged(v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('Delivery available'),
                  value: delivery,
                  onChanged: (v) => onDeliveryChanged(v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ],
        AppSpacing.spaceLG,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: PrimaryButton(
            text: 'Proceed',
            onPressed: onNext,
          ),
        ),
        AppSpacing.spaceMD,
      ],
    );
  }
}

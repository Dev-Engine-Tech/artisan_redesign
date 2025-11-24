import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import 'business_settings_widgets.dart' show ColorPickerDialog;

class BrandColor {
  final String name;
  final String hex; // in #RRGGBB
  const BrandColor(this.name, this.hex);
}

const List<BrandColor> kPopularBrandColors = [
  BrandColor('Google Blue', '#4285F4'),
  BrandColor('Google Red', '#DB4437'),
  BrandColor('Google Yellow', '#F4B400'),
  BrandColor('Google Green', '#0F9D58'),
  BrandColor('Facebook', '#1877F2'),
  BrandColor('LinkedIn', '#0A66C2'),
  BrandColor('Twitter/X', '#000000'),
  BrandColor('Instagram', '#E1306C'),
  BrandColor('WhatsApp', '#25D366'),
  BrandColor('YouTube', '#FF0000'),
  BrandColor('Slack', '#611F69'),
  BrandColor('Stripe', '#635BFF'),
  BrandColor('Shopify', '#96BF48'),
  BrandColor('GitHub', '#24292E'),
  BrandColor('Airbnb', '#FF5A5F'),
  BrandColor('Spotify', '#1DB954'),
  BrandColor('Amazon', '#FF9900'),
  BrandColor('Microsoft', '#0078D4'),
  BrandColor('Apple Gray', '#A3AAAE'),
  BrandColor('Netflix', '#E50914'),
];

class BrandColorPaletteDialog extends StatelessWidget {
  final String title;
  final String? initialColor;
  const BrandColorPaletteDialog(
      {super.key, required this.title, this.initialColor});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.6; // ensure enough room to scroll
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        height: maxHeight,
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: kPopularBrandColors.length,
                itemBuilder: (context, index) {
                  final bc = kPopularBrandColors[index];
                  final color = _parseHex(bc.hex);
                  final isSelected = bc.hex.toUpperCase() ==
                      (initialColor ?? '').toUpperCase();
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(bc.hex),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.orange
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            bc.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final hex = await showDialog<String>(
                    context: context,
                    builder: (ctx) => ColorPickerDialog(
                        title: 'Custom HEX Color', initialColor: initialColor),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop(hex);
                  }
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Custom HEX...'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  /// Convenience bottom sheet picker that returns a selected HEX string.
  Future<String?> showBrandColorPalette(BuildContext context,
      {required String title, String? initialColor}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: kPopularBrandColors.length,
                  itemBuilder: (context, index) {
                    final bc = kPopularBrandColors[index];
                    final color = _parseHex(bc.hex);
                    final isSelected = bc.hex.toUpperCase() ==
                        (initialColor ?? '').toUpperCase();
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(bc.hex),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.orange
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black12),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              bc.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final hex = await showDialog<String>(
                          context: context,
                          builder: (ctx) => ColorPickerDialog(
                              title: 'Custom HEX Color',
                              initialColor: initialColor),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop(hex);
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Custom HEX...'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Tab chip with selection indicator for home page
class HomeTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const HomeTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              padding: AppSpacing.horizontalSM,
              decoration: BoxDecoration(
                color: selected
                    ? context.softPinkColor
                    : context.cardBackgroundColor,
                borderRadius: AppRadius.radiusXXXL,
              ),
              child: Row(
                children: [
                  Text(label,
                      style: TextStyle(
                          color: context.brownHeaderColor,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: selected ? 13 : 12)),
                  AppSpacing.spaceXS,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: AppRadius.radiusLG),
                    child: Text('56',
                        style: TextStyle(
                            fontSize: 10, color: context.brownHeaderColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: selected ? 3 : 0,
              width: selected ? 36 : 0,
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

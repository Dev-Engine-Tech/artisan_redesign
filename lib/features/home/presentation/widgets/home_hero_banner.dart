import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Hero banner carousel for home page
class HomeHeroBanner extends StatelessWidget {
  final PageController controller;
  final List<Map<String, String>> heroItems;

  const HomeHeroBanner({
    required this.controller,
    required this.heroItems,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: controller,
        itemCount: heroItems.length,
        itemBuilder: (context, index) {
          final data = heroItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(14)),
              padding: AppSpacing.paddingLG,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            data['title']!,
                            style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppSpacing.spaceSM,
                        Flexible(
                          child: Text(
                            data['subtitle']!,
                            style: TextStyle(
                                color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withValues(alpha: 0.24),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(AppRadius.lg)))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

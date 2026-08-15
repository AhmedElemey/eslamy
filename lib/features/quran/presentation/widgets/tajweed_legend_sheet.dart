import 'package:flutter/material.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../data/tajweed_rules.dart';

/// Opens the full Tajweed color legend as a bottom sheet.
void showTajweedLegendSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _TajweedLegendSheet(),
  );
}

class _TajweedLegendSheet extends StatelessWidget {
  const _TajweedLegendSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rules = tajweedRules.values.toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tajweedLegendTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.tajweedLegendSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rules.length,
                separatorBuilder: (_, __) => const Divider(height: 20),
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  return Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: rule.colorFor(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rule.englishName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        rule.arabicName,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

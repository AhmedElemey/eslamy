import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../core/localization/error_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/models/azkar_models.dart';
import '../controllers/azkar_providers.dart';

class AzkarCategoryDetailPage extends ConsumerWidget {
  const AzkarCategoryDetailPage({super.key, required this.category});

  final AzkarCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(azkarItemsProvider(category.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          localizedAzkarCategoryName(context.l10n, category.id, category.name),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.couldNotLoadSectionWithError(
                    localizedError(context.l10n, e),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (items) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _AzkarItemCard(item: items[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _AzkarItemCard extends StatefulWidget {
  const _AzkarItemCard({required this.item});

  final AzkarItem item;

  @override
  State<_AzkarItemCard> createState() => _AzkarItemCardState();
}

class _AzkarItemCardState extends State<_AzkarItemCard> {
  int _done = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final target = item.repeat;
    final complete = _done >= target;

    return GlassCard(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.title.isNotEmpty)
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          if (item.title.isNotEmpty) const SizedBox(height: 8),
          Text(
            item.arabic,
            textDirection: TextDirection.rtl,
            style: AppTypography.naskh(
              size: 22,
              weight: FontWeight.w600,
              color: AppColors.ayahText(context),
              height: 1.8,
            ),
          ),
          if (item.translation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.translation,
              style: TextStyle(color: AppColors.mutedText(context), fontSize: 15, height: 1.5),
            ),
          ],
          if (item.source.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.source,
              style: TextStyle(fontSize: 12, color: AppColors.mutedText(context)),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (target > 1)
                Expanded(
                  child: FilledButton(
                    onPressed: complete
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            setState(() => _done++);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: complete
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                    child: Text('$_done / $target'),
                  ),
                )
              else
                const Spacer(),
              IconButton(
                icon: Icon(Icons.share_outlined, size: 20, color: AppColors.mutedText(context)),
                onPressed: () => Share.share('${item.arabic}\n\n${item.translation}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

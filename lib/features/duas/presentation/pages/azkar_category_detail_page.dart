import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
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
      appBar: AppBar(title: Text(category.name)),
      body: AppBackground(
        child: SafeArea(
          child: itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.couldNotLoadSectionWithError(e.toString()),
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
            style: const TextStyle(fontSize: 20, height: 1.6, fontWeight: FontWeight.w600),
          ),
          if (item.translation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(item.translation, style: const TextStyle(color: AppColors.muted)),
          ],
          if (item.source.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.source,
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (target > 1)
                GestureDetector(
                  onTap: complete
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          setState(() => _done++);
                        },
                  child: Chip(
                    label: Text('$_done / $target'),
                    backgroundColor: complete
                        ? Colors.green.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: complete ? Colors.green : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.muted),
                onPressed: () => Share.share('${item.arabic}\n\n${item.translation}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

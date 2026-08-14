import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../data/models/azkar_models.dart';
import '../controllers/azkar_providers.dart';
import 'azkar_category_detail_page.dart';

class AzkarCategoriesPage extends ConsumerWidget {
  const AzkarCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(azkarCategoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(context.l10n.duasAzkarTitle)),
      body: AppBackground(
        child: SafeArea(
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.couldNotLoadAzkarWithError(e.toString()),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (categories) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final category = categories[i];
                return _CategoryTile(category: category);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final AzkarCategory category;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.violet]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 20),
        ),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(category.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AzkarCategoryDetailPage(category: category),
            ),
          );
        },
      ),
    );
  }
}

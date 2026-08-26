import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/error_localizer.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/number_seal.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/list_error_view.dart';
import '../../../quran/presentation/controllers/quran_providers.dart';
import '../../data/models/azkar_models.dart';
import '../controllers/azkar_providers.dart';
import 'azkar_category_detail_page.dart';

class AzkarCategoriesPage extends ConsumerWidget {
  const AzkarCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(azkarCategoriesProvider);
    // Reserve room below the list for the global mini player when something
    // is loaded, so it doesn't clip the last category.
    final miniPlayerActive =
        ref.watch(currentMediaItemProvider).valueOrNull != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(context.l10n.duasAzkarTitle)),
      body: AppBackground(
        child: SafeArea(
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, _) => ListErrorView(
                  message: context.l10n.couldNotLoadAzkarWithError(
                    localizedError(context.l10n, e),
                  ),
                  onRetry: () => ref.invalidate(azkarCategoriesProvider),
                ),
            data:
                (categories) => ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    miniPlayerActive ? 190 : 16,
                  ),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final category = categories[i];
                    return _CategoryTile(category: category, index: i);
                  },
                ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.index});

  final AzkarCategory category;
  final int index;

  static const _icons = [
    Icons.wb_twilight_outlined,
    Icons.nights_stay_outlined,
    Icons.mosque_outlined,
    Icons.wb_sunny_outlined,
    Icons.bedtime_outlined,
    Icons.menu_book_outlined,
    Icons.favorite_outline,
    Icons.home_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final icon = _icons[index % _icons.length];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline(context)),
      ),
      child: ListTile(
        leading: IconSeal(icon: icon),
        title: Text(
          localizedAzkarCategoryName(context.l10n, category.id, category.name),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          localizedAzkarCategoryDescription(
            context.l10n,
            category.id,
            category.description,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(chevronFor(context)),
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

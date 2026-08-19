import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/error_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/quran_providers.dart';

/// Compact button showing the currently-selected translation language;
/// tapping opens a searchable picker over all editions the API exposes.
class TranslationSelectionWidget extends ConsumerWidget {
  const TranslationSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTranslationProvider);

    return OutlinedButton.icon(
      onPressed:
          () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const _TranslationSelectionSheet(),
          ),
      icon: const Icon(Icons.translate_rounded, size: 18),
      label: Text(selected.englishName),
    );
  }
}

class _TranslationSelectionSheet extends ConsumerStatefulWidget {
  const _TranslationSelectionSheet();

  @override
  ConsumerState<_TranslationSelectionSheet> createState() =>
      _TranslationSelectionSheetState();
}

class _TranslationSelectionSheetState
    extends ConsumerState<_TranslationSelectionSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editionsAsync = ref.watch(translationEditionsProvider);
    final selected = ref.watch(selectedTranslationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.chooseTranslationTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: context.l10n.searchLanguageHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: editionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, _) => Center(
                    child: Text(
                      context.l10n.couldNotLoadLanguagesWithError(
                        localizedError(context.l10n, e),
                      ),
                    ),
                  ),
              data: (editions) {
                final filtered =
                    _query.isEmpty
                        ? editions
                        : editions
                            .where(
                              (e) =>
                                  e.englishName.toLowerCase().contains(
                                    _query,
                                  ) ||
                                  e.language.toLowerCase().contains(_query),
                            )
                            .toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final edition = filtered[i];
                    final isSelected =
                        edition.identifier == selected.identifier;
                    return ListTile(
                      title: Text(
                        edition.englishName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : Colors.black,
                        ),
                      ),
                      subtitle: Text(edition.language.toUpperCase()),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                              : null,
                      onTap: () async {
                        await ref
                            .read(selectedTranslationProvider.notifier)
                            .select(edition);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

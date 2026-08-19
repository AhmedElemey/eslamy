import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/number_seal.dart';
import '../../service/quran_audio_service.dart';
import '../../models/quran_models.dart';
import '../controllers/quran_providers.dart';
import 'reciter_avatar.dart';

class ReciterSelectionWidget extends ConsumerWidget {
  const ReciterSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(selectedReciterProvider);
    final heading = AppColors.heading(context);
    final muted = AppColors.mutedText(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: GlassCard(
        borderRadius: 16,
        onTap: () => _showReciterSelectionDialog(context, ref),
        child: Row(
          children: [
            selectedReciter == null
                ? const IconSeal(icon: Icons.record_voice_over)
                : ReciterAvatar(
                  reciterId: selectedReciter.id,
                  name: selectedReciter.name,
                ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.quranReciterLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedReciter == null
                        ? context.l10n.selectReciterPlaceholder
                        : localizedReciterName(
                          context: context,
                          arabicName: selectedReciter.arabicName,
                          englishName: selectedReciter.name,
                        ),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: heading,
                    ),
                  ),
                  if (selectedReciter != null && !isArabicLocale(context))
                    Text(
                      selectedReciter.arabicName,
                      style: TextStyle(fontSize: 12, color: muted),
                      textDirection: TextDirection.rtl,
                    ),
                ],
              ),
            ),
            Icon(Icons.expand_more_rounded, color: muted),
          ],
        ),
      ),
    );
  }

  void _showReciterSelectionDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReciterSelectionDialog(),
    );
  }
}

class ReciterSelectionDialog extends ConsumerStatefulWidget {
  const ReciterSelectionDialog({super.key});

  @override
  ConsumerState<ReciterSelectionDialog> createState() =>
      _ReciterSelectionDialogState();
}

class _ReciterSelectionDialogState
    extends ConsumerState<ReciterSelectionDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedReciter = ref.watch(selectedReciterProvider);
    final allReciters = QuranAudioService.getAllReciters();
    final query = _query.trim().toLowerCase();
    final filteredReciters =
        query.isEmpty
            ? allReciters
            : allReciters
                .where(
                  (reciter) =>
                      reciter['englishName']!.toLowerCase().contains(query) ||
                      reciter['arabicName']!.contains(_query.trim()),
                )
                .toList();
    final heading = AppColors.heading(context);
    final muted = AppColors.mutedText(context);

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
              color: AppColors.hairline(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const IconSeal(icon: Icons.record_voice_over),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.chooseReciterTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: heading,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: muted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: context.l10n.searchReciterHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    _query.isEmpty
                        ? null
                        : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
              ),
            ),
          ),
          Expanded(
            child:
                filteredReciters.isEmpty
                    ? Center(
                      child: Text(
                        context.l10n.noRecitersFound,
                        style: TextStyle(color: muted, fontSize: 14),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredReciters.length,
                      itemBuilder: (context, index) {
                        final reciter = filteredReciters[index];
                        final reciterModel = Reciter(
                          id: int.parse(reciter['id']!),
                          name: reciter['englishName']!,
                          arabicName: reciter['arabicName']!,
                          relativePath: reciter['key']!,
                        );
                        final isSelected =
                            selectedReciter?.id == reciterModel.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.pageBackground(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.hairline(context),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: ReciterAvatar(
                              reciterId: reciterModel.id,
                              name: reciterModel.name,
                            ),
                            title: Text(
                              localizedReciterName(
                                context: context,
                                arabicName: reciter['arabicName']!,
                                englishName: reciter['englishName']!,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? AppColors.primaryOnBg(context)
                                        : heading,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                if (!isArabicLocale(context))
                                  Text(
                                    reciter['arabicName']!,
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 13,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  localizedReciterStyle(
                                    context.l10n,
                                    reciter['style']!,
                                  ),
                                  style: TextStyle(color: muted, fontSize: 12),
                                ),
                              ],
                            ),
                            trailing:
                                isSelected
                                    ? Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryOnBg(context),
                                      size: 24,
                                    )
                                    : null,
                            onTap: () async {
                              await ref
                                  .read(selectedReciterProvider.notifier)
                                  .setSelectedReciter(reciterModel);
                              if (context.mounted) Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../service/quran_audio_service.dart';
import '../../models/quran_models.dart';
import '../controllers/quran_providers.dart';

class ReciterSelectionWidget extends ConsumerWidget {
  const ReciterSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primary = AppColors.primary;
    const textMuted = AppColors.muted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.record_voice_over,
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Quran Reciter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final selectedReciter = ref.watch(selectedReciterProvider);

              return GestureDetector(
                onTap: () => _showReciterSelectionDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedReciter?.name ?? 'Select Reciter',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            if (selectedReciter != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                selectedReciter.arabicName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Active for Audio',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.volume_up,
                                    size: 12,
                                    color: primary,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: textMuted, size: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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

class ReciterSelectionDialog extends ConsumerWidget {
  const ReciterSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primary = AppColors.primary;
    const textMuted = AppColors.muted;
    final selectedReciter = ref.watch(selectedReciterProvider);
    final allReciters = QuranAudioService.getAllReciters();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.record_voice_over,
                    color: primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Choose Reciter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: textMuted),
                ),
              ],
            ),
          ),

          // Reciters list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: allReciters.length,
              itemBuilder: (context, index) {
                final reciter = allReciters[index];
                final reciterModel = Reciter(
                  id: int.parse(reciter['id']!),
                  name: reciter['englishName']!,
                  arabicName: reciter['arabicName']!,
                  relativePath: reciter['key']!,
                );

                final isSelected = selectedReciter?.id == reciterModel.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? primary.withOpacity(0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primary : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          reciter['id']!,
                          style: TextStyle(
                            color:
                                isSelected ? AppColors.white : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      reciter['englishName']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primary : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          reciter['arabicName']!,
                          style: TextStyle(color: textMuted, fontSize: 13),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reciter['style']!,
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing:
                        isSelected
                            ? const Icon(
                              Icons.check_circle,
                              color: primary,
                              size: 24,
                            )
                            : null,
                    onTap: () async {
                      await ref
                          .read(selectedReciterProvider.notifier)
                          .setSelectedReciter(reciterModel);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

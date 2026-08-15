import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ring_progress_painter.dart';
import '../../models/dhikr_preset.dart';
import '../controllers/tasbih_providers.dart';

class TasbihPage extends ConsumerWidget {
  const TasbihPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbihProvider);
    final notifier = ref.read(tasbihProvider.notifier);
    final reached = state.count >= state.preset.target;
    final l10n = context.l10n;
    final progress =
        state.preset.target == 0
            ? 0.0
            : (state.count / state.preset.target).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.tasbihCounterTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.resetTooltip,
            onPressed: notifier.reset,
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dhikrPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final preset = dhikrPresets[i];
                    final selected = preset.id == state.preset.id;
                    return ChoiceChip(
                      label: Text(preset.englishName),
                      selected: selected,
                      onSelected: (_) => notifier.selectPreset(preset),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color:
                            selected
                                ? Colors.white
                                : AppColors.heading(context),
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.preset.arabic,
                        textDirection: TextDirection.rtl,
                        style: AppTypography.naskh(
                          size: 34,
                          weight: FontWeight.w700,
                          color: AppColors.heading(context),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          notifier.increment();
                        },
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: CustomPaint(
                            painter: RingProgressPainter(
                              progress: progress,
                              trackColor: AppColors.primary.withValues(
                                alpha: 0.18,
                              ),
                              fillColor:
                                  reached
                                      ? AppColors.success
                                      : AppColors.primary,
                            ),
                            child: Center(
                              child: Text(
                                '${state.count}',
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        reached
                            ? l10n.targetReached
                            : l10n.targetLabel(state.preset.target),
                        style: TextStyle(
                          color:
                              reached
                                  ? AppColors.success
                                  : AppColors.mutedText(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: GlassCard(
                  borderRadius: 20,
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        color: AppColors.mutedText(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.tapCircleHint,
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

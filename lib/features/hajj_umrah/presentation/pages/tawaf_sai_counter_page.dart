import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ring_progress_painter.dart';
import '../../data/hajj_umrah_content.dart';
import '../controllers/tawaf_sai_counter_provider.dart';

class TawafSaiCounterPage extends ConsumerWidget {
  const TawafSaiCounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(tawafSaiCounterProvider);
    final notifier = ref.read(tawafSaiCounterProvider.notifier);
    final reached = state.count >= tawafSaiTarget;
    final progress = state.count / tawafSaiTarget;
    final isTawaf = state.mode == TawafSaiMode.tawaf;
    final dua = duaById(isTawaf ? 'between_rukns' : 'sai_running_dua');

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.tawafSaiCounterTitle),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<TawafSaiMode>(
                  segments: [
                    ButtonSegment(
                      value: TawafSaiMode.tawaf,
                      label: Text(l10n.tawafModeLabel),
                    ),
                    ButtonSegment(
                      value: TawafSaiMode.sai,
                      label: Text(l10n.saiModeLabel),
                    ),
                  ],
                  selected: {state.mode},
                  onSelectionChanged:
                      (selection) => notifier.selectMode(selection.first),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isTawaf ? l10n.tawafModeLabel : l10n.saiModeLabel,
                        style: AppTypography.naskh(
                          size: 30,
                          weight: FontWeight.w700,
                          color: AppColors.heading(context),
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
                            ? (isTawaf
                                ? l10n.tawafCompleteMessage
                                : l10n.saiCompleteMessage)
                            : l10n.circuitCountLabel(
                              state.count,
                              tawafSaiTarget,
                            ),
                        textAlign: TextAlign.center,
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
              if (dua != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GlassCard(
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dua.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.mutedText(context),
                          ),
                        ),
                        if (dua.arabic.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            dua.arabic,
                            textDirection: TextDirection.rtl,
                            style: AppTypography.naskh(
                              size: 20,
                              weight: FontWeight.w600,
                              color: AppColors.ayahText(context),
                              height: 1.7,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          dua.translation.isNotEmpty
                              ? dua.translation
                              : dua.note,
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 13,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/hajj_umrah_content.dart';
import '../../data/models/ritual_models.dart';
import '../controllers/ritual_providers.dart';

class RitualPhaseDetailPage extends ConsumerWidget {
  const RitualPhaseDetailPage({super.key, required this.phase});

  final RitualPhase phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final completed = ref.watch(ritualProgressProvider);
    final notifier = ref.read(ritualProgressProvider.notifier);
    final duas = phase.duaIds.map(duaById).whereType<RitualDua>().toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(phase.title)),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (phase.subtitle.isNotEmpty)
                Text(
                  phase.subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOnBg(context),
                  ),
                ),
              if (phase.date != null || phase.location != null) ...[
                const SizedBox(height: 4),
                Text(
                  [phase.date, phase.location].whereType<String>().join(' • '),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText(context),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                phase.overview,
                style: TextStyle(
                  color: AppColors.heading(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.ritualStepsHeading,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading(context),
                ),
              ),
              const SizedBox(height: 8),
              for (final step in phase.steps)
                _StepTile(
                  step: step,
                  done: completed.contains(step.id),
                  onToggle: () => notifier.toggle(step.id),
                ),
              if (duas.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.relevantDuasHeading,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading(context),
                  ),
                ),
                const SizedBox(height: 8),
                for (final dua in duas) _DuaCard(dua: dua),
              ],
              if (phase.edgeCases.isNotEmpty) ...[
                const SizedBox(height: 16),
                GlassCard(
                  borderRadius: 16,
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.info_outline,
                        color: AppColors.goldAccent(context),
                      ),
                      title: Text(l10n.edgeCasesHeading),
                      children: [
                        for (final edgeCase in phase.edgeCases)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '• $edgeCase',
                              style: TextStyle(
                                color: AppColors.mutedText(context),
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.done,
    required this.onToggle,
  });

  final RitualStep step;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderRadius: 14,
        onTap: onToggle,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: done ? AppColors.success : AppColors.mutedText(context),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.heading(context),
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.mutedText(context),
                      ),
                    ),
                    if (step.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.note!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.mutedText(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  const _DuaCard({required this.dua});

  final RitualDua dua;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderRadius: 16,
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
              const SizedBox(height: 6),
              Text(
                dua.transliteration,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
            if (dua.translation.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                dua.translation,
                style: TextStyle(
                  color: AppColors.heading(context),
                  fontSize: 13,
                ),
              ),
            ],
            if (dua.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                dua.note,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
            if (dua.source.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                dua.source,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.goldAccent(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

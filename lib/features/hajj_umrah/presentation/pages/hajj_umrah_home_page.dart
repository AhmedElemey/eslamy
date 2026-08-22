import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/number_seal.dart';
import '../../data/hajj_umrah_content.dart';
import '../../data/models/ritual_models.dart';
import '../../l10n/hajj_umrah_l10n.dart';
import '../controllers/pilgrim_mode_provider.dart';
import '../controllers/ritual_providers.dart';
import 'ritual_phase_detail_page.dart';
import 'tawaf_sai_counter_page.dart';

class HajjUmrahHomePage extends ConsumerWidget {
  const HajjUmrahHomePage({super.key});

  List<RitualPhase> _phasesFor(RitualTrack track) =>
      track == RitualTrack.umrah ? umrahPhases : hajjPhases;

  Future<void> _togglePilgrimMode(BuildContext context, WidgetRef ref) async {
    final enabled = ref.read(pilgrimModeEnabledProvider);
    if (enabled) {
      ref.read(pilgrimModeEnabledProvider.notifier).state = false;
      return;
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final granted =
        serviceEnabled &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
    if (!context.mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pilgrimModeLocationDenied)),
      );
      return;
    }
    ref.read(pilgrimModeEnabledProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final track = ref.watch(selectedRitualTrackProvider);
    final completed = ref.watch(ritualProgressProvider);
    final phases = _phasesFor(track);
    final pilgrimModeEnabled = ref.watch(pilgrimModeEnabledProvider);
    final nearestSite =
        pilgrimModeEnabled
            ? ref.watch(nearestHolySiteProvider).valueOrNull
            : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.hajjUmrahGuideTitle),
        actions: [
          IconButton(
            icon: Icon(
              pilgrimModeEnabled
                  ? Icons.my_location
                  : Icons.location_disabled_outlined,
              color: pilgrimModeEnabled ? AppColors.primaryOnBg(context) : null,
            ),
            tooltip: l10n.pilgrimModeTooltip,
            onPressed: () => _togglePilgrimMode(context, ref),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                l10n.hajjUmrahDisclaimer,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText(context),
                ),
              ),
              const SizedBox(height: 12),
              if (nearestSite != null) ...[
                GlassCard(
                  borderRadius: 16,
                  onTap:
                      nearestSite.relatedPhaseId == null
                          ? null
                          : () {
                            final phase = phases.firstWhere(
                              (p) => p.id == nearestSite.relatedPhaseId,
                              orElse: () => phases.first,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => RitualPhaseDetailPage(phase: phase),
                              ),
                            );
                          },
                  child: Row(
                    children: [
                      const IconSeal(icon: Icons.location_on_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.pilgrimModeNear(
                                nearestSite.localizedName(context),
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.heading(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nearestSite.localizedDescription(context),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              GlassCard(
                borderRadius: 16,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TawafSaiCounterPage(),
                      ),
                    ),
                child: Row(
                  children: [
                    const IconSeal(icon: Icons.donut_large_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.tawafSaiCounterTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading(context),
                        ),
                      ),
                    ),
                    Icon(
                      chevronFor(context),
                      color: AppColors.mutedText(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<RitualTrack>(
                segments: [
                  ButtonSegment(
                    value: RitualTrack.umrah,
                    label: Text(l10n.umrahTrackLabel),
                  ),
                  ButtonSegment(
                    value: RitualTrack.hajj,
                    label: Text(l10n.hajjTrackLabel),
                  ),
                ],
                selected: {track},
                onSelectionChanged:
                    (selection) =>
                        ref.read(selectedRitualTrackProvider.notifier).state =
                            selection.first,
              ),
              const SizedBox(height: 12),
              for (final phase in phases)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PhaseTile(phase: phase, completedIds: completed),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseTile extends StatelessWidget {
  const _PhaseTile({required this.phase, required this.completedIds});

  final RitualPhase phase;
  final Set<String> completedIds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final doneCount =
        phase.steps.where((s) => completedIds.contains(s.id)).length;
    final totalCount = phase.steps.length;
    final complete = totalCount > 0 && doneCount == totalCount;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;
    return GlassCard(
      borderRadius: 16,
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RitualPhaseDetailPage(phase: phase),
            ),
          ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: AppColors.hairline(context),
                  color: complete ? AppColors.success : AppColors.primary,
                ),
                if (complete)
                  Icon(Icons.check, size: 18, color: AppColors.success),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.localizedTitle(context),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading(context),
                  ),
                ),
                if (phase.subtitle.isNotEmpty)
                  Text(
                    phase.localizedSubtitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText(context),
                    ),
                  ),
                Text(
                  l10n.stepsCompletedLabel(doneCount, totalCount),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(chevronFor(context), color: AppColors.mutedText(context)),
        ],
      ),
    );
  }
}

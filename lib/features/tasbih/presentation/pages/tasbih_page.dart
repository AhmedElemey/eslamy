import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/localization/display_names.dart';
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
                  // Every built-in preset except the trailing "custom" one
                  // (a trigger, not a selectable dhikr) plus whatever the
                  // user has added themselves, then the trigger chip last.
                  itemCount:
                      dhikrPresets.length - 1 + state.customPresets.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final selectableCount =
                        dhikrPresets.length - 1 + state.customPresets.length;
                    if (i >= selectableCount) {
                      return ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 18),
                        label: Text(l10n.dhikrCustom),
                        onPressed: () => _addCustomDhikr(context, notifier),
                      );
                    }
                    final preset =
                        i < dhikrPresets.length - 1
                            ? dhikrPresets[i]
                            : state.customPresets[i -
                                (dhikrPresets.length - 1)];
                    final selected = preset.id == state.preset.id;
                    return ChoiceChip(
                      label: Text(
                        localizedDhikrName(l10n, preset.id, preset.englishName),
                      ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
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

  Future<void> _addCustomDhikr(
    BuildContext context,
    TasbihNotifier notifier,
  ) async {
    final result = await showDialog<({String text, int target})>(
      context: context,
      builder: (_) => const _AddCustomDhikrDialog(),
    );
    if (result == null) return;
    await notifier.addCustomPreset(
      arabicText: result.text,
      target: result.target,
    );
  }
}

/// Collects the dhikr/dua text and target count for a user-added preset.
/// Pure UI — hands the entered values back to the caller via
/// Navigator.pop rather than touching the provider itself, matching how
/// FavoritesPage's dialogs are wired.
class _AddCustomDhikrDialog extends StatefulWidget {
  const _AddCustomDhikrDialog();

  @override
  State<_AddCustomDhikrDialog> createState() => _AddCustomDhikrDialogState();
}

class _AddCustomDhikrDialogState extends State<_AddCustomDhikrDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _targetController = TextEditingController(text: '33');

  @override
  void dispose() {
    _textController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, (
      text: _textController.text.trim(),
      target: int.parse(_targetController.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.addCustomDhikrTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _textController,
              autofocus: true,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: AppTypography.naskh(
                size: 18,
                color: AppColors.heading(context),
              ),
              decoration: InputDecoration(labelText: l10n.customDhikrTextLabel),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? l10n.customDhikrTextRequired
                          : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.customDhikrTargetLabel,
              ),
              validator: (value) {
                final target = int.tryParse(value ?? '');
                return (target == null || target <= 0)
                    ? l10n.customDhikrTargetInvalid
                    : null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.addButton)),
      ],
    );
  }
}

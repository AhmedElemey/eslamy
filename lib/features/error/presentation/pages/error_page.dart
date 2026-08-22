import 'package:flutter/material.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';

class ErrorPage extends StatelessWidget {
  final String? message;
  final Object? error;

  const ErrorPage({super.key, this.message, this.error});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final displayMessage = message ?? l10n.somethingWentWrongGeneric;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: GlassCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.error.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 36,
                          color: scheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.errorOccurredTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedText(context),
                          height: 1.5,
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 140),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer.withValues(
                              alpha: 0.18,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: scheme.error.withValues(alpha: 0.25),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              error.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: scheme.error,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              child: Text(l10n.goBack),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/home',
                                  (_) => false,
                                );
                              },
                              child: Text(l10n.goHome),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

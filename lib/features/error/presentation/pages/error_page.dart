import 'package:flutter/material.dart';
import '../../../../core/localization/context_l10n_extension.dart';

class ErrorPage extends StatelessWidget {
  final String? message;
  final Object? error;

  const ErrorPage({super.key, this.message, this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final displayMessage = message ?? l10n.somethingWentWrongGeneric;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.errorPageTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.errorOccurredTitle, style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 16),
              Text(displayMessage, style: theme.textTheme.bodyLarge),
              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
              const Spacer(),
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
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/home', (_) => false);
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
    );
  }
}

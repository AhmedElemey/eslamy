import 'package:flutter/material.dart';
import '../../core/localization/context_l10n_extension.dart';
import '../../core/theme/app_colors.dart';

/// Standard "list failed to load" state: an error message plus a Retry
/// button that re-runs [onRetry] (typically `ref.invalidate(someProvider)`).
/// Used wherever a list-backed page/section surfaces an [AsyncValue.error].
class ListErrorView extends StatelessWidget {
  const ListErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: scheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText(context)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

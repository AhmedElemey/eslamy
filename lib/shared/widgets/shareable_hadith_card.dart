import 'package:flutter/material.dart';
import '../../core/localization/context_l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../features/hadith/models/hadith.dart';

/// Pure presentational card used for the share-as-image flow. Kept simple
/// and self-contained so it renders identically whether shown on screen or
/// captured off it.
class ShareableHadithCard extends StatelessWidget {
  const ShareableHadithCard({super.key, required this.hadith});

  final HadithItem hadith;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF7C4DBB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.format_quote_rounded, color: Colors.white70, size: 32),
          const SizedBox(height: 12),
          if (hadith.narrator != null && hadith.narrator!.isNotEmpty) ...[
            Text(
              context.l10n.narratedBy(hadith.narrator!),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            hadith.body ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.mosque, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hadith.bookName != null
                      ? '${hadith.bookName} #${formatHadithNumber(hadith.hadithNumber)}'
                      : hadith.title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                context.l10n.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

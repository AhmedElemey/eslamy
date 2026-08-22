import 'package:flutter/material.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../widgets/streak_card.dart';

/// Destination for the Home dashboard's streak tile — shows the current
/// streak and the last 7 days of activity via the existing [StreakCard].
class StreakDetailPage extends StatelessWidget {
  const StreakDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(l10n.streakDetailTitle)),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StreakCard(),
                const SizedBox(height: 16),
                Text(
                  l10n.streakExplanationBody,
                  style: TextStyle(color: AppColors.mutedText(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

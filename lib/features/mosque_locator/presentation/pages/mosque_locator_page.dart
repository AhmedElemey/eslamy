import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/number_seal.dart';
import '../../models/mosque.dart';
import '../controllers/mosque_locator_providers.dart';

class MosqueLocatorPage extends ConsumerWidget {
  const MosqueLocatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mosqueLocatorProvider);
    final notifier = ref.read(mosqueLocatorProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(l10n.mosqueLocatorTitle)),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: notifier.load,
            child: _buildBody(context, state, notifier),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MosqueLocatorState state,
    MosqueLocatorNotifier notifier,
  ) {
    final l10n = context.l10n;

    if (state.isLoading && state.mosques.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.mosques.isEmpty) {
      return _MessageView(
        icon: Icons.error_outline,
        message: l10n.mosqueLocatorFailedWithError(state.error!),
        onRetry: notifier.load,
      );
    }

    if (state.mosques.isEmpty) {
      return _MessageView(
        icon: Icons.mosque_outlined,
        message: l10n.mosqueLocatorEmpty,
        onRetry: notifier.load,
      );
    }

    final bannerCount =
        (state.isShowingStaleCache ? 1 : 0) +
        (state.usingFallbackLocation ? 1 : 0);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.mosques.length + bannerCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (state.isShowingStaleCache) {
          if (index == 0) {
            return _FallbackLocationBanner(
              text: l10n.mosqueLocatorStaleCache,
            );
          }
          index -= 1;
        }
        if (state.usingFallbackLocation) {
          if (index == 0) {
            return _FallbackLocationBanner(
              text: l10n.mosqueLocatorApproximateLocation,
            );
          }
          index -= 1;
        }
        return _MosqueTile(mosque: state.mosques[index]);
      },
    );
  }
}

class _MosqueTile extends StatelessWidget {
  const _MosqueTile({required this.mosque});

  final Mosque mosque;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textColor = Theme.of(context).textTheme.titleMedium?.color;

    return GlassCard(
      borderRadius: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconSeal(icon: Icons.mosque_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mosque.name ?? l10n.mosqueLocatorUnnamedMosque,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (mosque.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    mosque.address!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  l10n.mosqueLocatorDistance(_formatDistance(mosque.distanceMeters)),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedText(context),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _openDirections(context, mosque),
                    icon: const Icon(Icons.directions_outlined, size: 18),
                    label: Text(l10n.mosqueLocatorDirections),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections(BuildContext context, Mosque mosque) async {
    final l10n = context.l10n;
    final launched = await launchUrl(
      mosque.directionsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mosqueLocatorCouldNotOpenMaps)));
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}

class _FallbackLocationBanner extends StatelessWidget {
  const _FallbackLocationBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.mutedText(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: AppColors.mutedText(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: Text(l10n.retry),
          ),
        ),
      ],
    );
  }
}

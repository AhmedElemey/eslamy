import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Full-screen "no internet" status page. Pushed app-wide (see
/// `_handleConnectivityChange` in main.dart) whenever connectivity drops,
/// and pops itself automatically the moment connectivity is restored — the
/// "Try Again" button just gives the user an immediate, on-demand check
/// instead of waiting for the next connectivity-change event.
class NoNetworkPage extends ConsumerStatefulWidget {
  const NoNetworkPage({super.key});

  @override
  ConsumerState<NoNetworkPage> createState() => _NoNetworkPageState();
}

class _NoNetworkPageState extends ConsumerState<NoNetworkPage> {
  bool _checking = false;

  Future<void> _retry() async {
    setState(() => _checking = true);
    final connected = await checkHasConnection();
    if (!mounted) return;
    setState(() => _checking = false);
    if (connected) {
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noNetworkMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Redundant with the app-wide listener in main.dart, but keeping the
    // pop-on-reconnect logic co-located here too means this page always
    // dismisses itself correctly even if it's ever opened some other way.
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      if (next.valueOrNull == true) {
        Navigator.of(context).maybePop();
      }
    });

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
                          color: AppColors.goldAccent(
                            context,
                          ).withValues(alpha: 0.14),
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: 36,
                          color: AppColors.goldAccent(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.noNetworkTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noNetworkMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedText(context),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _checking ? null : _retry,
                          icon:
                              _checking
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                        ),
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

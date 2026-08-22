import 'package:flutter/material.dart';
import '../../../../core/localization/context_l10n_extension.dart';
import '../../../../core/share/share_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/shareable_hadith_card.dart';
import '../../models/hadith.dart';

Future<void> showHadithShareSheet(BuildContext context, HadithItem hadith) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HadithShareSheet(hadith: hadith),
  );
}

class _HadithShareSheet extends StatefulWidget {
  const _HadithShareSheet({required this.hadith});

  final HadithItem hadith;

  @override
  State<_HadithShareSheet> createState() => _HadithShareSheetState();
}

class _HadithShareSheetState extends State<_HadithShareSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      await ShareService.shareWidgetAsImage(
        _boundaryKey,
        text: context.l10n.sharedFromEslamy,
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _boundaryKey,
              child: ShareableHadithCard(hadith: widget.hadith),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSharing ? null : _share,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                icon:
                    _isSharing
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.share),
                label: Text(
                  _isSharing
                      ? context.l10n.preparingShare
                      : context.l10n.shareAsImage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

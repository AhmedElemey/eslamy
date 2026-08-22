import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/quran/presentation/widgets/tajweed_text.dart';

class BasmalaHeader extends StatelessWidget {
  const BasmalaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: AppTypography.naskh(
          size: 22,
          color: AppColors.primaryOnBg(context),
          height: 1.6,
        ),
      ),
    );
  }
}

class AyahNumberMedallion extends StatelessWidget {
  const AyahNumberMedallion({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.goldAccent(context), width: 1.2),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.goldAccent(context),
        ),
      ),
    );
  }
}

class AyahBlock extends StatelessWidget {
  const AyahBlock({
    super.key,
    required this.number,
    required this.arabic,
    this.tajweedText,
    this.translation,
    this.onTap,
    this.footer,
  });

  final int number;
  final String arabic;
  final String? tajweedText;
  final String? translation;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final ayahStyle = AppTypography.ayah(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (tajweedText != null)
              TajweedText(text: tajweedText!, style: ayahStyle)
            else
              Text(
                arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: ayahStyle,
              ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AyahNumberMedallion(number: number),
            ),
            if (translation != null && translation!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                translation!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
            if (footer != null) ...[const SizedBox(height: 8), footer!],
          ],
        ),
      ),
    );
  }
}

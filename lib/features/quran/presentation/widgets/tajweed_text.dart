import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../data/tajweed_rules.dart';
import '../../service/tajweed_text_parser.dart';

/// Renders Tajweed-tagged verse text (see tajweed_text_parser.dart) with
/// each ruled span colored, and tappable to show what that rule is.
class TajweedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const TajweedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.right,
  });

  @override
  State<TajweedText> createState() => _TajweedTextState();
}

class _TajweedTextState extends State<TajweedText> {
  late List<TajweedSegment> _segments;
  late List<TapGestureRecognizer?> _recognizers;

  @override
  void initState() {
    super.initState();
    _buildSegments();
  }

  @override
  void didUpdateWidget(covariant TajweedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _disposeRecognizers();
      _buildSegments();
    }
  }

  void _buildSegments() {
    _segments = parseTajweedText(widget.text);
    _recognizers = [
      for (final segment in _segments)
        segment.rule == null
            ? null
            : (TapGestureRecognizer()..onTap = () => _showRuleInfo(segment.rule!)),
    ];
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer?.dispose();
    }
  }

  void _showRuleInfo(TajweedRule rule) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => _TajweedRuleInfoSheet(rule: rule),
    );
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? DefaultTextStyle.of(context).style;
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < _segments.length; i++)
            _segments[i].rule == null
                ? TextSpan(text: _segments[i].text, style: baseStyle)
                : TextSpan(
                    text: _segments[i].text,
                    style: baseStyle.copyWith(
                      color: _segments[i].rule!.colorFor(context),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: _recognizers[i],
                  ),
        ],
      ),
      textDirection: TextDirection.rtl,
      textAlign: widget.textAlign,
    );
  }
}

class _TajweedRuleInfoSheet extends StatelessWidget {
  final TajweedRule rule;

  const _TajweedRuleInfoSheet({required this.rule});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: rule.colorFor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rule.arabicName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rule.englishName,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

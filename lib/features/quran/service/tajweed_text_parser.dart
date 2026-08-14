import '../data/tajweed_rules.dart';

/// A run of verse text with an optional Tajweed rule applied to it.
class TajweedSegment {
  final String text;
  final TajweedRule? rule;

  const TajweedSegment(this.text, [this.rule]);
}

/// Matches one rule span, e.g. `[h:1[ٱ]` or `[l[ل]` — group 1 is the rule
/// code, group 2 is the ruled text. The `:<digits>` id is optional and
/// unused (it's a reference id in the source data, not needed to render).
final RegExp _tajweedTagPattern = RegExp(r'\[([a-z]):?\d*\[([^\]]*)\]');

/// Parses Al Quran Cloud's `quran-tajweed` bracket format into plain-text
/// and rule-tagged segments, e.g. `بِسْمِ [h:1[ٱ]للَّهِ` becomes
/// `[("بِسْمِ ", null), ("ٱ", Hamzat ul Wasl), ("للَّهِ", null)]`.
///
/// Rule spans in this format are sequential, never nested (confirmed
/// against the live API), so a single linear regex pass is sufficient —
/// no HTML/XML parser needed.
List<TajweedSegment> parseTajweedText(String raw) {
  final segments = <TajweedSegment>[];
  var cursor = 0;

  for (final match in _tajweedTagPattern.allMatches(raw)) {
    if (match.start > cursor) {
      segments.add(TajweedSegment(raw.substring(cursor, match.start)));
    }
    final code = match.group(1)!;
    final text = match.group(2)!;
    if (text.isNotEmpty) {
      segments.add(TajweedSegment(text, tajweedRules[code]));
    }
    cursor = match.end;
  }

  if (cursor < raw.length) {
    segments.add(TajweedSegment(raw.substring(cursor)));
  }

  return segments;
}

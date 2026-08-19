import 'package:flutter/widgets.dart';

import '../data/models/ritual_models.dart';
import 'hajj_umrah_strings.dart';

String _localeCode(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

String hajjString(BuildContext context, String key, String fallback) {
  final code = _localeCode(context);
  if (code == 'en' || fallback.isEmpty) return fallback;
  final table = code == 'it' ? hajjUmrahIt : hajjUmrahAr;
  return table[key] ?? fallback;
}

extension RitualPhaseL10n on RitualPhase {
  String localizedTitle(BuildContext context) =>
      hajjString(context, '$id.title', title);
  String localizedSubtitle(BuildContext context) =>
      hajjString(context, '$id.subtitle', subtitle);
  String localizedOverview(BuildContext context) =>
      hajjString(context, '$id.overview', overview);
  String? localizedDate(BuildContext context) =>
      date == null ? null : hajjString(context, '$id.date', date!);
  String? localizedLocation(BuildContext context) =>
      location == null ? null : hajjString(context, '$id.location', location!);
  List<String> localizedEdgeCases(BuildContext context) => [
    for (var i = 0; i < edgeCases.length; i++)
      hajjString(context, '$id.edgeCases.$i', edgeCases[i]),
  ];
}

extension RitualStepL10n on RitualStep {
  String localizedLabel(BuildContext context) =>
      hajjString(context, '$id.label', label);
  String? localizedNote(BuildContext context) =>
      note == null ? null : hajjString(context, '$id.note', note!);
}

extension RitualDuaL10n on RitualDua {
  String localizedName(BuildContext context) =>
      hajjString(context, '$id.name', name);
  String localizedTranslation(BuildContext context) =>
      hajjString(context, '$id.translation', translation);
  String localizedNote(BuildContext context) =>
      hajjString(context, '$id.note', note);
}

extension HolySiteL10n on HolySite {
  String localizedName(BuildContext context) =>
      hajjString(context, '$id.name', name);
  String localizedDescription(BuildContext context) =>
      hajjString(context, '$id.description', description);
}

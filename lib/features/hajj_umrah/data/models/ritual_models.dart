/// A single supplication tied to a ritual moment (e.g. the Talbiyah, the
/// dua between the Yemeni Corner and the Black Stone).
class RitualDua {
  const RitualDua({
    required this.id,
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
    required this.note,
    this.featured = false,
  });

  final String id;
  final String name;
  final String arabic;
  final String transliteration;
  final String translation;
  final String source;
  final String note;
  final bool featured;
}

/// One actionable item within a [RitualPhase] (e.g. "Stone Jamarat al-Aqabah").
class RitualStep {
  const RitualStep({required this.id, required this.label, this.note});

  final String id;
  final String label;
  final String? note;
}

/// A stage of Hajj or Umrah — a day (Hajj) or a leg of the journey (Umrah),
/// made up of ordered [steps], the [duaIds] relevant to it, and any
/// exceptions/edge cases worth flagging.
class RitualPhase {
  const RitualPhase({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.overview,
    required this.steps,
    this.date,
    this.arabicDate,
    this.arabicName,
    this.location,
    this.duaIds = const [],
    this.edgeCases = const [],
    this.isOptional = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String overview;
  final List<RitualStep> steps;
  final String? date;
  final String? arabicDate;
  final String? arabicName;
  final String? location;
  final List<String> duaIds;
  final List<String> edgeCases;
  final bool isOptional;
}

/// Which pilgrimage track a phase list belongs to.
enum RitualTrack { umrah, hajj }

/// A geofence-style holy site used by Pilgrim Mode — when the user's
/// position comes within [radiusMeters], its guidance is surfaced.
class HolySite {
  const HolySite({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.description,
    this.relatedPhaseId,
  });

  final String id;
  final String name;
  final String arabicName;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String description;

  /// Optional [RitualPhase.id] to deep-link to for full guidance.
  final String? relatedPhaseId;
}

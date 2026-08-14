import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'models/azkar_models.dart';

/// Loads the bundled Hisnul-Muslim-style seed snapshot (a saved response
/// from UmmahAPI's /api/duas, see assets/data/azkar.json) for first-run
/// seeding and offline fallback.
class AzkarLocalDataSource {
  Future<AzkarDataset> load() async {
    final raw = await rootBundle.loadString('assets/data/azkar.json');
    return AzkarDataset.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

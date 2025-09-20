import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/quran_models.dart';

/// In-memory preferences service as fallback when SharedPreferences fails
class MemoryPreferencesService {
  static final Map<String, String> _memoryStorage = {};
  static const String _selectedReciterKey = 'selected_reciter';

  /// Save the selected reciter to memory
  static void saveSelectedReciter(Reciter reciter) {
    try {
      final reciterJson = jsonEncode(reciter.toJson());
      _memoryStorage[_selectedReciterKey] = reciterJson;
      debugPrint('Reciter saved to memory: ${reciter.name}');
    } catch (e) {
      debugPrint('Error saving reciter to memory: $e');
    }
  }

  /// Load the selected reciter from memory
  static Reciter? loadSelectedReciter() {
    try {
      final reciterJson = _memoryStorage[_selectedReciterKey];

      if (reciterJson != null) {
        final reciterMap = jsonDecode(reciterJson) as Map<String, dynamic>;
        final reciter = Reciter.fromJson(reciterMap);
        debugPrint('Reciter loaded from memory: ${reciter.name}');
        return reciter;
      }
    } catch (e) {
      debugPrint('Error loading reciter from memory: $e');
    }

    return null;
  }

  /// Clear the selected reciter from memory
  static void clearSelectedReciter() {
    _memoryStorage.remove(_selectedReciterKey);
    debugPrint('Reciter cleared from memory');
  }

  /// Check if memory storage has any data
  static bool hasData() {
    return _memoryStorage.containsKey(_selectedReciterKey);
  }
}

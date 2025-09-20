import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_models.dart';
import 'memory_preferences_service.dart';

class ReciterPreferencesService {
  static const String _selectedReciterKey = 'selected_reciter';
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences with proper error handling
  static Future<bool> _initializePrefs() async {
    if (_prefs != null) return true;

    try {
      _prefs = await SharedPreferences.getInstance();
      return true;
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
      return false;
    }
  }

  /// Save the selected reciter to SharedPreferences (with memory fallback)
  static Future<void> saveSelectedReciter(Reciter reciter) async {
    try {
      final initialized = await _initializePrefs();
      if (initialized) {
        final reciterJson = jsonEncode(reciter.toJson());
        await _prefs!.setString(_selectedReciterKey, reciterJson);
        debugPrint('Reciter saved to SharedPreferences: ${reciter.name}');
      } else {
        debugPrint('SharedPreferences not initialized, using memory fallback');
      }
    } catch (e) {
      debugPrint(
        'Error saving to SharedPreferences: $e, using memory fallback',
      );
    }

    // Always save to memory as well for immediate access and fallback
    MemoryPreferencesService.saveSelectedReciter(reciter);
  }

  /// Load the selected reciter from SharedPreferences (with memory fallback)
  static Future<Reciter?> loadSelectedReciter() async {
    // Try SharedPreferences first
    try {
      final initialized = await _initializePrefs();
      if (initialized) {
        final reciterJson = _prefs!.getString(_selectedReciterKey);

        if (reciterJson != null) {
          final reciterMap = jsonDecode(reciterJson) as Map<String, dynamic>;
          final reciter = Reciter.fromJson(reciterMap);
          debugPrint('Reciter loaded from SharedPreferences: ${reciter.name}');
          return reciter;
        }
      }
    } catch (e) {
      debugPrint(
        'Error loading from SharedPreferences: $e, trying memory fallback',
      );
    }

    // Fallback to memory storage
    final memoryReciter = MemoryPreferencesService.loadSelectedReciter();
    if (memoryReciter != null) {
      debugPrint('Reciter loaded from memory: ${memoryReciter.name}');
      return memoryReciter;
    }

    debugPrint('No saved reciter found, will use default');
    return null;
  }

  /// Clear the selected reciter from SharedPreferences and memory
  static Future<void> clearSelectedReciter() async {
    // Clear from SharedPreferences
    try {
      final initialized = await _initializePrefs();
      if (initialized) {
        await _prefs!.remove(_selectedReciterKey);
        debugPrint('Reciter cleared from SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error clearing from SharedPreferences: $e');
    }

    // Always clear from memory as well
    MemoryPreferencesService.clearSelectedReciter();
  }

  /// Get the default reciter (first one in the list)
  static Reciter getDefaultReciter() {
    // Return the first reciter as default
    return const Reciter(
      id: 1,
      name: 'Abdul Basit Mujawwad',
      arabicName: 'عبد الباسط عبد الصمد',
      relativePath: 'Abdul_Basit_Mujawwad',
    );
  }
}

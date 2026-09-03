import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Call once per test file (e.g. in `setUpAll`) before touching any of the
/// app's `*Database` singletons. Swaps sqflite's platform-channel backend for
/// `sqflite_common_ffi`'s, which runs against a real SQLite binary on the
/// host — so the singletons work unmodified in `flutter test`, no
/// device/emulator required.
void initSqfliteFfiForTests() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

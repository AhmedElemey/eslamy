import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device currently has a network interface up (Wi-Fi, mobile
/// data, ethernet, ...). This reflects radio/interface state only — not
/// proof of actual internet reachability — which is enough to drive the
/// app-wide "no network, please connect" redirect without adding a second
/// package just for a reachability probe.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _hasConnection(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_hasConnection);
});

bool _hasConnection(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);

/// One-shot check used by the "Try Again" button on the no-network page —
/// independent of the stream so a tap gets an immediate, fresh answer
/// instead of waiting on the next connectivity-change event.
Future<bool> checkHasConnection() async {
  final results = await Connectivity().checkConnectivity();
  return _hasConnection(results);
}

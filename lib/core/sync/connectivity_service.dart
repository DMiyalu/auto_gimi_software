import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(Connectivity());
});

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  Stream<bool> watchOnline() {
    return _connectivity.onConnectivityChanged.map(_isOnline);
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _isOnline(result);
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}

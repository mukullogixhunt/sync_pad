import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer';

class ConnectivityService {
  // Accept Connectivity instance via constructor for better testing/DI
  final Connectivity connectivity;

  final ValueNotifier<ConnectivityResult> connectionStatusNotifier =
      ValueNotifier(ConnectivityResult.none);

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityService({required this.connectivity}) {
    _init();
  }

  Future<void> _init() async {
    try {
      final initialResultList =
          await connectivity.checkConnectivity(); // Use injected instance
      _updateStatus(initialResultList);
    } catch (e) {
      log(
        "ConnectivityService: Couldn't check initial connectivity status: $e",
      );
      _updateStatus([ConnectivityResult.none]);
    }
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      _updateStatus,
    ); // Use injected instance
    log("ConnectivityService: Initialized and listening.");
  }

  void _updateStatus(List<ConnectivityResult> resultList) {
    log("ConnectivityService: Received status list: $resultList");
    ConnectivityResult effectiveResult = ConnectivityResult.none;
    if (resultList.contains(ConnectivityResult.wifi)) {
      effectiveResult = ConnectivityResult.wifi;
    } else if (resultList.contains(ConnectivityResult.mobile)) {
      effectiveResult = ConnectivityResult.mobile;
    } else if (resultList.contains(ConnectivityResult.ethernet)) {
      effectiveResult = ConnectivityResult.ethernet;
    }
    if (connectionStatusNotifier.value != effectiveResult) {
      connectionStatusNotifier.value = effectiveResult;
      log(
        "ConnectivityService: Effective status changed to $effectiveResult (based on $resultList)",
      );
    }
  }

  bool get isConnected {
    final currentEffectiveStatus = connectionStatusNotifier.value;
    return currentEffectiveStatus != ConnectivityResult.none &&
        currentEffectiveStatus != ConnectivityResult.bluetooth;
  }

  void dispose() {
    _connectivitySubscription.cancel();
    connectionStatusNotifier.dispose();
    log("ConnectivityService: Disposed.");
  }
}

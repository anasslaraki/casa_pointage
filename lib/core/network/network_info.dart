// Dart imports:
import 'dart:async';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:casa_pointage/app/data/datasources/remote/errors/exceptions.dart';

// Project imports:

enum NetworkStatus {
  connected,
  disconnected,
}

abstract class NetworkInfo {
  Future<bool> get isConnected;

  late Rx<NetworkStatus> onNetworkChanged;
  Future<T> verifyConnectivity<T>(Future func);

  Connectivity? connectivity;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl extends GetxController implements NetworkInfo {
  @override
  Connectivity? connectivity;
  @override
  Rx<NetworkStatus> onNetworkChanged =
      Rx<NetworkStatus>(NetworkStatus.connected);

  NetworkInfoImpl({this.connectivity}) {
    setupConnectivityLister();
  }

  // here we ping on some website to know if there is internet with that activated connection
  // @override
  // Future<bool> get hasInternet => internetConnectionChecker!.hasConnection;

  // here we only test if device activate connection
  @override
  Future<bool> get isConnected async {
    final results = await connectivity!.checkConnectivity();
    return _hasConnection(results);
  }

  void setupConnectivityLister() {
    connectivity!.onConnectivityChanged.listen((results) async {
      onNetworkChanged.value = _hasConnection(results)
          ? NetworkStatus.connected
          : NetworkStatus.disconnected;
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.contains(ConnectivityResult.wifi) ||
      results.contains(ConnectivityResult.mobile) ||
      results.contains(ConnectivityResult.ethernet);

  @override
  Future<T> verifyConnectivity<T>(Future func) async {
    if (await isConnected) {
      return (await func) as T;
    } else {
      throw ConnectivityException();
    }
  }
}

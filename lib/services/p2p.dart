// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:permission_handler/permission_handler.dart';

class P2PManager {
  final plugin = FlutterP2pConnection();
  WifiP2PInfo? wifiP2PInfo;
  Stream<WifiP2PInfo>? streamWifiInfo;
  Stream<List<DiscoveredPeers>>? streamPeers;
  bool isInit = false;

  // singleton (init on first use)
  static final P2PManager _instance = P2PManager._internal();
  factory P2PManager() => _instance;
  P2PManager._internal();

  Future init() async {
    if (isInit) return;
    await plugin.initialize();
    await plugin.register();
    streamWifiInfo = plugin.streamWifiP2PInfo();
    streamPeers = plugin.streamPeers();

    if (streamWifiInfo != null) {
      streamWifiInfo!.listen((event) {
        wifiP2PInfo = event;
      });
    }
    isInit = true;
  }

  Future<bool> enable() async {
    return await plugin.register();
  }

  Future<bool> disable() async {
    return await plugin.unregister();
  }

  bool _closeSocketConnection() {
    return plugin.closeSocket();
  }

  Future<bool> host() async {
    return await plugin.createGroup();
  }

  Future<WifiP2PGroupInfo?> groupInfo() async {
    var result = await plugin.groupInfo();
    if (result == null) {
      var wifi = await Permission.nearbyWifiDevices.status;
      var location = await Permission.location.status;

      if (wifi.isDenied) await Permission.nearbyWifiDevices.request();
      if (location.isDenied) await Permission.location.request();
    }
    return result;
  }

  WifiP2PInfo? wifiInfo() {
    return wifiP2PInfo;
  }

  Future<bool> disconnect() async {
    final a = await plugin.removeGroup();
    final b = _closeSocketConnection();
    return a && b;
  }

  Future<bool> discover() async {
    var wifi = await Permission.nearbyWifiDevices.status;
    var location = await Permission.location.status;

    if (wifi.isDenied) await Permission.nearbyWifiDevices.request();
    if (location.isDenied) await Permission.location.request();
    return await plugin.discover();
  }

  Future<bool> connect(DiscoveredPeers peer) async {
    return await plugin.connect(peer.deviceAddress);
  }

  Future<bool> stopDiscover() async {
    return await plugin.stopDiscovery();
  }

  Future<List<DiscoveredPeers>> getPeers() async {
    return await plugin.fetchPeers();
  }
}

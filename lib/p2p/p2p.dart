// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class P2PManager {
  final _flutterP2pConnectionPlugin = FlutterP2pConnection();
  List<DiscoveredPeers> peers = [];
  WifiP2PInfo? wifiP2PInfo;
  Stream<WifiP2PInfo>? _streamWifiInfo;
  Stream<List<DiscoveredPeers>>? _streamPeers;
  bool isInit = false;

  // singleton (init on first use)
  static final P2PManager _instance = P2PManager._internal();
  factory P2PManager() => _instance;
  P2PManager._internal();
  

  Future init() async {
    if (isInit) return;
    await _flutterP2pConnectionPlugin.initialize();
    await _flutterP2pConnectionPlugin.register();
    _streamWifiInfo = _flutterP2pConnectionPlugin.streamWifiP2PInfo();
    _streamPeers = _flutterP2pConnectionPlugin.streamPeers();

    if (_streamWifiInfo != null) {
      _streamWifiInfo!.listen((event) {
        wifiP2PInfo = event;
      });
    }
    isInit = true;
  }

  Future<bool> enable() async {
    return await _flutterP2pConnectionPlugin.register();
  }

  Future<bool> disable() async {
    return await _flutterP2pConnectionPlugin.unregister();
  }

  Future<bool> startSocket() async {
    if (wifiP2PInfo != null) {
      bool started = await _flutterP2pConnectionPlugin.startSocket(
        groupOwnerAddress: wifiP2PInfo!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 2,
        deleteOnError: true,
        onConnect: (name, address) {
          print("$name connected to socket with address: $address");
        },
        transferUpdate: (transfer) {
          if (transfer.completed) {
            print(
                "${transfer.failed ? "failed to ${transfer.receiving ? "receive" : "send"}" : transfer.receiving ? "received" : "sent"}: ${transfer.filename}");
          }
          print(
              "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}");
        },
        receiveString: (req) async {
          print(req);
        },
      );
      print("open socket: $started");
      return started;
    } else {
      print("wifiP2PInfo is null");
      return false;
    }
  }

  Future<bool> connectToSocket() async {
    if (wifiP2PInfo != null) {
      await _flutterP2pConnectionPlugin.connectToSocket(
        groupOwnerAddress: wifiP2PInfo!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 3,
        deleteOnError: true,
        onConnect: (address) {
          print("connected to socket: $address");
        },
        transferUpdate: (transfer) {
          // if (transfer.count == 0) transfer.cancelToken?.cancel();
          if (transfer.completed) {
            print(
                "${transfer.failed ? "failed to ${transfer.receiving ? "receive" : "send"}" : transfer.receiving ? "received" : "sent"}: ${transfer.filename}");
          }
          print(
              "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}");
        },
        receiveString: (req) async {
          print(req);
        },
      );
      return true;
    } else {
      print("wifiP2PInfo is null");
      return false;
    }
  }

  bool closeSocketConnection() {
    return _flutterP2pConnectionPlugin.closeSocket();
  }

  Future<bool> host() async {
    return await _flutterP2pConnectionPlugin.createGroup();
  }

  Future<WifiP2PGroupInfo?> groupInfo() async {
    return _flutterP2pConnectionPlugin.groupInfo();
  }

  Future<bool> disconnect() async {
    return await _flutterP2pConnectionPlugin.removeGroup();
  }

  Future<bool> discover() async {
    return await _flutterP2pConnectionPlugin.discover();
  }

  Future<bool> connect(DiscoveredPeers peer) async {
    return await _flutterP2pConnectionPlugin.connect(peer.deviceAddress);
  }

  Future<bool> stopDiscover() async {
    return await _flutterP2pConnectionPlugin.stopDiscovery();
  }

  Future<List<DiscoveredPeers>> getPeers() async {
    return await _flutterP2pConnectionPlugin.fetchPeers();
  }
}

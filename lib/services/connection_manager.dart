import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:quesaco/models/game_state.dart';

import 'p2p.dart';

class Manager extends ChangeNotifier {
  static final Manager _instance = Manager._internal();
  final p2p = P2PManager();
  WifiP2PGroupInfo? groupInfo;
  bool isHost = false;
  List<DiscoveredPeers> peers = [];
  bool isConnected = false;
  GameState? gameState;
  String me = "?";

  factory Manager() {
    return _instance;
  }

  Manager._internal();

  void _onGameStateChange() {
    if (gameState == null) return;
    sendMessage(gameState.toString());
  }

  // Initialize and manage the connection and messaging here
  // Inside ConnectionManager
  Future createRoom() async {
    if (!p2p.isInit) p2p.init();
    me = await p2p.plugin.getDeviceModel() ?? "?";
    isHost = true;
    isConnected = false;
    await p2p.init();
    await p2p.host();
    for (var i = 0; i < 10; i++) {
      if (await _startSocket()) {
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    for (var i = 0; i < 10; i++) {
      await refreshRoom();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // Initialize and establish a connection as a waiting player
  Future discoverRooms() async {
    isHost = false;
    isConnected = false;
    await p2p.init();
    await p2p.discover();
    for (var i = 0; i < 10; i++) {
      await refreshRoom();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<bool> joinRoom(DiscoveredPeers peer) async {
    if (!p2p.isInit) p2p.init();
    me = await p2p.plugin.getDeviceModel() ?? "?";
    await p2p.disconnect();
    final connectedRoom = await p2p.connect(peer);
    if (!connectedRoom) {
      log("Can't connect to room");
      return false;
    } else {
      log("Connected to room, trying to connect to socket");
    }
    // try 10 times to connect to socket
    for (var i = 0; i < 30; i++) {
      if (await _connectToSocket()) {
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    if (isConnected) {
      notifyListeners();
      return true;
    }
    disconnect();
    return false;
  }

  Future<bool> startGame() async {
    refreshRoom();
    if (!isConnected || groupInfo == null) return false;
    if (isHost) {
      var players = groupInfo!.clients.map((e) => e.deviceName).toList();
      // add host as player
      players.add(me);
      gameState = GameState.init(players);
      sendMessage(gameState.toString());
      gameState!.addListener(_onGameStateChange);
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> _startSocket() async {
    var info = p2p.wifiInfo();
    if (info != null) {
      var result = await p2p.plugin.startSocket(
        groupOwnerAddress: info.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 3,
        deleteOnError: true,
        onConnect: (name, address) {
          log("$name connected to socket with address: $address");
        },
        transferUpdate: (_) {},
        receiveString: _onReceiveMessage,
      );
      log("Connected to the socket! $result");
      isConnected = result;
      return result;
    } else {
      log("Can't start socket, info is null");
      isConnected = false;
      return false;
    }
  }

  Future<bool> _connectToSocket() async {
    var info = p2p.wifiInfo();
    if (info != null) {
      var result = await p2p.plugin.connectToSocket(
        groupOwnerAddress: info.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 3,
        deleteOnError: true,
        onConnect: (address) {
          log("connected to socket with address: $address");
        },
        transferUpdate: (_) {},
        receiveString: _onReceiveMessage,
      );
      log("Connected to the socket! $result");
      isConnected = result;
      return result;
    } else {
      isConnected = false;
      log("Can't connect to socket, info is null");
      return false;
    }
  }

  Future refreshRoom() async {
    if (isHost || isConnected) {
      if (!isConnected) {
        await _startSocket();
      }
      groupInfo = await p2p.groupInfo();
    } else {
      List<DiscoveredPeers> p = await p2p.getPeers();
      peers = p;
    }
    notifyListeners();
  }

  Future disconnect() async {
    log("Disconnecting...");
    gameState?.removeListener(_onGameStateChange);
    gameState = null;
    await p2p.disconnect();
    await p2p.stopDiscover();
    notifyListeners();
  }

  // Inside ConnectionManager
  void sendMessage(String message) {
    log("Sending message: $message");
    p2p.plugin.sendStringToSocket(message);
    notifyListeners();
  }

  void _onReceiveMessage(dynamic message) async {
    log("Received message: $message");
    gameState?.removeListener(_onGameStateChange);
    gameState = GameState.from(message);
    gameState!.addListener(_onGameStateChange);
    notifyListeners();
  }
}

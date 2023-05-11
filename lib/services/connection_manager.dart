import 'dart:developer';

import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:quesaco/models/game_state.dart';

import 'p2p.dart';

class Manager extends GameState {
  static final Manager _instance = Manager._internal();
  final p2p = P2PManager();
  WifiP2PGroupInfo? groupInfo;
  bool isHost = false;
  List<DiscoveredPeers> peers = [];
  bool isConnected = false;
  bool isGameStarted = false;
  String me = PLAYER_USERNAME;
  String other = HOST_USERNAME;
  bool isSolo = false;

  factory Manager() {
    return _instance;
  }

  Manager._internal();

  // Initialize and manage the connection and messaging here
  // Inside ConnectionManager
  Future createRoom() async {
    if (!p2p.isInit) p2p.init();
    me = HOST_USERNAME;
    other = PLAYER_USERNAME;
    isHost = true;
    isConnected = false;
    await p2p.init();
    await p2p.host();
    for (var i = 0; i < 10; i++) {
      if (await _startSocket() || isGameStarted) {
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    for (var i = 0; i < 10; i++) {
      if (isGameStarted) {
        break;
      }
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
    me = PLAYER_USERNAME;
    other = HOST_USERNAME;
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
    me = HOST_USERNAME;
    other = PLAYER_USERNAME;
    isHost = true;
    if (!isSolo) {
      await refreshRoom();
    }
    if (isSolo || (groupInfo == null || groupInfo!.clients.length == 1)) {
      isSolo = true;
    }
    sendMessage("start");
    isGameStarted = true;
    init();
    notifyListeners();
    return true;
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
    if (!p2p.isInit) p2p.init();
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
    if (!p2p.isInit) p2p.init();
    log("Disconnecting...");
    await p2p.disconnect();
    await p2p.stopDiscover();
    isConnected = false;
    isGameStarted = false;
    isSolo = false;
    groupInfo = null;
    peers = [];
    clear();
    notifyListeners();
  }

  // Inside ConnectionManager
  void sendMessage(String msg) {
    log("Sending message: $msg");
    p2p.plugin.sendStringToSocket(msg);
    notifyListeners();
  }

  @override
  void set(String key, String value) {
    sendKeyValue(key, value);
    super.set(key, value);
    notifyListeners();
  }

  @override
  void setInt(String key, int value) {
    sendKeyValue(key, value.toString());
    super.setInt(key, value);
    notifyListeners();
  }

  @override
  void setBool(String key, bool value) {
    sendKeyValue(key, value.toString());
    super.setBool(key, value);
    notifyListeners();
  }

  @override
  void setDouble(String key, double value) {
    sendKeyValue(key, value.toString());
    super.setDouble(key, value);
    notifyListeners();
  }

  // Inside ConnectionManager
  void sendKeyValue(String key, String value) {
    log("Sending Key value: $key: $value");
    p2p.plugin.sendStringToSocket("$key:$value");
  }

  void _onReceiveMessage(dynamic message) async {
    if (message == "start") {
      init();
      isGameStarted = true;
      isSolo = false;
      isHost = false;
      me = PLAYER_USERNAME;
      other = HOST_USERNAME;
      notifyListeners();
      return;
    }
    log("Received message: $message");
    // split
    var split = message.split(":");
    if (split.length == 2) {
      super.set(split[0], split[1]);
      notifyListeners();
      return;
    }
    log("Error when receiving message (message.split(\":\").length != 2): $message");
  }
}

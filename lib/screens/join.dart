import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:provider/provider.dart';
import 'package:quesaco/screens/waiting.dart';

import '../services/connection_manager.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _JoinPageState();
  }
}

class _JoinPageState extends State<JoinPage> {
  Manager m = Manager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Manager().discoverRooms();
    });
  }

  Future onRefresh() async {
    Manager().refreshRoom();
  }

  Future onConnect(DiscoveredPeers peer, BuildContext context) async {
    bool success = await Manager().joinRoom(peer);
    log('success: $success');
    if (success) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const WaitingPage()));
    }
  }

  void loadAndPlayMusic(String music) async {
    if (m.audioPlayer.state == PlayerState.playing) {
      return;
    }
    await m.audioCache.load(music);

    m.audioPlayer.play(AssetSource(music));
  }

  @override
  Widget build(BuildContext context) {
    loadAndPlayMusic("musics/main_menu.mp3");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre une room'),
      ),
      body: Consumer<Manager>(builder: (context, m, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text('Les rooms disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          )),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: onRefresh,
                        child: const Text('Actualiser'),
                      ),
                    ],
                  )),
              for (var peer in m.peers)
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      child: ListTile(
                        title: Text(peer.deviceName),
                        subtitle: const Text("Appuyer pour rejoindre"),
                        onTap: () {
                          onConnect(peer, context);
                        },
                      ),
                    ))
            ],
          ),
        );
      }),
    );
  }
}

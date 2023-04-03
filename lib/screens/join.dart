import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import '../p2p/p2p.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _JoinPageState();
  }
}

class _JoinPageState extends State<JoinPage> {
  final p2p = P2PManager();

  @override
  void initState() {
    super.initState();
    p2p.init().then((value) => p2p.discover());
  }

  @override
  void dispose() {
    p2p.stopDiscover();
    super.dispose();
  }

  void onRefresh() async {
    List<DiscoveredPeers> peers = await p2p.getPeers();
    setState(() {
      p2p.peers = peers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Rooms available'),
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Refresh'),
                ),
              ],
            ),
            // foreach peer in p2p.peers
            for (var peer in p2p.peers) Text(peer.deviceName),
          ],
        ),
      ),
    );
  }
}

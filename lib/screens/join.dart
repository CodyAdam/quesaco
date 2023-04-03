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

  List<DiscoveredPeers> peers = [];

  @override
  void initState() {
    super.initState();
    p2p.init().then((value) => p2p.discover());
  }

  @override
  void dispose() {
    p2p.stopDiscover();
    p2p.disconnect();
    super.dispose();
  }

  void onRefresh() async {
    List<DiscoveredPeers> p = await p2p.getPeers();
    setState(() {
      peers = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre une room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Les rooms disponibles',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        )),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: onRefresh,
                      child: const Text('Actualiser'),
                    ),
                  ],
                )),
            for (var peer in peers)
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    child: ListTile(
                      title: Text(peer.deviceName),
                      subtitle: const Text("Appuyer pour rejoindre"),
                      onTap: () {
                        p2p.connect(peer);
                      },
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}

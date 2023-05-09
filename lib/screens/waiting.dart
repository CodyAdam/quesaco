import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import '../p2p/p2p.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WaitingPageState();
  }
}

class _WaitingPageState extends State<WaitingPage> {
  final p2p = P2PManager();
  WifiP2PGroupInfo? info;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    await p2p.init();
    final fetchedInfo = await p2p.groupInfo();
    setState(() {
      info = fetchedInfo;
    });
  }

  @override
  void dispose() {
    p2p.disconnect();
    super.dispose();
  }

  void onRefresh() async {
    final fetchedInfo = await p2p.groupInfo();
    setState(() {
      info = fetchedInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salle d\'attente'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 16.0), // Added this line
                        child: Text(
                          ' ${info != null ?  "Room de ${info!.groupNetworkName}" : "En attente de l'acceptation de l'hôte"}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onRefresh,
                      child: const Text('Actualiser'),
                    ),
                  ],
                )),
            const Spacer(),
            if (info != null)
              Column(
                children: [
                  SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey)),
                            onPressed: null,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: Text("En attente de l'hôte",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24)),
                            )),
                      ))
                ],
              )
          ],
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import '../p2p/p2p.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HostPageState();
  }
}

class _HostPageState extends State<HostPage> {
  final p2p = P2PManager();
  WifiP2PGroupInfo? info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future init() async {
    await p2p.init();
    await p2p.host();
    await onRefresh();
    await onRefresh();
  }

  @override
  void dispose() {
    p2p.disconnect();
    super.dispose();
  }

  Future onRefresh() async {
    final fetchedInfo = await p2p.groupInfo();
    log(fetchedInfo.toString());
    setState(() {
      info = fetchedInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une Room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Les joueurs connectés',
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
            if (info != null)
              for (var client in info!.clients)
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      child: ListTile(
                        title: Text(client.deviceName),
                        subtitle: Text(client.deviceAddress),
                      ),
                    )),
            if (info != null && info!.clients.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(12),
                  child: Card(
                    child: ListTile(
                      title: Text("Personne n'est connecté"),
                    ),
                  ))
            else if (info == null)
              const Padding(
                  padding: EdgeInsets.all(12),
                  child: Card(
                    child: ListTile(
                      title: Text(
                          "Chargement...\n\n Vérifier que vous avez bien accordée la permission NEARBY_WIFI_DEVICES (Android >=13) ou ACCESS_FINE_LOCATION"),
                    ),
                  )),
            const Spacer(),
            if (info != null)
              Column(
                children: [
                  Text(
                    "${info!.clients.length + 1}/4 joueurs",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.green)),
                            onPressed: null,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: Text("Commencer la partie",
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
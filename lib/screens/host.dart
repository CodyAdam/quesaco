import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quesaco/screens/game.dart';
import 'package:quesaco/services/connection_manager.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HostPageState();
  }
}

class _HostPageState extends State<HostPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Manager().createRoom();
    });
  }

  Future onRefresh() async {
    Manager().refreshRoom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Créer une Room'),
        ),
        body: Consumer<Manager>(
          builder: (context, m, child) {
            if (m.isGameStarted) {
              Future.delayed(Duration.zero, () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const GamePage()));
              });
            }
            return Center(
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
                  if (m.groupInfo != null)
                    for (var client in m.groupInfo!.clients)
                      Padding(
                          padding: const EdgeInsets.all(12),
                          child: Card(
                            child: ListTile(
                              title: Text(client.deviceName),
                              subtitle: Text(client.deviceAddress),
                            ),
                          )),
                  if (m.groupInfo != null && m.groupInfo!.clients.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(12),
                        child: Card(
                          child: ListTile(
                            title: Text("Personne n'est connecté"),
                          ),
                        ))
                  else if (m.groupInfo == null)
                    const Padding(
                        padding: EdgeInsets.all(12),
                        child: Card(
                          child: ListTile(
                              title: Text("Chargement..."),
                              subtitle: Text(
                                "Vérifier que vous avez bien accordée la permission NEARBY_WIFI_DEVICES (Android >=13) ou ACCESS_FINE_LOCATION",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 205, 202, 202),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300),
                              )),
                        )),
                  const Spacer(),
                  if (m.groupInfo != null)
                    Column(
                      children: [
                        Text(
                          "${m.groupInfo!.clients.length + 1}/2 joueurs",
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
                                  onPressed: () => Manager().startGame(),
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
            );
          },
        ));
  }
}

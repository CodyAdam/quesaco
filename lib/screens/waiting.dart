import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quesaco/services/connection_manager.dart';

import 'game.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WaitingPageState();
  }
}

class _WaitingPageState extends State<WaitingPage> {
  void onRefresh() async {
    Manager().refreshRoom();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      Manager().refreshRoom();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salle d\'attente'),
      ),
      body: Consumer<Manager>(builder: (context, m, child) {
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
                      Flexible(
                        fit: FlexFit.tight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0), // Added this line
                          child: Text(
                            ' ${m.groupInfo != null ? "Room de ${m.groupInfo!.groupNetworkName}" : "En attente de l'acceptation de l'hôte"}',
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
              if (m.groupInfo != null)
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
        );
      }),
    );
  }
}

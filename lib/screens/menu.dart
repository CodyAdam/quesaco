import 'package:flutter/material.dart';

import '../services/connection_manager.dart';
import 'host.dart';
import 'join.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MenuState();
  }
}

class _MenuState extends State<Menu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Manager().disconnect();
    });
  }

  Future _onNavigateBack() async {
    await Manager().disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Menu principal'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text("Quesaco",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  )),
              const Text("Édition Deluxe 2023",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color.fromARGB(255, 173, 173, 173),
                  )),
              const SizedBox(height: 70),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.lime)),
                    onPressed: () async {
                      // Navigate
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HostPage()),
                      );
                      await _onNavigateBack();
                    },
                    child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Créer une room',
                          style: TextStyle(fontSize: 28),
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green)),
                      onPressed: () async {
                        // Navigate
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const JoinPage()),
                        );
                        await _onNavigateBack();
                      },
                      child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Rejoindre une room',
                            style: TextStyle(fontSize: 28),
                          ))),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("© 2023 Quesaco - Arthur & Cody",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 173, 173, 173),
                    )),
              )
            ],
          ),
        ));
  }
}

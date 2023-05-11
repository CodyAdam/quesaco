
import 'package:flutter/material.dart';
import 'package:quesaco/screens/game.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset("assets/icon/banner.png"),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(5),
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 61, 159, 239))),
                onPressed: () async {
                  // Navigate
                  Manager().isSolo = true;
                  Manager().startGame();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage()),
                  );
                },
                child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Jouer en Solo',
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
                    elevation: MaterialStateProperty.all(5),
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 160, 220, 57))),
                onPressed: () async {
                  // Navigate
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HostPage()),
                  );
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
                      elevation: MaterialStateProperty.all(5),
                      backgroundColor: MaterialStateProperty.all(Colors.green)),
                  onPressed: () async {
                    // Navigate
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JoinPage()),
                    );
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

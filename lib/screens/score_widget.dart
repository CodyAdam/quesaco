import 'package:flutter/material.dart';

import '../services/connection_manager.dart';

class ScoreWidget extends StatelessWidget {
  bool hasWon = false;

  Manager m = Manager();

  ScoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (m.getInt(m.me)! >= m.getInt(m.other)!) {
      hasWon = true;
    }
    // wait 5 sec then call
    Future.delayed(const Duration(seconds: 5), () {
      m.clearGamesData();

      m.goToNextGame();
    });
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 300)),
        Text(
          "Fin de la partie",
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 50),
        if (!m.isSolo) ...[
          Text(
            'Vous avez ${hasWon ? "gagné" : "perdu"} !',
            style: TextStyle(
                fontSize: 32, color: hasWon ? Colors.green : Colors.red),
          ),
          const SizedBox(height: 10),
        ],
        if (m.isSolo) ...[
          Text(
            'Bien joué !',
            style: TextStyle(
                fontSize: 32, color: hasWon ? Colors.green : Colors.red),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          'Votre score : ${m.getInt(m.me)}',
          style: const TextStyle(fontSize: 20),
        ),
        if (!m.isSolo) ...[
          const SizedBox(height: 10),
          Text(
            'Score adverse : ${m.getInt(m.other)}',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ],
    )));
  }
}

import 'package:flutter/material.dart';

import '../services/connection_manager.dart';

class ScoreWidget extends StatelessWidget {
  bool hasWon = false;

  Manager m = Manager();

  ScoreWidget();

  @override
  Widget build(BuildContext context) {
    if(m.getInt(m.me)! >= m.getInt(m.other)!) {
      hasWon = true;
    }
    return Scaffold(
        body: Center(
        child : Column(
      children: [
        Padding(padding: EdgeInsets.only(top: 350)),
        if (!m.isSolo) ...[
        Text(
          'Vous avez ${hasWon ? "gagné" : "perdu"} !',
          style: TextStyle(fontSize: 32, color: hasWon ? Colors.green : Colors.red),
        ),
        SizedBox(height: 10),
        ],
        if (m.isSolo) ...[
          Text(
            'Bien joué !',
            style: TextStyle(fontSize: 32, color: hasWon ? Colors.green : Colors.red),
          ),
          SizedBox(height: 10),
        ],
        Text(
          'Votre score : ${m.getInt(m.me)}',
          style: TextStyle(fontSize: 20),
        ),
        if (!m.isSolo) ...[
          SizedBox(height: 10),
          Text(
            'Score adverse : ${m.getInt(m.other)}',
            style: TextStyle(fontSize: 20),
          ),

        ],
      ],
    )));
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../services/connection_manager.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GamePageState();
  }
}

class _GamePageState extends State<GamePage> {
  nextMinigame(GameState game) {
    game.setInt(MINIGAME_ID, game.getInt(MINIGAME_ID)! + 1);
  }

  addPointToPlayer(GameState game, String playerName, int amount) {
    game.setInt(playerName, game.getInt(playerName)! + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Manager>(builder: (context, m, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Minigame ${m.getInt(MINIGAME_ID)}"),
        ),
        body: Center(
          child: Column(
            // fill height
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Minigame id : ${m.getInt(MINIGAME_ID)}"),
              Text("My score : ${m.getInt(m.me)}"),
              Text("Other score : ${m.getInt(m.other)}"),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () => nextMinigame(m),
                    child: const Text('Next minigame (+1)'),
                  ),
                ],
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () => addPointToPlayer(m, m.me, 1),
                    child: const Text('Add points to me (+1)'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

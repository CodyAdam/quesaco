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
    game.nextMiniGame();
  }

  addPointToPlayer(GameState game, String playerName, int amount) {
    game.updateScore(playerName, (game.scores[playerName] ?? 0) + amount);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Manager>(builder: (context, m, child) {
      var game = m.gameState!;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Menu principal'),
        ),
        body: Center(
          child: Column(
            // fill height
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Minigame id : ${game.currentMiniGameIndex}"),
              Text("Players count : ${game.players.length}"),
              Text("Scores : ${game.scores.toString()}"),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () => nextMinigame(game),
                    child: const Text('Next minigame (+1)'),
                  ),
                ],
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () => addPointToPlayer(game, m.me, 1),
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

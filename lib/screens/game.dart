import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../services/connection_manager.dart';
import '../widget/card.dart';
import '../widget/score_bar.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GamePageState();
  }
}

class _GamePageState extends State<GamePage> {
  void selectGame(GameState game, int id) {
    game.setInt(MINIGAME_ID, id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Manager>(builder: (context, game, child) {
      if (game.getInt(MINIGAME_ID) == 1) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 1"),
            bottomNavigationBar: gameScoreBar(game));
      } else if (game.getInt(MINIGAME_ID) == 2) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 2"),
            bottomNavigationBar: gameScoreBar(game));
      } else if (game.getInt(MINIGAME_ID) == 3) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 3"),
            bottomNavigationBar: gameScoreBar(game));
      } else if (game.getInt(MINIGAME_ID) == 4) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 4"),
            bottomNavigationBar: gameScoreBar(game));
      } else if (game.getInt(MINIGAME_ID) == 5) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 5"),
            bottomNavigationBar: gameScoreBar(game));
      } else if (game.getInt(MINIGAME_ID) == 6) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 6"),
            bottomNavigationBar: gameScoreBar(game));
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Selectionnez un jeu"),
          ),
          body: Center(
            child: GridView.builder(
              itemCount: 6,
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (BuildContext context, int index) {
                return gameImageCard(() => selectGame(game, index + 1),
                    'assets/images/thumb_game_${index + 1}.png');
              },
            ),
          ),
          bottomNavigationBar: gameScoreBar(game),
        );
      }
    });
  }
}

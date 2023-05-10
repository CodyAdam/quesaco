import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quesaco/games/game3.dart';

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
  void selectGame(int id) {
    Manager().setInt(MINIGAME_ID, id);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Manager, int>(
        selector: (_, m) => m.getInt(MINIGAME_ID) ?? 0,
        builder: (context, id, child) {
          if (id == 1) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Minigame $id"),
                  automaticallyImplyLeading: false,
                ),
                body: const Text("Game 1"),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 2) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Minigame $id"),
                  automaticallyImplyLeading: false,
                ),
                body: const Text("Game 2"),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 3) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Minigame $id"),
                  automaticallyImplyLeading: false,
                ),
                body: GameWidget(game: Game3()),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 4) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Minigame $id"),
                  automaticallyImplyLeading: false,
                ),
                body: const Text("Game 4"),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 5) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Minigame $id"),
                  automaticallyImplyLeading: false,
                ),
                body: const Text("Game 5"),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 6) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Minigame $id"),
                  automaticallyImplyLeading: false,
                ),
                body: const Text("Game 6"),
                bottomNavigationBar: gameScoreBar(context));
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
                    return gameImageCard(() => selectGame(index + 1),
                        'assets/images/thumb_game_${index + 1}.png');
                  },
                ),
              ),
              bottomNavigationBar: gameScoreBar(context),
            );
          }
        });
  }
}

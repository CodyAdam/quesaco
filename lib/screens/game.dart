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
  @override
  void initState() {
    super.initState();
  }

  void selectGame(GameState game, int id) {
    game.setInt(MINIGAME_ID, id);
  }

  Card _buildCardButton(BuildContext context, int id, String imagePath) {
    final game = Provider.of<Manager>(context, listen: false);
    return Card(
      child: InkWell(
        onTap: () => selectGame(game, id),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
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
            body: const Text("Game 1"));
      } else if (game.getInt(MINIGAME_ID) == 2) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 2"));
      } else if (game.getInt(MINIGAME_ID) == 3) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 3"));
      } else if (game.getInt(MINIGAME_ID) == 4) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 4"));
      } else if (game.getInt(MINIGAME_ID) == 5) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 5"));
      } else if (game.getInt(MINIGAME_ID) == 6) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Minigame ${game.getInt(MINIGAME_ID)}"),
              automaticallyImplyLeading: false,
            ),
            body: const Text("Game 6"));
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Selectionnez un jeu"),
          ),
          body: Center(
            child: GridView.builder(
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _buildCardButton(context, index + 1,
                    'assets/images/thumb_game_${index + 1}.png');
              },
            ),
          ),
        );
      }
    });
  }
}

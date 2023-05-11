import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quesaco/games/game3.dart';
import 'package:quesaco/games/music_quizz.dart';

import '../games/emoji_widget.dart';
import '../games/flag_quizz.dart';
import '../games/game4.dart';
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
          if(Manager().audioPlayer.state == PlayerState.playing) {
            Manager().audioPlayer.stop();
          }
          if (id == 1) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Quel est ce pays ?"),
                  automaticallyImplyLeading: false,
                ),
                body: const Flag(),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 2) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Quel est ce jeu vidéo ?"),
                  automaticallyImplyLeading: false,
                ),
                body: const Music(),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 3) {
            return Scaffold(
                body: GameWidget(game: Game3()),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 4) {
            return Scaffold(
                body: GameWidget(game: Game4()),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == 5) {
            return Scaffold(
                body: EmojiGame(),
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

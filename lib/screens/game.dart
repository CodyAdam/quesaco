import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quesaco/games/game3.dart';
import 'package:quesaco/games/music_quizz.dart';
import 'package:quesaco/screens/score_widget.dart';

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
    List<String> gamesIdShuffled = [];
    for (int i = 1; i <= 6; i++) {
      gamesIdShuffled.add(i.toString());
    }
    gamesIdShuffled.shuffle();
    return Selector<Manager, int>(
        selector: (_, m) => m.getInt(MINIGAME_ID) ?? 0,
        builder: (context, id, child) {
          if (Manager().audioPlayer.state == PlayerState.playing) {
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
                body: EmojiGame(), bottomNavigationBar: gameScoreBar(context));
          } else if (id == 6) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Minigame $id"),
                  automaticallyImplyLeading: false,
                ),
                body: const Text("Game 6"),
                bottomNavigationBar: gameScoreBar(context));
          } else if (id == -1) {
            return Scaffold(
                body: ScoreWidget(),
                bottomNavigationBar: gameScoreBar(context));
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Selectionnez un jeu"),
              ),
              body: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.5 *
                                  .8 *
                                  2.2,
                              height: MediaQuery.of(context).size.width * 0.5,
                              child: gameImageCard(
                                  () => {
                                        Manager().set(UPCOMING_MINIGAMES_ID,
                                            gamesIdShuffled.join(",")),
                                        Manager().goToNextGame(),
                                      },
                                  'assets/images/thumb_random.png'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.5 *
                                  0.8, // Adjust the width as needed
                              height: MediaQuery.of(context).size.width *
                                  0.5, // Calculate height based on the width and aspect ratio
                              child: gameImageCard(() => selectGame(1),
                                  'assets/images/thumb_game_1.png'),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 * .8,
                              height: MediaQuery.of(context).size.width * 0.5,
                              child: gameImageCard(() => selectGame(2),
                                  'assets/images/thumb_game_2.png'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 * .8,
                              height: MediaQuery.of(context).size.width * 0.5,
                              child: gameImageCard(() => selectGame(3),
                                  'assets/images/thumb_game_3.png'),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 * .8,
                              height: MediaQuery.of(context).size.width * 0.5,
                              child: gameImageCard(() => selectGame(4),
                                  'assets/images/thumb_game_4.png'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 * .8,
                              height: MediaQuery.of(context).size.width * 0.5,
                              child: gameImageCard(() => selectGame(5),
                                  'assets/images/thumb_game_5.png'),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 0.5 * .8,
                              height: MediaQuery.of(context).size.width * 0.5,
                              child: gameImageCard(() => selectGame(6),
                                  'assets/images/thumb_game_6.png'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              bottomNavigationBar: gameScoreBar(context),
            );
          }
        });
  }
}

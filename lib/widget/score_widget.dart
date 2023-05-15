import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../services/connection_manager.dart';

Widget scoreWidget() {
  bool hasWon = false;

  Manager m = Manager();

  void loadAndPlayMusic(String music) async {
    if (m.audioPlayer.state == PlayerState.playing) {
      return;
    }
    await m.audioCache.load(music);

    m.audioPlayer.play(AssetSource(music));
  }

  if (!m.hasUpcomingGames()) {
    if (m.getInt(m.me)! >= m.getInt(m.other)!) {
      hasWon = true;
    }
    if (m.isSolo) {
      hasWon = true;
    }

    if (hasWon) {
      loadAndPlayMusic("musics/win.mp3");
    } else {
      loadAndPlayMusic("musics/lost.mp3");
    }
  }

  // wait 5 sec then call
  Future.delayed(Duration(seconds: m.hasUpcomingGames() ? 0 : 5), () {
    m.clearGamesData();
    if (m.isHost) {
      m.goToNextGame();
    }
  });
  if (m.hasUpcomingGames()) {
    return const Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }
  return Scaffold(
      body: Center(
          child: Column(
    children: [
      const Padding(padding: EdgeInsets.only(top: 300)),
      const Text(
        "Fin de la partie",
        style: TextStyle(fontSize: 40),
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

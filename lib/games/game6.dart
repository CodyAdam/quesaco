// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:math' hide log;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:quesaco/models/game_state.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../services/connection_manager.dart';

class Game6 extends FlameGame with DragCallbacks {
  Manager m = Manager();
  Random r = Random(Manager().getInt(SEED) ?? 0);
  late Image playerImg;
  SpriteComponent? player;

  TimerComponent? timer;
  TimerComponent? timerStart;

  TextComponent? timerText;
  TextComponent? timerCount;

  int lvl = 0;

  double t = 0;

  int countup = 0;
  bool isPlaying = false;

  double gyro = 0;
  late StreamSubscription<MagnetometerEvent> _gyroStream;

  @override
  Color backgroundColor() => const Color.fromARGB(0, 248, 249, 249);

  Future startSequence() async {
    cleanUpLevel();

    var instructionTitle = TextComponent(
      text: 'Tourner pour alligner!',
      position: Vector2(size.x / 2, size.y / 2 - 25),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color.fromARGB(255, 52, 52, 55),
          fontSize: 32.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
      size: Vector2.all(13),
    );
    var countdown = 3;
    var timerText = TextComponent(
      text: countdown.toString(),
      position: Vector2(size.x / 2, size.y / 2 + 40),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color.fromARGB(255, 52, 52, 55),
          fontSize: 60.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
    );

    add(instructionTitle);
    add(timerText);
    timerStart = TimerComponent(
        period: 1,
        repeat: true,
        removeOnFinish: true,
        onTick: () async {
          countdown--;
          timerText.text = countdown.toString();
          if (countdown <= 0) {
            remove(instructionTitle);
            remove(timerText);
            remove(timerStart!);
            await startLevel();
          }
        });
    add(timerStart!);
  }

  Future startLevel() async {
    // start timer text
    timerText = TextComponent(
      text: 'Temps de survie',
      position: Vector2(size.x / 2, size.x * .2),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color.fromARGB(255, 52, 52, 55),
          fontSize: 32.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
      size: Vector2.all(18),
    );
    timerCount = TextComponent(
      text: "${countup}s",
      position: Vector2(size.x / 2, size.x * .2 + 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color.fromARGB(255, 52, 52, 55),
          fontSize: 32.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
      size: Vector2.all(13),
    );

    add(timerText!);
    add(timerCount!);
    isPlaying = true;
    timer = TimerComponent(
        period: 1,
        repeat: true,
        removeOnFinish: true,
        onTick: () async {
          countup++;
          if (timerCount != null) {
            timerCount!.text = "${countup}s";
          }
        });
    add(timer!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    t += dt;
    // change text
    if (timerText != null) {
      timerText!.text = gyro.toString().characters.take(5).toString();
    }

    if (player != null) {
      // easing to gyro in degree
      player!.angle =
          lerpDouble(player!.angle * 180 / pi, gyro, 0.1)! * pi / 180;
    }
  }

  void cleanUpLevel() {
    timer = null;
    if (timerText != null) {
      remove(timerText!);
    }
    timerText = null;
    if (timerCount != null) {
      remove(timerCount!);
    }
  }

  void loadAndPlayMusic(String music) async {
    if (m.audioPlayer.state == PlayerState.playing) {
      return;
    }
    await m.audioCache.load(music);

    m.audioPlayer.play(AssetSource(music));
  }

  void endTheGame() async {
    _gyroStream.cancel();
    isPlaying = false;
    m.audioPlayer.stop();
    if (timer != null) {
      timer!.timer.stop();
    }

    var addScore = countup * 10;
    var endText = TextComponent(
      text: 'Vous avez survécu ${countup}s',
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
    );
    var endTextScore = TextComponent(
      text: '+${countup * 10} points',
      position: Vector2(size.x / 2, size.y / 2 + 25),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
    );

    m.setInt(m.me, m.getInt(m.me)! + addScore);
    add(endText);
    add(endTextScore);
    await Future.delayed(const Duration(seconds: 4));
    cleanUpLevel();
    m.clearGamesData();
    m.setInt(MINIGAME_ID, -1);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    m.audioPlayer.stop();

    playerImg = await images.load('Grimacing Face.png');
    player = SpriteComponent.fromImage(playerImg,
        position: Vector2(size.x / 2, size.y / 2),
        size: Vector2.all(100),
        anchor: Anchor.center);
    add(player!);
    _gyroStream = magnetometerEvents.listen((MagnetometerEvent event) {
      gyro = event.y;
    });
    await startSequence();

    loadAndPlayMusic("musics/game.mp3");
  }
}

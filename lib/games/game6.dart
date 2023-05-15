// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:developer';
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

const SENSOR_SENSIBILITY = 2;

class Game6 extends FlameGame with TapCallbacks {
  Manager m = Manager();
  Random r = Random(Manager().getInt(SEED) ?? 0);
  late Image playerImg;
  SpriteComponent? player;
  double playerSpeed = 1;

  TimerComponent? timer;
  TimerComponent? timerStart;

  TextComponent? timerText;
  TextComponent? timerCount;

  int countup = 0;
  bool isPlaying = false;

  double speedX = 0;
  double speedY = 0;
  late StreamSubscription<GyroscopeEvent> _gyroStream;

  List<Map> maps = [];
  Map? current;

  @override
  Color backgroundColor() => const Color.fromARGB(0, 248, 249, 249);

  Future startSequence() async {
    cleanUpLevel();

    var instructionTitle = TextComponent(
      text: 'Complète la photo !',
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
    if (current != null) {
      add(current!);
      addAll(current!.targets);
    }

    // start timer text
    timerText = TextComponent(
      text: 'Temps',
      position: Vector2(size.x / 2, size.x * .2),
      textRenderer: TextPaint(
        style: const TextStyle(
          backgroundColor: Color.fromARGB(180, 52, 52, 55),
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 32.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
      size: Vector2.all(18),
    );
    timerCount = TextComponent(
      text: "${countup}s",
      position: Vector2(size.x / 2, size.x * .2 + 45),
      textRenderer: TextPaint(
        style: const TextStyle(
          backgroundColor: Color.fromARGB(180, 52, 52, 55),
          color: Color.fromARGB(255, 255, 255, 255),
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

    // dark outline
    player = SpriteComponent.fromImage(playerImg,
        position: Vector2(size.x / 2, size.y * .8),
        size: Vector2.all(100),
        anchor: Anchor.center);
    add(player!);
    speedX = 0;
    speedY = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) {
      return;
    }
    if (player != null && current != null) {
      player!.position.x += speedX;
      player!.position.y += speedY;

      player!.angle = lerpDouble(player!.angle, speedX * 0.1, 0.1) ?? 0;

      // clamp in screen
      player!.position.x = player!.position.x
          .clamp(0 + player!.size.x / 2, size.x - player!.size.x / 2);
      player!.position.y = player!.position.y
          .clamp(0 + player!.size.y / 2, size.y - player!.size.y / 2);

      for (var target in current!.targets) {
        if (target.isDone) {
          continue;
        }
        var dist = player!.position.distanceTo(target.position);
        if (dist < target.size.x / 2) {
          target.isDone = true;
          target.paint = Paint()..colorFilter = null;
        }
      }
      if (current!.targets.every((element) => element.isDone)) {
        endTheGame();
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) async {
    if (player == null || !isPlaying) {
      return;
    }
    speedX = 0;
    speedY = 0;
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
    if (player != null) {
      remove(player!);
    }
    isPlaying = false;
    m.audioPlayer.stop();
    if (timer != null) {
      timer!.timer.stop();
    }

    var addScore = (10 - countup) * 100;
    var endText = TextComponent(
      text: 'Vous mis ${countup}s',
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(
          backgroundColor: Color.fromARGB(180, 52, 52, 55),
          fontSize: 18.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
    );
    var endTextScore = TextComponent(
      text: '+$addScore points',
      position: Vector2(size.x / 2, size.y / 2 + 35),
      textRenderer: TextPaint(
        style: const TextStyle(
          backgroundColor: Color.fromARGB(180, 52, 52, 55),
          fontSize: 32.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
    );

    m.setInt(m.me, m.getInt(m.me)! + addScore);
    add(endText);
    add(endTextScore);

    m.setBool("${m.me}_game6_finished", true);
    if (!m.isSolo) {
      for (var i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (m.getBool("${m.other}_game6_finished") ?? false) {
          break;
        }
      }
    }
    await Future.delayed(const Duration(seconds: 4));
    cleanUpLevel();
    m.clearGamesData();
    m.setInt(MINIGAME_ID, -1);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    m.audioPlayer.stop();

    playerImg = await images.load('Face with Raised Eyebrow.png');
    var fillImg = await images.load('Face with Raised Eyebrow.png');
    _gyroStream = gyroscopeEvents.listen((GyroscopeEvent event) {
      speedX += event.y * SENSOR_SENSIBILITY;
      speedY += event.x * SENSOR_SENSIBILITY;
    });

    var map1Img = await images.load('map2.jpg');
    var map1Size = Vector2(size.y * (map1Img.width / map1Img.height), size.y);
    var map1 = Map(map1Img, map1Size, Vector2(size.x / 2, size.y / 2));
    map1.targets.add(Target(fillImg, 0.13, Vector2(0, 0), map1Size, size));
    map1.targets.add(Target(fillImg, 0.12, Vector2(.04, -.48), map1Size, size));
    map1.targets.add(Target(fillImg, 0.11, Vector2(-.25, -.3), map1Size, size));
    map1.targets.add(Target(fillImg, 0.18, Vector2(.3, .1), map1Size, size));
    maps.add(map1);

    var map2Img = await images.load('map1.jpg');
    var map2Size = Vector2(size.y * (map2Img.width / map2Img.height), size.y);
    var map2 = Map(map2Img, map2Size, Vector2(size.x / 2, size.y / 2));
    map2.targets
        .add(Target(fillImg, 0.2, Vector2(0.16, -0.09), map2Size, size));
    map2.targets
        .add(Target(fillImg, 0.25, Vector2(-0.33, -0.16), map2Size, size));
    maps.add(map2);

    current = maps[r.nextInt(maps.length)];

    await startSequence();
    loadAndPlayMusic("musics/game.mp3");

  }
}

class Map extends SpriteComponent {
  List<Target> targets = [];
  Map(Image image, Vector2 size, Vector2 position)
      : super.fromImage(image, size: size, position: position) {
    anchor = Anchor.center;
  }
}

class Target extends SpriteComponent {
  bool isDone = false;
  Vector2 mapSize;
  Vector2 canvasSize;
  Target(Image image, double size, Vector2 positionRel, this.mapSize,
      this.canvasSize)
      : super.fromImage(image,
            size: Vector2(50, 50), position: Vector2.zero()) {
    this.size = Vector2.all(size) * canvasSize.y;
    position = Vector2(
      canvasSize.x / 2 + mapSize.x * positionRel.x / 2,
      canvasSize.y / 2 + mapSize.y * positionRel.y / 2,
    );
    anchor = Anchor.center;
    var opa = 0.0;
    paint = Paint()
      ..colorFilter = ColorFilter.matrix([
        opa,
        0,
        0,
        0,
        0,
        0,
        opa,
        0,
        0,
        0,
        0,
        0,
        opa,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]);
  }
}

class Map extends SpriteComponent {
  List<Target> targets = [];
  Map(Image image, Vector2 size, Vector2 position)
      : super.fromImage(image, size: size, position: position) {
    anchor = Anchor.center;
  }
}

class Target extends SpriteComponent {
  bool isDone = false;
  Vector2 mapSize;
  Vector2 canvasSize;
  Target(Image image, double size, Vector2 positionRel, this.mapSize,
      this.canvasSize)
      : super.fromImage(image,
            size: Vector2(50, 50), position: Vector2.zero()) {
    this.size = Vector2.all(size) * canvasSize.y;
    position = Vector2(
      canvasSize.x / 2 + mapSize.x * positionRel.x / 2,
      canvasSize.y / 2 + mapSize.y * positionRel.y / 2,
    );
    anchor = Anchor.center;
    var opa = 0.0;
    paint = Paint()
      ..colorFilter = ColorFilter.matrix([
        opa,
        0,
        0,
        0,
        0,
        0,
        opa,
        0,
        0,
        0,
        0,
        0,
        opa,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]);
  }
}

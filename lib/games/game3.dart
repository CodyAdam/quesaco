import 'dart:async';
import 'dart:math' hide log;

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:quesaco/models/game_state.dart';

import '../services/connection_manager.dart';

class Game3 extends FlameGame with TapCallbacks {
  Manager m = Manager();
  late Image wantedImage;
  List<Image> faces = [];
  TimerComponent? timer;
  TimerComponent? timerStart;

  SpriteComponent? wantedSprite;
  TextComponent? timerText;
  TextComponent? timerCount;

  SpriteComponent? suspectSprite;
  Face? suspect;
  int level = 1;
  List<Face> fakes = [];
  bool isPlaying = false;

  Future startSequence() async {
    cleanUpLevel();
    var instructionLevel = TextComponent(
      text: 'Niveau $level',
      position: Vector2(size.x / 2, size.y / 2 - 70),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 60.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
      size: Vector2.all(13),
    );
    var instructionTitle = TextComponent(
      text: 'Toucher sur le suspect!',
      position: Vector2(size.x / 2, size.y / 2 - 25),
      textRenderer: TextPaint(
        style: const TextStyle(
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
          fontSize: 60.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
    );

    add(instructionLevel);
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
            remove(instructionLevel);
            remove(timerText);
            remove(timerStart!);
            await startLevel();
          }
        });
    add(timerStart!);
  }

  Future startLevel() async {
    wantedSprite = SpriteComponent.fromImage(
      wantedImage,
      size: Vector2(size.y * .2, size.y * .2),
      anchor: Anchor.center,
    );
    wantedSprite!.position = Vector2(size.x / 2, wantedSprite!.height / 2);
    add(wantedSprite!);

    var countdown = 25;
    // start timer text
    timerText = TextComponent(
      text: 'Temps restant',
      position: Vector2(size.x / 2, wantedSprite!.height + 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32.0,
          fontFamily: 'Josefa Rounded',
        ),
      ),
      anchor: Anchor.center,
      size: Vector2.all(18),
    );
    timerCount = TextComponent(
      text: "${countdown}s",
      position: Vector2(size.x / 2, wantedSprite!.height + 70),
      textRenderer: TextPaint(
        style: const TextStyle(
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
          countdown--;
          if (timerCount != null) {
            timerCount!.text = "${countdown}s";
          }
          if (countdown <= 0) {
            if (timerCount != null) {
              timerCount!.text = "Temps écoulé";
            }
            timer!.timer.stop();
            revealSuspect();
          }
        });
    add(timer!);
    var count = 100;
    if (level == 2) {
      count = 200;
    } else if (level == 3) {
      count = 250;
    } else if (level == 4) {
      count = 350;
    } else if (level == 5) {
      count = 300;
    }

    var suspectImage = faces[Random().nextInt(faces.length)];
    for (var i = 0; i < count; i++) {
      // random position between 0 and 1
      var randomPosition = Vector2(
          Random().nextDouble() * size.x * .9,
          Random().nextDouble() * size.x * .7 +
              size.y -
              size.x * .7 -
              size.x * .2);
      var speed = 0;
      if (level == 3) {
        speed = 10;
      } else if (level == 4) {
        speed = 20;
      } else if (level == 5) {
        speed = 40;
      }
      var image = faces[Random().nextInt(faces.length)];
      while (image == suspectImage) {
        image = faces[Random().nextInt(faces.length)];
      }

      var face = Face(
          image,
          randomPosition,
          speed.toDouble(),
          size.x * .1,
          Vector2(0 * size.x * .9,
              0 * size.x * .7 + size.y - size.x * .7 - size.x * .2),
          Vector2(1 * size.x * .9,
              1 * size.x * .7 + size.y - size.x * .7 - size.x * .2));
      if (i == count ~/ 2) {
        suspect = Face(
            suspectImage,
            randomPosition,
            speed.toDouble(),
            size.x * .1,
            Vector2(0 * size.x * .9,
                0 * size.x * .7 + size.y - size.x * .7 - size.x * .2),
            Vector2(1 * size.x * .9,
                1 * size.x * .7 + size.y - size.x * .7 - size.x * .2));

        add(suspect!);
      } else {
        fakes.add(face);
        add(face);
      }
    }

    suspectSprite = SpriteComponent.fromImage(suspectImage);
    suspectSprite!.position = wantedSprite!.position;
    suspectSprite!.size = wantedSprite!.size;
    suspectSprite!.anchor = Anchor.center;
    add(suspectSprite!);
  }

  void revealSuspect() async {
    if (timer != null && timerText != null) {
      timer!.timer.stop();
      var winnerText = m.getString("find_${level}_winner");
      if (winnerText != null) {
        timerText!.text =
            "Bien joué à ${winnerText == m.me ? "moi" : "l'autre"}";
      } else {
        timerText!.text = "Personne n'a trouvé";
      }
    }
    for (var face in fakes) {
      remove(face);
    }
    fakes.clear();

    isPlaying = false;
    await Future.delayed(const Duration(seconds: 4));
    cleanUpLevel();
    nextLevel();
  }

  void nextLevel() {
    cleanUpLevel();
    level++;
    if (level > 5) {
      endTheGame();
    }
    startSequence();
  }

  @override
  void onTapDown(TapDownEvent event) async {
    if (suspect == null || !isPlaying) {
      return;
    }

    var pos = event.canvasPosition;
    var distToSuspect = (pos - suspect!.position).distanceTo(Vector2.zero());
    if (distToSuspect <= size.x * .1) {
      m.set("find_${level}_winner", m.me);
      revealSuspect();
      m.setInt(m.me, (m.getInt(m.me) ?? 0) + (1000 ~/ 5));
    }
  }

  @override
  void update(double dt) async {
    super.update(dt);
    var winner = m.getString("find_${level}_winner");
    if (winner != null && isPlaying) {
      revealSuspect();
    }
  }

  void cleanUpLevel() {
    if (suspect != null) {
      remove(suspect!);
    }
    suspect = null;
    if (suspectSprite != null) {
      remove(suspectSprite!);
    }
    suspectSprite = null;
    for (var face in fakes) {
      remove(face);
    }
    fakes.clear();
    if (timer != null) {
      timer!.timer.stop();
      remove(timer!);
    }
    timer = null;
    if (timerText != null) {
      remove(timerText!);
    }
    timerText = null;
    if (timerCount != null) {
      remove(timerCount!);
    }
    timerCount = null;
    if (wantedSprite != null) {
      remove(wantedSprite!);
    }
    wantedSprite = null;
  }

  void endTheGame() {
    cleanUpLevel();
    m.clearGamesData();
    m.setInt(MINIGAME_ID, 0);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    wantedImage = await images.load('wanted.jpg');
    faces.add(await images.load('face1.png'));
    faces.add(await images.load('face2.png'));
    faces.add(await images.load('face3.png'));
    faces.add(await images.load('face4.png'));
    faces.add(await images.load('face5.png'));
    await startSequence();
  }
}

class Face extends SpriteComponent {
  Vector2 direction = Vector2(0, 0);
  double countdownDirection = 0;
  double speed = 0;
  Vector2 boundTopLeft = Vector2(0, 0);
  Vector2 boundBottomRight = Vector2(0, 0);
  Face(Image image, Vector2 position, this.speed, double size,
      this.boundTopLeft, this.boundBottomRight)
      : super.fromImage(image, size: Vector2(size, size), position: position) {
    // random direction between -1 and 1
    direction = Vector2(Random().nextDouble() - .5, Random().nextDouble() - .5)
        .normalized();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (speed == 0) {
      return;
    }
    countdownDirection -= dt;
    if (countdownDirection <= 0) {
      countdownDirection = Random().nextDouble() * 2;
      direction =
          Vector2(Random().nextDouble() - .5, Random().nextDouble() - .5)
              .normalized();
    }
    position += direction * speed * dt;
    if (position.x < boundTopLeft.x) {
      position.x = boundTopLeft.x;
      direction.x = -direction.x;
    }
    if (position.x > boundBottomRight.x) {
      position.x = boundBottomRight.x;
      direction.x = -direction.x;
    }
    if (position.y < boundTopLeft.y) {
      position.y = boundTopLeft.y;
      direction.y = -direction.y;
    }
    if (position.y > boundBottomRight.y) {
      position.y = boundBottomRight.y;
      direction.y = -direction.y;
    }
  }
}

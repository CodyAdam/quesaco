import 'dart:async';
import 'dart:math' hide log;

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:quesaco/models/game_state.dart';

import '../services/connection_manager.dart';

class Game4 extends FlameGame with TapCallbacks {
  Manager m = Manager();
  late Image lavaImg;
  late Image rockImg;
  late Image fireBallImg;
  TimerComponent? timer;
  TimerComponent? timerStart;

  SpriteComponent? lavaSprite;
  SpriteComponent? rockSprite;
  TextComponent? timerText;
  TextComponent? timerCount;
  double t = 0;

  int countup = 0;

  bool isPlaying = false;

  Future startSequence() async {
    cleanUpLevel();

    var instructionTitle = TextComponent(
      text: 'Bouger pour survivre!',
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
    lavaSprite = SpriteComponent.fromImage(
      lavaImg,
      size: Vector2(size.x * 1.5, size.x * 3),
      anchor: Anchor.center,
    );
    lavaSprite!.position = Vector2(size.x / 2, size.y / 2);
    add(lavaSprite!);
    rockSprite = SpriteComponent.fromImage(
      rockImg,
      size: Vector2(size.x * .8, size.x * .8),
      anchor: Anchor.center,
    );
    rockSprite!.position = Vector2(size.x / 2, size.y / 2);
    add(rockSprite!);

    // start timer text
    timerText = TextComponent(
      text: 'Temps de survie',
      position: Vector2(size.x / 2, size.x * .1),
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
      text: "${countup}s",
      position: Vector2(size.x / 2, size.x * .1 + 30),
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
          countup++;
          if (timerCount != null) {
            timerCount!.text = "${countup}s";
          }
        });
    add(timer!);

    for (var i = 0; i < 10; i++) {
      if (isPlaying) {
        add(Fireball(fireBallImg, size, 50));
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    t += dt;

    if (rockSprite != null) {
      final offsetX =
          .4 * size.x * .01 * cos(t * 3) + .2 * size.x * .01 * cos(t * 9);
      final offsetY =
          .5 * size.x * .01 * cos(t * 7) + 1.2 * size.x * .01 * cos(t * 3);
      final rotation = 0.03 * sin(t * 2) + 0.01 * sin(t * 1);
      final scale = 0.01 * sin(t * 1.8) + 0.01 * sin(t * 3);
      rockSprite!.position = (size / 2) + Vector2(offsetX, offsetY);
      rockSprite!.scale = Vector2.all(1 + scale);
      rockSprite!.angle = rotation;
    }

    if (lavaSprite != null) {
      final offsetX = .01 * size.x * cos(t * 3) + size.x * .15 * cos(t * .75);
      final offsetY =
          .1 * size.x * .01 * cos(t * 7) + .25 * size.x * cos(t * .3);
      lavaSprite!.position = (size / 2) + Vector2(offsetX, offsetY);
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
    timerCount = null;
  }

  void endTheGame() {
    cleanUpLevel();
    m.clearGamesData();
    m.setInt(MINIGAME_ID, 0);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    lavaImg = await images.load('lava.jpg');
    rockImg = await images.load('rock.png');
    fireBallImg = await images.load('fireball.png');

    await startSequence();
  }
}

Vector2 getRandomPointOutside(Vector2 size) {
  double margin = size.x * .2;
  if (Random().nextBool()) {
    // top or bottom
    if (Random().nextBool()) {
      // top
      return Vector2(Random().nextDouble() * size.x - margin, 0);
    } else {
      // bottom
      return Vector2(Random().nextDouble() * size.x + margin, size.y);
    }
  } else {
    // left or right
    if (Random().nextBool()) {
      // left
      return Vector2(0, Random().nextDouble() * size.y - margin);
    } else {
      // right
      return Vector2(size.x, Random().nextDouble() * size.y + margin);
    }
  }
}

Vector2 getRandomPointInside(Vector2 size) {
  final boundTopLeft = (size / 2) - Vector2(size.x * .75 / 2, size.x * .75 / 2);
  return boundTopLeft + Vector2.random() * size.x * .75;
}

Vector2 directionFromTo(Vector2 from, Vector2 to) {
  return (to - from).normalized();
}

class Fireball extends SpriteComponent {
  final double speed;
  final Vector2 psize;
  late Vector2 direction;
  Fireball(Image img, this.psize, this.speed)
      : super.fromImage(img,
            size: Vector2.all(psize.x * .1),
            position: getRandomPointOutside(psize)) {
    direction = directionFromTo(position, getRandomPointInside(psize));
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;
    angle += 4 * dt;
  }
}

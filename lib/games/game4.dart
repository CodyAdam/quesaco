// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:math' hide log;

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:quesaco/models/game_state.dart';

import '../services/connection_manager.dart';


class Game4 extends FlameGame with DragCallbacks {
  Manager m = Manager();
  late Image lavaImg;
  late Image rockImg;
  late Image otherImg;
  late Image fireBallImg;
  late Image playerImg;
  Random r = Random(Manager().getInt(SEED) ?? 0);

  TimerComponent? timer;
  TimerComponent? timerStart;
  TimerComponent? timerPositionLoop;
  TimerComponent? timerFireball;

  SpriteComponent? lavaSprite;
  SpriteComponent? rockSprite;
  TextComponent? timerText;
  TextComponent? timerCount;
  bool isDragging = false;
  double t = 0;
  Player? player;
  Player? other;
  int countup = 0;
  bool isPlaying = false;
  List<Fireball> fireballs = [];
  bool isAlive = true;

  @override
  Color backgroundColor() => const Color.fromARGB(0, 248, 249, 249);

  Future startSequence() async {
    cleanUpLevel();

    var instructionTitle = TextComponent(
      text: 'Bouger pour survivre!',
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
      position: Vector2(size.x / 2, size.x * .2),
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
      position: Vector2(size.x / 2, size.x * .2 + 30),
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

    timerFireball = TimerComponent(
        period: 1,
        repeat: true,
        removeOnFinish: true,
        onTick: () async {
          if (isPlaying) {
            for (var i = 0; i < countup ~/ 10 + 1; i++) {
              var f = Fireball(fireBallImg, size,
                  size.x / 400 * (countup > 20 ? 200 : 100), fireballs, this);
              fireballs.add(f);
              add(f);
            }
          }
        });
    add(timerFireball!);

    if (!m.isSolo) {
      other = Player(otherImg, size, this);
      add(other!);
    }
    player = Player(playerImg, size, this);
    add(player!);
    timerPositionLoop = TimerComponent(
        period: 0.1,
        repeat: true,
        removeOnFinish: true,
        onTick: () async {
          if (isPlaying && player != null) {
            var topLeftBound =
                (size / 2) - Vector2(size.x * .75 / 2, size.x * .75 / 2);
            Vector2 pos = (player!.position - topLeftBound) / (size.x * .75);
            m.setDouble("${m.me}_posx", pos.x);
            m.setDouble("${m.me}_posy", pos.y);
          }
          await Future.delayed(const Duration(milliseconds: 500));
        });
    add(timerPositionLoop!);
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
    if (!isPlaying) {
      return;
    }

    if (other != null) {
      var posx = m.getDouble("${m.other}_posx");
      var posy = m.getDouble("${m.other}_posy");
      if (posx != null && posy != null) {
        Vector2 otherPos = Vector2(posx, posy); // in percent relative to bounds
        var topLeftBound =
            (size / 2) - Vector2(size.x * .75 / 2, size.x * .75 / 2);
        other!.position = topLeftBound + otherPos * size.x * .75;
      }
    }

    if (m.getBool("${m.other}_dead") == true) {
      endTheGame();
      return;
    }

    for (var f in fireballs) {
      if (f.position.distanceTo(player!.position) < size.x * .07) {
        isAlive = false;
        m.setBool("${m.me}_dead", true);
        endTheGame();
      }
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    isDragging = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (player != null && isPlaying) {
      player!.position += event.delta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isDragging = false;
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
    if (timerPositionLoop != null) {
      remove(timerPositionLoop!);
    }
    timerPositionLoop = null;
    if (timerFireball != null) {
      remove(timerFireball!);
    }
    timerFireball = null;
  }

  void loadAndPlayMusic(String music) async {
    if (m.audioPlayer.state == PlayerState.playing) {
      return;
    }
    await m.audioCache.load(music);

    m.audioPlayer.play(AssetSource(music));
  }

  void endTheGame() async {
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
    if (!m.isSolo && isAlive) {
      var endLastAlive = TextComponent(
        text: 'Dernier survivant',
        position: Vector2(size.x / 2, size.y / 2 + 150),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18.0,
            fontFamily: 'Josefa Rounded',
          ),
        ),
        anchor: Anchor.center,
      );
      var endLastAlivePts = TextComponent(
        text: '+300 points',
        position: Vector2(size.x / 2, size.y / 2 + 175),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 32.0,
            fontFamily: 'Josefa Rounded',
          ),
        ),
        anchor: Anchor.center,
      );
      add(endLastAlive);
      add(endLastAlivePts);
      addScore += 300;
    }
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

    lavaImg = await images.load('lava.jpg');
    rockImg = await images.load('rock.png');
    fireBallImg = await images.load('fireball.png');
    playerImg = await images.load('Hot Face.png');
    otherImg = await images.load('Cold Face.png');

    await startSequence();

    loadAndPlayMusic("musics/game.mp3");
  }
}

Vector2 getRandomPointOutside(Vector2 size, Random r) {
  double margin = size.x * .2;
  if (r.nextBool()) {
    // top or bottom
    if (r.nextBool()) {
      // top
      return Vector2(r.nextDouble() * size.x - margin, 0);
    } else {
      // bottom
      return Vector2(r.nextDouble() * size.x + margin, size.y);
    }
  } else {
    // left or right
    if (r.nextBool()) {
      // left
      return Vector2(0, r.nextDouble() * size.y - margin);
    } else {
      // right
      return Vector2(size.x, r.nextDouble() * size.y + margin);
    }
  }
}

Vector2 getRandomPointInside(Vector2 size, Random r) {
  final boundTopLeft = (size / 2) - Vector2(size.x * .75 / 2, size.x * .75 / 2);
  return boundTopLeft + Vector2.random(r) * size.x * .75;
}

Vector2 directionFromTo(Vector2 from, Vector2 to) {
  return (to - from).normalized();
}

class Fireball extends SpriteComponent {
  final double speed;
  final Vector2 psize;
  final Game4 game;
  late Vector2 direction;
  final List<SpriteComponent> fireballs;
  Fireball(Image img, this.psize, this.speed, this.fireballs, this.game)
      : super.fromImage(img,
            size: Vector2.all(psize.x * .1),
            position: getRandomPointOutside(psize, game.r)) {
    direction = directionFromTo(position, getRandomPointInside(psize, game.r));
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;
    position += direction * speed * dt;
    angle += 4 * dt;
  }
}

class Player extends SpriteComponent {
  final Vector2 psize;
  final Game4 game;
  late Vector2 topLeftBound;
  late Vector2 bottomRightBound;
  double t = 0;
  Player(Image img, this.psize, this.game)
      : super.fromImage(img,
            size: Vector2.all(psize.x * .1),
            position: Vector2(psize.x / 2, psize.y / 2)) {
    anchor = Anchor.center;
    topLeftBound = (psize / 2) - Vector2(psize.x * .75 / 2, psize.x * .75 / 2);
    bottomRightBound = topLeftBound + Vector2.all(psize.x * .75);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;
    t += dt;
    if (position.x < topLeftBound.x) {
      position.x = topLeftBound.x;
    }
    if (position.x > bottomRightBound.x) {
      position.x = bottomRightBound.x;
    }
    if (position.y < topLeftBound.y) {
      position.y = topLeftBound.y;
    }
    if (position.y > bottomRightBound.y) {
      position.y = bottomRightBound.y;
    }

    var rotation = 0.07 * sin(t * 16) + 0.2 * sin(t * 7);

    angle = rotation;
  }
}

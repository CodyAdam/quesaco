import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

class MenuBackground extends FlameGame {
  @override
  Color backgroundColor() => const Color.fromARGB(0, 248, 249, 249);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    List<Image> bgImages = [];
    bgImages.add(await images.load('thumb_game_1.png'));
    bgImages.add(await images.load('thumb_game_2.png'));
    bgImages.add(await images.load('thumb_game_3.png'));
    bgImages.add(await images.load('thumb_game_4.png'));
    bgImages.add(await images.load('thumb_game_5.png'));
    bgImages.add(await images.load('thumb_game_6.png'));

    // col -2
    bgImages.shuffle();
    for (int i = -2; i < 4; i++) {
      add(CardCompo(bgImages[i % 6], -2, i, size.x, size.y));
    }
    // col -1
    bgImages.shuffle();
    for (int i = -2; i < 4; i++) {
      add(CardCompo(bgImages[i % 6], -1, i, size.x, size.y));
    }
    // col 0
    bgImages.shuffle();
    for (int i = -2; i < 4; i++) {
      add(CardCompo(bgImages[i % 6], 0, i, size.x, size.y));
    }
    // col 1
    bgImages.shuffle();
    for (int i = -2; i < 4; i++) {
      add(CardCompo(bgImages[i % 6], 1, i, size.x, size.y));
    }
    // col 2
    bgImages.shuffle();
    for (int i = -2; i < 4; i++) {
      add(CardCompo(bgImages[i % 6], 2, i, size.x, size.y));
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(
      -30 * 3.14 / 180,
    );
    canvas.translate(-size.x / 2, -size.y / 2);

    super.render(canvas);
  }
}

class CardCompo extends SpriteComponent {
  int index = 0;
  int column = 0;
  double w;
  double h;
  late Vector2 mid;
  late double xoffset;
  late double yoffset;
  double movementOffset = 0;
  final double speed = 10;

  CardCompo(Image image, this.column, this.index, this.w, this.h)
      : super.fromImage(image) {
    xoffset = w * 0.46;
    yoffset = w * 0.55;
    anchor = Anchor.center;
    mid = Vector2(w / 2, h / 2);
    size = Vector2(0.8 * w * .5, 1.0 * w * .5);
    position = Vector2(mid.x + xoffset * column, mid.y + yoffset * index);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (column % 2 == 0) {
      movementOffset = (dt * w * .01 * speed + movementOffset);
      if (position.y > h + size.y) {
        movementOffset -= 6 * yoffset;
      }
      position = Vector2(mid.x + xoffset * column, mid.y + yoffset * index) +
          Vector2(0, movementOffset);
    } else {
      movementOffset = (dt * w * .01 * speed + movementOffset);
      if (position.y < -size.y) {
        movementOffset -= 6 * yoffset;
      }
      position = Vector2(mid.x + xoffset * column, mid.y + yoffset * index) +
          Vector2(0, -movementOffset);
    }
  }
}

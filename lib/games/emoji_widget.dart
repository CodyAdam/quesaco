import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quesaco/games/emoji/slice.dart';
import 'package:quesaco/games/emoji/slice_math.dart';

import 'emoji/gravity.dart';

class EmojiWidget extends StatefulWidget {
  final Size screenSize;
  final Size worldSize;

  const EmojiWidget({required Key key, required this.screenSize, required this.worldSize}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EmojiWidgetState();
}

class EmojiWidgetState extends State<EmojiWidget> {
  Random r = Random();

  late Timer emojiTimer;

  List<Emoji> emoji = [];

  List<EmojiSliced> emojiSliced = [];

  List<Slice> slices = [];

  late int sliceBeginMoment;
  late Offset sliceBeginPosition;
  late Offset sliceEnd;

  int score = 0;

  @override
  void initState() {
    super.initState();

    emojiTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        emoji.add(Emoji(
            createdMS: DateTime.now().millisecondsSinceEpoch,
            flightPath: FlightPath(
                angle: 1.0,
                angularVelocity: .3 + r.nextDouble() * 3.0,
                position: Offset(2.0 + r.nextDouble() * (widget.worldSize.width - 4.0), 1.0),
                velocity: Offset(-1.0 + r.nextDouble() * 2.0, 7.0 + r.nextDouble() * 7.0)),
            type: EmojiType.values[r.nextInt(EmojiType.values.length)]));
      });
    });
  }

  @override
  void dispose() {
    if (emojiTimer != null) {
      emojiTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double ppu = widget.screenSize.height / widget.worldSize.height;
    List<Widget> stackItems = [];
    for (Emoji e in emoji) {
      stackItems.add(FlightPathWidget(
        key: e.key,
        flightPath: e.flightPath,
        unitSize: e.type.unitSize,
        pixelsPerUnit: ppu,
        child: e.type.getImageWidget(ppu),
        onOffScreen: () {
          setState(() {
            emoji.remove(e);
          });
        },
      ));
    }
    for (Slice slice in slices) {
      Offset b = Offset(slice.begin.dx * ppu, (widget.worldSize.height - slice.begin.dy) * ppu);
      Offset e = Offset(slice.end.dx * ppu, (widget.worldSize.height - slice.end.dy) * ppu);
      stackItems.add(Positioned.fill(
          child: SliceWidget(
            sliceBegin: b,
            sliceEnd: e,
            sliceFinished: () {
              setState(() {
                slices.remove(slice);
              });
            }, key: const Key(""),
          )));
    }
    for (EmojiSliced es in emojiSliced) {
      stackItems.add(FlightPathWidget(
        key: es.key,
        flightPath: es.flightPath,
        unitSize: es.type.unitSize,
        pixelsPerUnit: ppu,
        child: ClipPath(clipper: EmojiSlicePath(es.slice), child: es.type.getImageWidget(ppu)),
        onOffScreen: () {
          setState(() {
            emojiSliced.remove(es);
          });
        },
      ));
    }
    TextStyle scoreDisplay = const TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.w700);
    stackItems.add(Positioned.fill(
        child: DefaultTextStyle(
            style: scoreDisplay,
            child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Text("Score"),
                          const SizedBox(
                            height: 8,
                          ),
                          Text("$score")
                        ]),
                      ],
                    )
                  ],
                )))));
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: stackItems,
      ),
      onPanDown: (DragDownDetails details) {
        sliceBeginMoment = DateTime.now().millisecondsSinceEpoch;
        sliceBeginPosition = details.localPosition;
        sliceEnd = details.localPosition;
      },
      onPanUpdate: (DragUpdateDetails details) {
        sliceEnd = details.localPosition;
      },
      onPanEnd: (DragEndDetails details) {
        int nowMS = DateTime.now().millisecondsSinceEpoch;
        if (nowMS - sliceBeginMoment < 1250 && (sliceEnd - sliceBeginPosition).distanceSquared > 25.0) {
          setState(() {
            Offset worldSliceBegin =
            Offset(sliceBeginPosition.dx / ppu, (widget.screenSize.height - sliceBeginPosition.dy) / ppu);
            Offset worldSliceEnd = Offset(sliceEnd.dx / ppu, (widget.screenSize.height - sliceEnd.dy) / ppu);
            slices.add(Slice(worldSliceBegin, worldSliceEnd));
            Offset direction = worldSliceEnd - worldSliceBegin;

            worldSliceBegin = worldSliceBegin - direction;
            worldSliceEnd = worldSliceEnd + direction;
            List<Emoji> toRemove = [];
            for (Emoji e in emoji) {
              double elapsedSeconds = (nowMS - e.createdMS) / 1000.0;
              Offset currPos = e.flightPath.getPosition(elapsedSeconds);
              double currAngle = e.flightPath.getAngle(elapsedSeconds);
              List<List<Offset>> sliceParts =
              getSlicePaths(worldSliceBegin, worldSliceEnd, e.type.unitSize, currPos, currAngle);
              if (sliceParts.isNotEmpty) {
                toRemove.add(e);
                emojiSliced.add(EmojiSliced(
                    slice: sliceParts[0],
                    flightPath: FlightPath(
                        angle: currAngle,
                        angularVelocity: e.flightPath.angularVelocity - .25 + r.nextDouble() * .5,
                        position: currPos,
                        velocity: const Offset(-1.0, 2.0)),
                    type: e.type));
                emojiSliced.add(EmojiSliced(
                    slice: sliceParts[1],
                    flightPath: FlightPath(
                        angle: currAngle,
                        angularVelocity: e.flightPath.angularVelocity - .25 + r.nextDouble() * .5,
                        position: currPos,
                        velocity: const Offset(1.0, 2.0)),
                    type: e.type));
              }
            }
            for(Emoji e in toRemove) {
              if(e.type == EmojiType.love) {
                score -= 1;
              } else {
                score += 1;
              }
            }
            emoji.removeWhere((e) => toRemove.contains(e));
          });
        }
      },
    );
  }
}

class EmojiSlicePath extends CustomClipper<Path> {
  final List<Offset> normalizedPoints;

  EmojiSlicePath(this.normalizedPoints);

  @override
  Path getClip(Size size) {
    Path p = Path()..moveTo(normalizedPoints[0].dx * size.width, normalizedPoints[0].dy * size.height);
    for (Offset o in normalizedPoints.skip(1)) {
      p.lineTo(o.dx * size.width, o.dy * size.height);
    }
    return p..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

Widget EmojiGame() {
  return Scaffold(
      body: Container(
          color: Colors.white,
          child: LayoutBuilder(builder: (context, constraints) {
            Size screenSize = Size(constraints.maxWidth, constraints.maxHeight);
            Size worldSize = Size(
                WORLD_HEIGHT * screenSize.aspectRatio, WORLD_HEIGHT);
            return EmojiWidget(
              screenSize: Size(constraints.maxWidth, constraints.maxHeight),
              worldSize: worldSize, key: const Key(""),
            );
          })));
}
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'dart:ui';

const Offset GRAVITY = Offset(0, -9.8);
const double WORLD_HEIGHT = 16.0;

enum EmojiType { idiot, love, laught, angry }

extension EmojiTypeUtil on EmojiType {
  Size get unitSize {
    switch (this) {
      case EmojiType.idiot:
        return const Size(2, 2);
      case EmojiType.love:
        return const Size(2, 2);
      case EmojiType.laught:
        return const Size(2, 2);
      case EmojiType.angry:
        return const Size(2, 2);
    }
  }

  String get imageFile {
    switch (this) {
      case EmojiType.idiot:
        return "assets/emoji/laid.png";
      case EmojiType.love:
        return "assets/emoji/amoureux.png";
      case EmojiType.laught:
        return "assets/emoji/en-riant.png";
      case EmojiType.angry:
        return "assets/emoji/en-colere.png";
    }
  }

  Widget getImageWidget(double pixelsPerUnit) => Image.asset(imageFile,
      width: unitSize.width * pixelsPerUnit,
      height: unitSize.height * pixelsPerUnit);
}

class Emoji {
  final Key key = UniqueKey();
  final int createdMS;
  final FlightPath flightPath;
  final EmojiType type;

  Emoji(
      {required this.createdMS, required this.flightPath, required this.type});
}

class EmojiSliced {
  final Key key = UniqueKey();
  final List<Offset> slice;
  final FlightPath flightPath;
  final EmojiType type;

  EmojiSliced(
      {required this.slice, required this.flightPath, required this.type});
}

class Slice {
  final Key key = UniqueKey();
  final Offset begin;
  final Offset end;

  Slice(this.begin, this.end);
}

// a parabolic flight path.
// all flights in this program start below zero and fly upwards
// past zero. Therefore, there are always two zeroes.
class FlightPath {
  final double angle;
  final double angularVelocity;
  final Offset position;
  final Offset velocity;

  FlightPath(
      {required this.angle,
      required this.angularVelocity,
      required this.position,
      required this.velocity});

  Offset getPosition(double t) {
    return (GRAVITY * .5) * t * t + velocity * t + position;
  }

  double getAngle(double t) {
    return angle + angularVelocity * t;
  }

  List<double> get zeroes {
    double a = (GRAVITY * .5).dy;
    double sqrtTerm = sqrt(velocity.dy * velocity.dy - 4.0 * a * position.dy);
    if (sqrtTerm.isNaN) {
      return [0, 0]; // or handle the case when there are no real zeroes
    }
    return [
      (-velocity.dy + sqrtTerm) / (2 * a),
      (-velocity.dy - sqrtTerm) / (2 * a)
    ];
  }
}

class FlightPathWidget extends StatefulWidget {
  final FlightPath flightPath;

  final Size unitSize;
  final double pixelsPerUnit;

  final Widget child;

  final Function() onOffScreen;

  const FlightPathWidget(
      {required Key key,
      required this.flightPath,
      required this.unitSize,
      required this.pixelsPerUnit,
      required this.child,
      required this.onOffScreen})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => FlightPathWidgetState();
}

class FlightPathWidgetState extends State<FlightPathWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    List<double> zeros = widget.flightPath.zeroes;
    double time = max(zeros[0], zeros[1]);

    animationController = AnimationController(
        vsync: this,
        upperBound: time + 1.0, // allow an extra second of fall time
        duration: Duration(milliseconds: ((time + 1.0) * 1000.0).round()));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onOffScreen();
      }
    });
    animationController.forward();
  }

  @override
  void dispose() {
    if (animationController != null) {
      animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        Offset pos = widget.flightPath.getPosition(animationController.value) *
            widget.pixelsPerUnit;
        return Positioned(
          left: pos.dx - widget.unitSize.width * .5 * widget.pixelsPerUnit,
          bottom: pos.dy - widget.unitSize.height * .5 * widget.pixelsPerUnit,
          child: Transform(
            transform: Matrix4.rotationZ(
                widget.flightPath.getAngle(animationController.value)),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: widget.child);
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: RockPaperScissors(),
    ),
  );
}

enum SquareType {
  rock,
  paper,
  scissors,
}

const double squareWidth = 48;

//Square Model
class Square {
  static final Random _random = Random();
  static const double _speed = 4.0;

  Offset position;
  Offset speed;
  SquareType type;
  bool isDeleted = false;

  Square({
    required this.type,
    required this.position,
  }) : speed = Offset(
          _random.nextDouble() * _speed - _speed / 2,
          _random.nextDouble() * _speed - _speed / 2,
        );

  void move() {
    position += speed;
  }

  void bounce(double minX, double maxX, double minY, double maxY) {
    if (position.dx < minX || position.dx > maxX - squareWidth) {
      speed = Offset(speed.dx * -1, speed.dy);
    }
    if (position.dy < minY || position.dy > maxY - squareWidth) {
      speed = Offset(speed.dx, speed.dy * -1);
    }
  }

  void collide(Square other) {
    if (position.dx < other.position.dx + squareWidth &&
        position.dx + squareWidth > other.position.dx &&
        position.dy < other.position.dy + squareWidth &&
        position.dy + squareWidth > other.position.dy) {
      if (other.type != type) {
        switch (type) {
          case SquareType.paper:
            if (other.type == SquareType.rock) {
              other.isDeleted = true;
            } else if (other.type == SquareType.scissors) {
              isDeleted = true;
            }
            break;
          case SquareType.rock:
            if (other.type == SquareType.scissors) {
              other.isDeleted = true;
            } else if (other.type == SquareType.paper) {
              isDeleted = true;
            }
            break;
          case SquareType.scissors:
            if (other.type == SquareType.paper) {
              other.isDeleted = true;
            } else if (other.type == SquareType.rock) {
              isDeleted = true;
            }
            break;
        }
      } else {
        double tempX = speed.dx;
        double tempY = speed.dy;
        speed = Offset(other.speed.dx, other.speed.dy);
        other.speed = Offset(tempX, tempY);
      }
    }
  }
}

class RockPaperScissors extends StatefulWidget {
  const RockPaperScissors({super.key});

  @override
  RockPaperScissorsState createState() => RockPaperScissorsState();
}

class RockPaperScissorsState extends State<RockPaperScissors> {
  List<Square> squares = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createSquars();
      startTimer();
    });
  }

  void createSquars() {
    Random random = Random();

    for (SquareType squareType in SquareType.values) {
      for (int i = 0; i < 5; i++) {
        double x = random.nextDouble() * (MediaQuery.of(context).size.width - squareWidth);
        double y = random.nextDouble() * (MediaQuery.of(context).size.height - squareWidth);
        bool overlaps = false;
        for (Square other in squares) {
          if (x < other.position.dx + squareWidth &&
              x + squareWidth > other.position.dx &&
              y < other.position.dy + squareWidth &&
              y + squareWidth > other.position.dy) {
            overlaps = true;
            break;
          }
        }
        if (!overlaps) {
          squares.add(
            Square(
              type: squareType,
              position: Offset(x, y),
            ),
          );
        } else {
          i--;
        }
      }
    }
  }

  void startTimer() {
    Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        setState(
          () {
            for (var square in squares.where((square) => square.isDeleted == false)) {
              square.move();
              square.bounce(
                0,
                MediaQuery.of(context).size.width,
                0,
                MediaQuery.of(context).size.height,
              );
              for (var other in squares.where((square) => square.isDeleted == false)) {
                if (square != other) {
                  square.collide(other);
                }
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              Opacity(
                opacity: 0.4,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            color: Colors.brown,
                            height: 96,
                            width: 96,
                          ),
                          const Text(
                            'Rock',
                            style: TextStyle(fontSize: 64),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            color: Colors.yellow,
                            height: 96,
                            width: 96,
                          ),
                          const Text(
                            'Paper',
                            style: TextStyle(fontSize: 64),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            color: Colors.purple,
                            height: 96,
                            width: 96,
                          ),
                          const Text(
                            'Scissor',
                            style: TextStyle(fontSize: 64),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                painter: RockPaperScissorsPainter(squares),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RockPaperScissorsPainter extends CustomPainter {
  List<Square> squares;

  RockPaperScissorsPainter(this.squares);

  @override
  void paint(Canvas canvas, Size size) {
    for (var square in squares.where(
      (object) => (object.isDeleted == false),
    )) {
      final type = square.type;
      Color getColor() {
        switch (type) {
          case SquareType.rock:
            return Colors.brown;
          case SquareType.paper:
            return Colors.yellow;
          case SquareType.scissors:
            return Colors.purple;
        }
      }

      canvas.drawRect(
        Rect.fromLTWH(square.position.dx, square.position.dy, squareWidth, squareWidth),
        Paint()..color = getColor(),
      );
    }
  }

  @override
  bool shouldRepaint(RockPaperScissorsPainter oldDelegate) {
    return true;
  }
}

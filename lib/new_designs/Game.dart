import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class BubblePopScreen extends StatefulWidget {
  const BubblePopScreen({Key? key}) : super(key: key);

  @override
  State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen>
    with TickerProviderStateMixin {
  final List<Bubble> _bubbles = [];
  final List<PopEffect> _popEffects = [];
  int _score = 0;
  Timer? _bubbleGenerator;
  int _idCounter = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startBubbleGeneration();
  }

  void _startBubbleGeneration() {
    _bubbleGenerator = Timer.periodic(const Duration(milliseconds: 800), (
      timer,
    ) {
      if (_bubbles.length < 15) {
        _generateBubble();
      }
    });
  }

  void _generateBubble() {
    final size = MediaQuery.of(context).size;
    final bubbleSize = _random.nextDouble() * 60 + 40;

    final bubble = Bubble(
      id: _idCounter++,
      x: _random.nextDouble() * (size.width - bubbleSize),
      y: _random.nextDouble() * (size.height - 150 - bubbleSize) + 100,
      size: bubbleSize,
      color: HSLColor.fromAHSL(
        1.0,
        _random.nextDouble() * 360,
        0.7,
        0.6,
      ).toColor(),
    );

    setState(() {
      _bubbles.add(bubble);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _bubbles.removeWhere((b) => b.id == bubble.id);
        });
      }
    });
  }

  void _popBubble(Bubble bubble) {
    setState(() {
      _score++;
      _bubbles.removeWhere((b) => b.id == bubble.id);
      _popEffects.add(
        PopEffect(
          x: bubble.x + bubble.size / 2,
          y: bubble.y + bubble.size / 2,
          color: bubble.color,
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _popEffects.removeWhere((p) => p.x == bubble.x + bubble.size / 2);
        });
      }
    });
  }

  @override
  void dispose() {
    _bubbleGenerator?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE9D5FF), Color(0xFFFCE7F3), Color(0xFFDBEAFE)],
          ),
        ),
        child: Stack(
          children: [
            ..._bubbles.map(
              (bubble) => BubbleWidget(
                key: ValueKey(bubble.id),
                bubble: bubble,
                onPop: () => _popBubble(bubble),
              ),
            ),

            ..._popEffects.map(
              (effect) => PopEffectWidget(
                key: ValueKey('${effect.x}-${effect.y}'),
                effect: effect,
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🫧 Bubble Pop',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bubble {
  final int id;
  final double x;
  final double y;
  final double size;
  final Color color;

  Bubble({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
}

class BubbleWidget extends StatefulWidget {
  final Bubble bubble;
  final VoidCallback onPop;

  const BubbleWidget({Key? key, required this.bubble, required this.onPop})
    : super(key: key);

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: 0,
      end: -20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.bubble.x,
          top: widget.bubble.y + _floatAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onPop,
              child: Container(
                width: widget.bubble.size,
                height: widget.bubble.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.4),
                    colors: [
                      widget.bubble.color.withOpacity(1.0),
                      widget.bubble.color.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.bubble.color.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: widget.bubble.size * 0.15,
                      left: widget.bubble.size * 0.2,
                      child: Container(
                        width: widget.bubble.size * 0.3,
                        height: widget.bubble.size * 0.3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PopEffect {
  final double x;
  final double y;
  final Color color;

  PopEffect({required this.x, required this.y, required this.color});
}

class PopEffectWidget extends StatefulWidget {
  final PopEffect effect;

  const PopEffectWidget({Key? key, required this.effect}) : super(key: key);

  @override
  State<PopEffectWidget> createState() => _PopEffectWidgetState();
}

class _PopEffectWidgetState extends State<PopEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.effect.x,
          top: widget.effect.y,
          child: Opacity(
            opacity: 1 - _controller.value,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: List.generate(8, (index) {
                  final angle = (index * 45) * pi / 180;
                  final distance = 40 * _controller.value;
                  return Positioned(
                    left: 40 + cos(angle) * distance - 4,
                    top: 40 + sin(angle) * distance - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.effect.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

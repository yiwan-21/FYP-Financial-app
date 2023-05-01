import 'package:flutter/material.dart';

class GrowingTree extends StatefulWidget {
  final double progress;

  const GrowingTree({required this.progress, super.key});

  @override
  State<GrowingTree> createState() => _GrowingTreeState();
}

class _GrowingTreeState extends State<GrowingTree>
    with SingleTickerProviderStateMixin {
  final List<String> images = [
    'assets/images/growing_1.png',
    'assets/images/growing_2.png',
    'assets/images/growing_3.png',
    'assets/images/growing_4.png',
    'assets/images/growing_5.png',
    'assets/images/growing_6.png',
  ];
  late AnimationController _controller;
  late Animation<double> _animation;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = (widget.progress / 20).floor();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    // _controller.forward();
    // _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // _index = (_index + 1) % images.length;
        });
      },
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              images[_index],
              height: 300,
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: IgnorePointer(
                child: Image.asset(
                  images[(_index + 1) % images.length],
                  fit: BoxFit.cover,
                  height: 300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  //   return TweenAnimationBuilder<double>(
  //     tween: Tween(begin: 0.0, end: progress),
  //     duration: Duration(milliseconds: 500),
  //     builder: (BuildContext context, double value, Widget? child) {
  //       return ClipRect(
  //         child: Align(
  //           alignment: Alignment.bottomCenter,
  //           heightFactor: value,
  //           child: Image(image: AssetImage("assets/images/growingTree.jpg")),
  //         ),
  //       );
  //     },
  //   );
  }
}

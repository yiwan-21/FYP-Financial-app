import 'package:flutter/material.dart';

class GrowingTree extends StatefulWidget {
  final double progress;

  const GrowingTree({required this.progress, super.key});

  @override
  State<GrowingTree> createState() => _GrowingTreeState();
}

class _GrowingTreeState extends State<GrowingTree>
    with SingleTickerProviderStateMixin {
  final List<ImageProvider> images = const[
    AssetImage('assets/images/growing_1.png'),
    AssetImage('assets/images/growing_2.png'),
    AssetImage('assets/images/growing_3.png'),
    AssetImage('assets/images/growing_4.png'),
    AssetImage('assets/images/growing_5.png'),
    AssetImage('assets/images/growing_6.png'),
  ];
  late AnimationController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = (widget.progress / 20).floor();

    _controller = AnimationController(
      duration: Duration(milliseconds: (_index * 300)),
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
      builder: (BuildContext context, Widget? child) {
        return Image(
          image: images[(_controller.value * _index).floor() % images.length],
          height: 300,
          fit: BoxFit.fitHeight,
        );
      }
    );
  }
}

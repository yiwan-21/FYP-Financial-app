import 'package:flutter/material.dart';

class GrowingTree extends StatefulWidget {
  final double progress;

  const GrowingTree({required this.progress, super.key});

  @override
  State<GrowingTree> createState() => _GrowingTreeState();
}

class _GrowingTreeState extends State<GrowingTree>
    with SingleTickerProviderStateMixin {
  final List<ImageProvider> images = const [
    AssetImage('assets/images/growing_1.png'),
    AssetImage('assets/images/growing_2.png'),
    AssetImage('assets/images/growing_3.png'),
    AssetImage('assets/images/growing_4.png'),
    AssetImage('assets/images/growing_5.png'),
    AssetImage('assets/images/growing_6.png'),
  ];
  late AnimationController _controller;
  int _index = 0;
  int _newIndex = 0;
  // first load: _growing = true
  // updates after first load: _growing = false
  bool _growing = true;

  @override
  void initState() {
    super.initState();
    _index = (widget.progress / 20).floor();

    _controller = AnimationController(
      duration: Duration(milliseconds: (_index * 300)),
      vsync: this,
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_growing) {
        setState(() {
          _index = _newIndex;
        });
      }
    });
  }

  @override
  void didUpdateWidget(GrowingTree oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newIndex = (widget.progress / 20).floor();
    if (_index != newIndex) {
      setState(() {
        _growing = false;
        _newIndex = newIndex;
      });
      _controller.reset();
      _controller.forward();
    }
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
            // if growing: show images from 0 to index
            image: _growing ? images[(_controller.value * _index).floor() % images.length] 
              // if not growing: show images from index to newIndex
              : images[(_controller.value * (_newIndex - _index) + _index).floor() % images.length], 
            height: 300,
            fit: BoxFit.fitHeight,
          );
        });
  }
}

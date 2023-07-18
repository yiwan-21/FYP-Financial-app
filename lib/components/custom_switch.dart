import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({
    Key? key,
    required this.onToggle,
    this.isIncome = false,
  }) : super(key: key);

  final Color activeColor = const Color.fromARGB(255, 185, 246, 202);
  final Color inactiveColor = const Color.fromARGB(255, 255, 176, 176);
  final List<String> labels = const ['Income', 'Expense'];
  final ValueChanged<bool> onToggle;
  final bool isIncome;

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  bool _value = false;

  @override
  void initState() {
    const duration = Duration(milliseconds: 100);
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: const Offset(3.2, 0),
    ).animate(_controller);
    if (widget.isIncome) {
      _controller.duration = const Duration(milliseconds: 0);
      _controller.forward();
      _controller.duration = duration;
    }
    _value = widget.isIncome;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _value = !_value;
    widget.onToggle(_value);

    if (_value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 125.0,
        height: 34.0,
        decoration: BoxDecoration(
          border: _value
              ? Border.all(color: Colors.green[600]!, width: 2.0)
              : Border.all(color: Colors.red[600]!, width: 2.0),
          borderRadius: BorderRadius.circular(16.0),
          color: _value ? widget.activeColor : widget.inactiveColor,
        ),
        child: Padding(
          padding: _value
              ? const EdgeInsets.only(left: 14.0)
              : const EdgeInsets.only(right: 14.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.labels[0],
                  style: TextStyle(
                    color: _value ? Colors.black : widget.inactiveColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.labels[1],
                  style: TextStyle(
                    color: _value ? widget.activeColor : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return SlideTransition(
                    position: _animation,
                    child: Container(
                      width: 25.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: _value
                            ? Border.all(color: Colors.green[600]!, width: 2.0)
                            : Border.all(color: Colors.red[600]!, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

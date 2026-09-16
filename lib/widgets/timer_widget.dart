import 'dart:async';
import 'package:flutter/material.dart';
import '../core/utils/formatter.dart';

class TimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onTimeUp;
  final Function(int remainingSeconds)? onTick;

  const TimerWidget({
    super.key,
    required this.initialSeconds,
    required this.onTimeUp,
    this.onTick,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        widget.onTimeUp();
      } else {
        setState(() {
          _remainingSeconds--;
        });
        if (widget.onTick != null) {
          widget.onTick!(_remainingSeconds);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWarning = _remainingSeconds <= 300;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isWarning
              ? Colors.red.shade50.withOpacity(0.8)
              : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isWarning ? Colors.red : Colors.blue,
            width: isWarning ? (1.5 + _pulseController.value * 1) : 1,
          ),
          boxShadow: isWarning
              ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3 * _pulseController.value),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_rounded,
              size: 18,
              color: isWarning ? Colors.red : Colors.blue.shade800,
            ),
            const SizedBox(width: 6),
            Text(
              Formatter.duration(_remainingSeconds),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isWarning ? Colors.red : Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

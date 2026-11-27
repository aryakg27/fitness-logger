import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Rest timer bar shown at the top of the workout screen.
/// Pick a duration, watch the countdown, and get an alert when it ends.
class RestTimer extends StatefulWidget {
  const RestTimer({super.key});

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  // Rest durations in seconds that the user can choose from.
  static const _options = [60, 90, 120];

  Timer? _timer;
  // Seconds left. 0 means the timer is not running.
  int _remaining = 0;

  /// Starts (or restarts) a countdown of [seconds].
  void _start(int seconds) {
    _timer?.cancel();
    setState(() => _remaining = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        // Time is up: stop, then vibrate and play a sound.
        timer.cancel();
        setState(() => _remaining = 0);
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
        return;
      }
      setState(() => _remaining--);
    });
  }

  /// Stops the countdown without an alert.
  void _stop() {
    _timer?.cancel();
    setState(() => _remaining = 0);
  }

  @override
  void dispose() {
    // Always cancel the timer when the screen closes.
    _timer?.cancel();
    super.dispose();
  }

  /// Turns seconds into text like "1:05".
  String _format(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: _remaining > 0
          // Running: show the countdown and a Stop button.
          ? Row(
              children: [
                const Icon(Icons.timer),
                const SizedBox(width: 8),
                Text(
                  'Rest  ${_format(_remaining)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(onPressed: _stop, child: const Text('Stop')),
              ],
            )
          // Idle: show the duration buttons.
          : Row(
              children: [
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 8),
                const Text('Rest:'),
                const SizedBox(width: 8),
                for (final s in _options)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text('${s}s'),
                      onPressed: () => _start(s),
                    ),
                  ),
              ],
            ),
    );
  }
} 
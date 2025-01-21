import 'package:flutter/material.dart';

class MeetingControls extends StatelessWidget {
  final bool micEnabled;
  final bool camEnabled;
  final void Function() onToggleMicButtonPressed;
  final void Function() onToggleCameraButtonPressed;
  final void Function() onLeaveButtonPressed;
  const MeetingControls({
    Key? key,
    required this.micEnabled,
    required this.camEnabled,
    required this.onToggleMicButtonPressed,
    required this.onToggleCameraButtonPressed,
    required this.onLeaveButtonPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: onLeaveButtonPressed,
          child: const Text('Leave'),
        ),
        IconButton(
          onPressed: onToggleMicButtonPressed,
          icon: Icon(micEnabled ? Icons.mic : Icons.mic_off),
        ),
        IconButton(
          onPressed: onToggleCameraButtonPressed,
          icon: Icon(camEnabled ? Icons.videocam : Icons.videocam_off),
        ),
      ],
    );
  }
}

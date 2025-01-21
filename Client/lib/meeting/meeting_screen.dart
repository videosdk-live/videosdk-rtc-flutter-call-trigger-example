import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_example/home.dart';

import 'package:videosdk_flutter_example/meeting/meeting_controls.dart';
import './participant_tile.dart';
import 'package:http/http.dart' as http;

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String token;
  final String url;
  final String callerId;
  String? source;
  MeetingScreen(
      {Key? key,
      required this.meetingId,
      required this.token,
      required this.callerId,
      required this.url,
      this.source})
      : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late Room _room;
  var micEnabled = true;
  var camEnabled = true;

  Map<String, Participant> participants = {};

  @override
  void initState() {
    // create room
    if (widget.source == "true") {
      sendnotification(
          widget.url, widget.callerId, "Call Accepted", widget.meetingId);
    }
    _room = VideoSDK.createRoom(
        roomId: widget.meetingId,
        token: widget.token,
        displayName: "John Doe",
        micEnabled: micEnabled,
        camEnabled: camEnabled,
        defaultCameraIndex: kIsWeb
            ? 0
            : 1 // Index of MediaDevices will be used to set default camera
        );

    setMeetingEventListener();

    // Join room
    _room.join();

    super.initState();
  }

  Future<void> sendnotification(String api, callerId, status, roomId) async {
    await sendCallStatus(
        serverUrl: api, callerId: callerId, status: status, roomId: roomId);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // listening to meeting events
  void setMeetingEventListener() {
    _room.on(Events.roomJoined, () {
      setState(() {
        participants.putIfAbsent(
            _room.localParticipant.id, () => _room.localParticipant);
      });
    });

    _room.on(
      Events.participantJoined,
      (Participant participant) {
        setState(
          () => participants.putIfAbsent(participant.id, () => participant),
        );
      },
    );

    _room.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(
          () => participants.remove(participantId),
        );
      }
    });

    _room.on(Events.roomLeft, () {
      participants.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  callerID: widget.callerId,
                )),
        (route) => false, // Removes all previous routes
      );
    });
  }

  // onbackButton pressed leave the room
  Future<bool> _onWillPop() async {
    _room.leave();
    return true;
  }

  Future<void> sendCallStatus({
    required String serverUrl,
    required String callerId,
    required String status,
    required String roomId,
  }) async {
    final url = Uri.parse('$serverUrl/send-call-status');
    print("callerID in call status : $callerId");
    try {
      // Request payload
      final body = jsonEncode({
        'callerId': callerId,
        'status': status,
        'roomId': roomId,
      });

      // Sending the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Handling the response
      if (response.statusCode == 200) {
        print("Notification sent successfully: ${response.body}");
      } else {
        print("Failed to send notification: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Error sending call status: $e");
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('VideoSDK QuickStart'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(widget.meetingId),
              //render all participant
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 300,
                    ),
                    itemBuilder: (context, index) {
                      return ParticipantTile(
                          key: Key(participants.values.elementAt(index).id),
                          participant: participants.values.elementAt(index));
                    },
                    itemCount: participants.length,
                  ),
                ),
              ),
              MeetingControls(
                micEnabled: micEnabled,
                camEnabled: camEnabled,
                onToggleMicButtonPressed: () {
                  setState(() {
                    micEnabled = !micEnabled;
                  });
                  micEnabled ? _room.unmuteMic() : _room.muteMic();
                },
                onToggleCameraButtonPressed: () {
                  setState(() {
                    camEnabled = !camEnabled;
                  });
                  camEnabled ? _room.enableCam() : _room.disableCam();
                },
                onLeaveButtonPressed: () {
                  _room.leave();
                },
              ),
            ],
          ),
        ),
      ),
      //home: JoinScreen(),
    );
  }
}

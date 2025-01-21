// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:videosdk_flutter_example/meeting/meeting_screen.dart';
import 'dart:io';

String background = "";
String? callerId;
// ignore: non_constant_identifier_names
String roomId_sender = "";
// ignore: non_constant_identifier_names
String romId_receiver = "";
String? _currentUuid;
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("hii");
  print("Handling a background message: ${message.data}");
  romId_receiver = message.data['roomId'];
  print("romID receiver: $romId_receiver");
  roomId_sender = message.data['roomId'];
  callerId = message.data['callerInfo'];
  print("Caller Info: $callerId");

  if (Platform.isIOS) {
    print("Hellooooooooooooo is is inisde the _firebase message");
    makeFakeCallInComing(callerId!);
  }
}

Future<void> makeFakeCallInComing(String callerId) async {
  print("CallerId:$callerId");
  print("Helloooooooooo");
  {
    _currentUuid = const Uuid().v4();
    print("uuid: $_currentUuid");
    final params = CallKitParams(
      id: _currentUuid,
      nameCaller: callerId,
      appName: 'VideoSdk',
      avatar: 'https://i.pravatar.cc/100',
      handle: callerId,
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
    Future.delayed(const Duration(seconds: 10), () async {
      await FlutterCallkitIncoming.endAllCalls();
    });
  }
}

// ignore: must_be_immutable
class Home extends StatefulWidget {
  String? callerID;
  String? source = "";
  Home({
    Key? key,
    this.source,
    this.callerID,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  bool isCalling = false;
  String textEvents = "";
  TextEditingController callIdController = TextEditingController();
  static const platform = MethodChannel('com.example.example/calls');
  String callStatus = "No Work Done";
  String? apiUrl = dotenv.env['SERVER_URL'];
  String? videoSdkKey = dotenv.env["VIDEO_SDK_KEY"];
  late final Future<String> deviceno;
  String? device;
  // ignore: non_constant_identifier_names
  String caller_id_backgroung = "";
  @override
  void initState() {
    super.initState();

    print("Calling init State");
    WidgetsBinding.instance.addObserver(this);

    print("Calling init State");
    WidgetsBinding.instance.addObserver(this);
    device = checkPlatform();
    print("Hello my device name is : $device");
    if (device == "iOS") {
      _currentUuid = "";
    }
    _initializeFirebase();
    deviceno = generateOrFetchCallerId();

    if (device == "iOS") {
      listenerEvent(onEvent);
    }
    if (widget.source == "true") {
      print("heloooooo I am inside the call status : ${widget.callerID}");
      sendCallStatus(
          serverUrl: apiUrl!,
          callerId: widget.callerID!,
          status: "Call Rejected",
          roomId: "demo_123345");
    }
    if (device == "Android") {
      Future.delayed(const Duration(seconds: 05), () {
        _initializePhoneAccount();
      });
      _listenForCallEvents();
    }
  }

  String checkPlatform() {
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isIOS) {
      return "iOS";
    } else {
      return "Unsupported Platform";
    }
  }

  Future<void> addCallerRoomAndCallee(
      String callerId, String roomId, String calleeId) async {
    final url = Uri.parse('$apiUrl/api/add');
    final body = jsonEncode({
      "callerId": callerId,
      "roomId": roomId,
      "calleeId": calleeId,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        print("Data added successfully.");
      } else {
        print("Failed to add data: ${response.body}");
      }
    } catch (e) {
      print("Error adding data: $e");
    }
  }

  /// Get `roomId` by `callerId`
  Future<bool> getRoomByCallee(String calleeId) async {
    final url = Uri.parse('$apiUrl/api/getByCallee/$callerId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        romId_receiver = data['roomId'];
        caller_id_backgroung = data['callerId'];
        return true;
      } else if (response.statusCode == 404) {
        print("No data found for the provided Caller ID.");
        return false;
      } else {
        print("Failed to fetch data: ${response.body}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return false;
  }

  Future<void> sendNotification({
    required String callerId,
    required String callerInfo,
    required String roomId,
    required String token,
  }) async {
    final Map<String, dynamic> payload = {
      'callerId': callerId,
      'callerInfo': {'id': callerInfo},
      'videoSDKInfo': {'roomId': roomId, 'token': token},
    };

    try {
      // Send POST request to the API
      final response = await http.post(
        Uri.parse("${apiUrl!}/send-notification"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // Handle the response from the API
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Message sent successfully")),
          );
        }
        print(response.body);
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending notification: $e');
    }
  }

  Future<void> _initializePhoneAccount() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the counter value from SharedPreferences, defaulting to 0 if not set.
    int counter = prefs.getInt('counter') ?? 0;
    print("Value of Counter: $counter");
    if (counter == 0) {
      // Show a SnackBar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Initializing Phone Account..."),
          duration: Duration(seconds: 2), // SnackBar duration
        ),
      );
      await Future.delayed(const Duration(seconds: 5));
      await platform.invokeMethod('registerPhoneAccount');
      await platform.invokeMethod('openPhoneAccountSettings');

      // Increment the counter and store it in SharedPreferences.
      counter++;
      await prefs.setInt('counter', counter);
    }
  }

  void onEvent(CallEvent event) {
    if (!mounted) return;
    setState(() {
      textEvents += '---\n${event.toString()}\n';
    });
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();

      print("Firebase initialized successfully.");
      //  generateOrFetchCallerId();

      _getFcmTokenAndStoreInFirebase();

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notificationData = message.data;

        if (device == "iOS") {
          if (notificationData['type'] == "Call Accepted") {
            setState(() {
              roomId_sender = notificationData['roomId'];
            });

            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MeetingScreen(
                  meetingId: roomId_sender,
                  token: videoSdkKey!,
                  callerId: callerId!,
                  url: apiUrl!,
                ),
              ),
            );
            // Do nothing
          } else if (notificationData['type'] == null) {
            setState(() {
              romId_receiver = notificationData['roomId'];
              callerId = notificationData['callerInfo'];
            });

            makeFakeCallInComing(callerId!);
          } else if (notificationData['type'] != null &&
              notificationData['type'] == "Call Rejected") {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Call Rejected"),
                duration:
                    Duration(seconds: 3), // Optional: duration of snackbar
              ),
            );
          }
        }
        // Check if the callerId in the payload matches the currentCallerId
        if (device == "Android") {
          if (notificationData['type'] == "Call Accepted") {
            setState(() {
              roomId_sender = notificationData['roomId'];
            });

            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MeetingScreen(
                  meetingId: roomId_sender,
                  callerId: callerId!,
                  token: videoSdkKey!,
                  url: apiUrl!,
                ),
              ),
            );
          } else if (notificationData['type'] != null &&
              notificationData['type'] == "Call Rejected") {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Call Rejected"),
                duration:
                    Duration(seconds: 3), // Optional: duration of snackbar
              ),
            );
          }
        }
      });

      // Handle background notifications
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Notification opened: ${message.data}");
        _handleIncomingNotification(message.data);
      });
    } catch (e) {
      debugPrint("Error initializing Firebase: $e");
    }
  }

  Future<String> generateOrFetchCallerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedCallerId = prefs.getString('callerId');
    if (storedCallerId == null) {
      String newCallerId = _generateRandom8DigitNumber();
      await prefs.setString('callerId', newCallerId);
      storedCallerId = newCallerId;
      print("Generated new Caller ID: $storedCallerId");
    } else {
      print("Fetched stored Caller ID: $storedCallerId");
    }
    setState(() {
      callerId = storedCallerId;
      print("CallerId in side   generate or fetch callerid:$callerId");
    });
    return storedCallerId;
  }

  String _generateRandom8DigitNumber() {
    Random random = Random();
    int min = 10000000;
    int max = 99999999;
    return (min + random.nextInt(max - min)).toString();
  }

  Future<void> _getFcmTokenAndStoreInFirebase() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      if (await Permission.phone.request().isGranted) {
        print("True");
      }

      String? token = await messaging.getToken();

      if (token != null && callerId != null) {
        DatabaseReference ref =
            FirebaseDatabase.instance.ref("users/$callerId");
        await ref.set({"fcmToken": token});
      } else {
        print("Unable to store FCM token. Caller ID or token is null.");
      }
    } catch (e) {
      print("Error getting FCM token or storing it: $e");
    }
  }

  Future<void> listenerEvent(void Function(CallEvent) callback) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('HOME: $event');
        switch (event!.event) {
          case Event.actionCallIncoming:
            break;
          case Event.actionCallStart:
            break;
          case Event.actionCallAccept:
            await sendCallStatus(
              serverUrl: apiUrl!,
              callerId: callerId!,
              status: "Call Accepted",
              roomId: romId_receiver,
            );

            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MeetingScreen(
                  meetingId: romId_receiver,
                  token: videoSdkKey!,
                  callerId: callerId!,
                  url: apiUrl!,
                ),
              ),
            );
            setState(() {
              callStatus = "Call Answered";
            });
            break;
          case Event.actionCallDecline:
            await sendCallStatus(
              serverUrl: apiUrl!,
              callerId: callerId!,
              status: "Call Rejected",
              roomId: romId_receiver,
            );
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => Home(
                  callerID: "",
                ),
              ),
            );
            // Show a snackbar

            setState(() {
              callStatus = "No time Today";
            });
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            break;
          case Event.actionCallEnded:
            break;
          case Event.actionCallTimeout:
            break;
          case Event.actionCallCallback:
            break;
          case Event.actionCallToggleHold:
            break;
          case Event.actionCallToggleMute:
            break;
          case Event.actionCallToggleDmtf:
            break;
          case Event.actionCallToggleGroup:
            break;
          case Event.actionCallToggleAudioSession:
            break;
          case Event.actionCallCustom:
            break;
        }
        callback(event);
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> _listenForCallEvents() async {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onCallAnswered":
          if (background == "ture") {
            await getRoomByCallee(callerId!);

            await sendCallStatus(
              serverUrl: apiUrl!,
              callerId: callerId!,
              status: "Call Accepted",
              roomId: romId_receiver,
            );

            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MeetingScreen(
                  meetingId: romId_receiver,
                  token: videoSdkKey!,
                  callerId: callerId!,
                  url: apiUrl!,
                ),
              ),
            );
            setState(() {
              callStatus = "Call Answered";
            });
            break;
          } else {
            bool check = await getRoomByCallee(callerId!);
            if (check == true) {
              await sendCallStatus(
                serverUrl: apiUrl!,
                callerId: caller_id_backgroung,
                status: "Call Accepted",
                roomId: romId_receiver,
              );
            } else {
              await sendCallStatus(
                serverUrl: apiUrl!,
                callerId: callerId!,
                status: "Call Accepted",
                roomId: romId_receiver,
              );
            }

            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MeetingScreen(
                  meetingId: romId_receiver,
                  token: videoSdkKey!,
                  callerId: callerId!,
                  url: apiUrl!,
                ),
              ),
            );
            setState(() {
              callStatus = "Call Answered";
            });
            break;
          }
        case "onCallRejected":
          print("Dart side: Call Rejected - ${call.arguments}");

          if (background == "ture") {
            print("Heloooooooooo");
            await getRoomByCallee(callerId!);
            print("callerId: $callerId");

            await sendCallStatus(
              serverUrl: apiUrl!,
              callerId: callerId!,
              status: "Call Rejected",
              roomId: romId_receiver,
            );

            print("roomId:$romId_receiver");
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => Home(
                        callerID: "",
                      )),
            );
            setState(() {
              callStatus = "Call Rejected";
            });
            break;
          } else {
            bool check = await getRoomByCallee(callerId!);
            if (check == true) {
              await sendCallStatus(
                serverUrl: apiUrl!,
                callerId: caller_id_backgroung,
                status: "Call Rejected",
                roomId: romId_receiver,
              );
            } else {
              await sendCallStatus(
                serverUrl: apiUrl!,
                callerId: callerId!,
                status: "Call Rejected",
                roomId: romId_receiver,
              );
            }

            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => Home(
                        callerID: "",
                      )),
            );
            setState(() {
              callStatus = "Call Rejected";
            });
            break;
          }

        default:
          print("Unknown method: ${call.method}");
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('foreground');
        background = "false";
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (like during a phone call)
        break;
      case AppLifecycleState.paused:
        print('background');
        background = "true";
        break;
      case AppLifecycleState.detached:
        // App is terminated
        break;
      default:
        break;
    }
  }

  Future<void> sendCallStatus({
    required String serverUrl,
    required String callerId,
    required String status,
    required String roomId,
  }) async {
    final url = Uri.parse('$serverUrl/send-call-status');

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

  void _handleIncomingNotification(Map<String, dynamic> data) {
    String callerId1 = callerId!;
    makeCall(callerId1);

    try {
      if (data.containsKey('callerId')) {
      } else {
        debugPrint("Invalid notification payload: $data");
      }
    } catch (e) {
      debugPrint("Error handling notification: $e");
    }
  }

  Future<void> makeCall(String callerID) async {
    callerId = callerID;
    if (await Permission.phone.isDenied) {
      await Permission.phone.request();
    }
    if (await Permission.phone.isGranted) {
      try {
        final result = await platform
            .invokeMethod('handleIncomingCall', {'callerId': callerID});
        print('Result: $result');
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('Phone permission is not granted');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoSDK CallKit Example'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card to show Caller ID
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Your Caller ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<String>(
                          future: deviceno,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              return Text(
                                '${snapshot.data}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else {
                              return const Text('No Caller ID found');
                            }
                          },
                        ),
                        if (callerId != null)
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.purple),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: callerId!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Caller ID copied to clipboard',
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Text Field to input Call ID
            TextField(
              controller: callIdController,
              decoration: InputDecoration(
                labelText: 'Enter call ID of user you want to call',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Conditional Button or Calling Status
            isCalling
                ? Center(
                    child: Text(
                      "Calling ${callIdController.text}...",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      // Set calling state to true
                      setState(() {
                        isCalling = true;
                      });

                      // Perform the Call Logic
                      String calleeId = callIdController.text;
                      print("CallerId the main: $callerId");
                      final http.Response httpResponse = await http.post(
                        Uri.parse("https://api.videosdk.live/v2/rooms"),
                        headers: {'Authorization': videoSdkKey!},
                      );
                      print(httpResponse.body);
                      setState(() {
                        roomId_sender =
                            json.decode(httpResponse.body)['roomId'];
                      });
                      print("Object : $callerId, $roomId_sender");
                      await addCallerRoomAndCallee(
                          callerId!, roomId_sender, calleeId);

                      print("http response:$roomId_sender");
                      print("Caller ID: $callerId, $calleeId");
                      sendNotification(
                        callerId: calleeId,
                        callerInfo: callerId!,
                        roomId: roomId_sender,
                        token: videoSdkKey!,
                      );

                      // Delay for 15 seconds before resetting the button
                      Future.delayed(const Duration(seconds: 15), () {
                        setState(() {
                          isCalling = false;
                        });
                      });
                    },
                    child: const Text(
                      'Call',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

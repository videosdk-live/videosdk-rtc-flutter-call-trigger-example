import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:videosdk_flutter_example/home.dart';

import 'package:videosdk_flutter_example/meeting/meeting_screen.dart';

String? videoSdkKey = dotenv.env["VIDEO_SDK_KEY"];
String? url = dotenv.env["SERVER_URL"];
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

String device = "";
String checkPlatform() {
  if (Platform.isAndroid) {
    return "Android";
  } else if (Platform.isIOS) {
    return "iOS";
  } else {
    return "Unsupported Platform";
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await dotenv.load(fileName: ".env");
  device = checkPlatform();

  runApp(const MyApp());

  const platform = MethodChannel('com.yourapp/call');
  platform.setMethodCallHandler((call) async {
    if (call.method == "incomingCall") {
      final data = call.arguments as Map;
      final roomId = data["roomId"];
      final callerId = data["callerId"];
      print("Incoming call from $callerId to room $roomId");
      // Navigate to call screen or trigger call logic
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (device == "Android") {
      return MaterialApp(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '');
          if (uri.path == '/meeting') {
            final roomId = uri.queryParameters['roomId'];
            final callerId = uri.queryParameters['callerId'];
            print("Callaer id in Main.dart file: $callerId");
            return MaterialPageRoute(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeetingScreen(
                        meetingId: roomId!,
                        token: videoSdkKey!,
                        callerId: callerId!,
                        url: url!,
                        source: "true",
                      ),
                    ),
                    (route) => false, // Removes all previous routes
                  );
                });
                return const SizedBox(); // Placeholder widget (not displayed)
              },
            );
          } else if (uri.path == '/home') {
            final callerId = uri.queryParameters['callerId'];
            return MaterialPageRoute(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(
                        callerID: callerId!,
                        source: "true",
                      ),
                    ),
                    (route) => false, // Removes all previous routes
                  );
                });
                return const SizedBox(); // Placeholder widget (not displayed)
              },
            );
          } else {
            return MaterialPageRoute(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                    (route) => false, // Removes all previous routes
                  );
                });
                return const SizedBox(); // Placeholder widget (not displayed)
              },
            );
          }
        },
        debugShowCheckedModeBanner: false,
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
      );
    }
  }
}

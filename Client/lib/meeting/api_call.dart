import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

//Auth token we will use to generate a meeting and connect to it
  String? token = dotenv.env["VIDEO_SDK_KEY"];

// API call to create meeting
Future<String> createMeeting() async {
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': token!},
  );

//Destructuring the roomId from the response
  return json.decode(httpResponse.body)['roomId'];
}

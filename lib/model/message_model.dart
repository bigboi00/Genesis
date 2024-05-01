import 'package:genesis/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MessageModel {
  Stream<List<Map<String, dynamic>>> getUsersStream() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the chat list from SharedPreferences
    String? jsonList = prefs.getString('chat_list');
    // If chat list exists, yield it as a stream
    if (jsonList != null) {
      List<Map<String, dynamic>> chatList = List<Map<String, dynamic>>.from(jsonDecode(jsonList));
      yield chatList;
    }
  }

    Stream<List<Map<String, dynamic>>> getUsersStreamMessage() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the messages from SharedPreferences
    String? jsonString = prefs.getString(StorageManager.key);
    // If messages exist, yield them as a stream
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      yield List<Map<String, dynamic>>.from(jsonList);
    }
  }
}

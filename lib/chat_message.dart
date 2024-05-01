import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String userId;
  final String text;
  final DateTime createdAt;
  final String? mediaType;

  Message({
    required this.userId,
    required this.text,
    required this.createdAt,
    this.mediaType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'mediaType': mediaType,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      userId: json['userId'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      mediaType: json['mediaType'],
    );
  }
}

class StorageManager {
  static const _key = 'messages';

  static String get key => _key; 

  static Future<void> saveMessages(List<ChatMessage> chatMessages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesToSave = chatMessages.map((chatMessage) => Message(
        userId: chatMessage.user.id,
        text: chatMessage.text,
        createdAt: chatMessage.createdAt,
        mediaType: chatMessage.medias?.isNotEmpty == true ? chatMessage.medias!.first.type.toString() : null,
      )).toList();
      final jsonString = jsonEncode(messagesToSave);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      print("Error saving messages: $e");
      rethrow; // Propagate the error if needed
    }
  }

  static Future<List<Message>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Message(
        userId: json['userId'],
        text: json['text'],
        createdAt: DateTime.parse(json['createdAt']),
        mediaType: json['mediaType'],
      )).toList();
    } catch (e) {
      print("Error loading messages: $e");
      return [];
    }
  }
}

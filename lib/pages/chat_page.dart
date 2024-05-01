import 'dart:io';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:genesis/chat_message.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String age;
  final String name;
  final String gender;
  final String id;
  final String userId;


  const ChatPage({super.key, required this.age, required this.name,  required this.gender, required this.id, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Gemini gemini = Gemini.instance;
  bool _isMounted = false;
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadAndDisplayMessages();
  }
  
  Future<void> _loadAndDisplayMessages() async {
    List<Message> loadedMessages = await StorageManager.loadMessages();
    if (_isMounted) { // Check if the widget is still mounted
      setState(() {
        messages = loadedMessages
            .where((msg) => msg.userId == widget.userId || msg.userId == widget.id)
            .map((msg) {
          return ChatMessage(
            user: ChatUser(
              id: msg.userId,
              profileImage: "https://designerapp.officeapps.live.com/designerapp/document.ashx?path=/73681d9a-9775-4e45-8ead-38b4941b277a/DallEGeneratedImages/dalle-dc470507-734c-482b-bf4f-e0c7fa04a5800251687729091967176200.jpg&dcHint=IndiaCentral&fileToken=b62ed7fa-b55d-47f9-a562-92e478ab516a",
            ),
            text: msg.text,
            createdAt: msg.createdAt,
          );
        })
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 250, 170, 21), 
        centerTitle: true,
        title: Text(
          widget.name,
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    ChatUser currentUser = ChatUser(id: widget.userId, firstName: "User");
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
          onPressed: _sendMediaMessage,
          icon: const Icon(
            Icons.image,
          ),
        )
      ]),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    ChatUser geminiUser = ChatUser(
      id: widget.id,
      firstName: widget.name,
      profileImage:
          "https://designerapp.officeapps.live.com/designerapp/document.ashx?path=/73681d9a-9775-4e45-8ead-38b4941b277a/DallEGeneratedImages/dalle-dc470507-734c-482b-bf4f-e0c7fa04a5800251687729091967176200.jpg&dcHint=IndiaCentral&fileToken=b62ed7fa-b55d-47f9-a562-92e478ab516a",
    );
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question =  "I want u to roleplay as a character called ${widget.name},gender: ${widget.gender},age: ${widget.age}just reply me the message no need to make a setting or anything ${chatMessage.text}";
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        if (!mounted) return;
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(
            () {
              messages = [lastMessage!, ...messages];
            },
          );
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
            StorageManager.saveMessages(messages);
          });
        }
      });
    } catch (e) {

    }
  }

  void _sendMediaMessage() async {
    ChatUser currentUser = ChatUser(id: widget.userId, firstName: "User");
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }

}



import 'dart:convert';
import 'package:genesis/model/chat_model.dart';
import 'package:genesis/screen/chat_screen.dart';
import 'package:genesis/screen/community_screen.dart';
import 'package:genesis/screen/game_screen.dart';
import 'package:genesis/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadUserLevel();
  }

Future<void> loadUserLevel() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if JSON data exists and user level is 1, if not, add default data
  String? existingJson = prefs.getString('chat_list');
  List<Map<String, dynamic>> chatList = [];

  // Generate unique IDs for chat models
  String id = const Uuid().v4();
  String userId = "${id}1";

  // Define the default chat model for Mei
  ChatModel chatModel = ChatModel(
    gender: 'Female', 
    name: 'Mei', 
    age: '35',
    id: id,
    userId: userId,
    profile: 'https://designerapp.officeapps.live.com/designerapp/document.ashx?path=/73681d9a-9775-4e45-8ead-38b4941b277a/DallEGeneratedImages/dalle-dc470507-734c-482b-bf4f-e0c7fa04a5800251687729091967176200.jpg&dcHint=IndiaCentral&fileToken=b62ed7fa-b55d-47f9-a562-92e478ab516a',
  );

  // Add default data if existingJson is not null
  if (existingJson != null) {
    chatList = List<Map<String, dynamic>>.from(jsonDecode(existingJson));
  }

  // Check if Mei already exists in the chat list
  bool meiExists = chatList.any((chat) => chat['name'] == 'Mei');

  // If Mei doesn't exist, add her to the chat list
  if (!meiExists) {
    chatList.add(chatModel.toJson());
  }

  // Encode the updated chat list to JSON and save it to SharedPreferences
  String updatedJson = jsonEncode(chatList);
  await prefs.setString('chat_list', updatedJson);
}



  void navigateToXoxoScreen() {
    setState(() {
      _currentIndex = 2; // Index of the XoxoScreen in the bottom navigation bar
    });
  }
  
  final List<Widget> _screens = [
    ChatScreen(), // Replace with your chat screen widget
    GameScreen(), // Replace with your call screen widget
    const CommunityScreen(), // Replace with your community screen widget
  ];

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              "Genesis",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 250, 170, 21), // Set app bar background color
        elevation: 0, // Remove app bar elevation
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
              // Add your settings action here
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Communities',
          ),
        ],
        selectedItemColor: Colors.blue, // Set selected item color
        unselectedItemColor: Colors.grey, // Set unselected item color
        backgroundColor: Colors.white, // Set background color
        elevation: 10, // Add elevation to bottom navigation bar
      ),
    );
  }
}

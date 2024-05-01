import 'package:flutter/material.dart';
import 'package:genesis/model/message_model.dart';
import 'package:genesis/pages/chat_page.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key
  });

    // Function to truncate the message to a certain length
  String _truncateMessage(String message, int maxLength) {
    if (message.length <= maxLength) {
      return message;
    } else {
      return '${message.substring(0, maxLength)}...';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: MessageModel().getUsersStream(),
              builder: (context, usersSnapshot) {
                if (!usersSnapshot.hasData) {
                  return const Center(
                    child: Text("No Messages"),
                  );
                }
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: MessageModel().getUsersStreamMessage(),
                  builder: (context, messagesSnapshot) {

                    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
                    
                    return ListView.builder(
                      itemCount: usersSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final userData = usersSnapshot.data![index];
                        final String name = userData['name'];
                        final String age = userData['age'];
                        final String gender = userData['gender'];
                        final String id = userData['id'];
                        final String userId = userData['userId'];

                        // Filter messages for the current user
                        final List<Map<String, dynamic>> userMessages = messagesSnapshot.data ?? [];
                        final List<Map<String, dynamic>> userMessagesFiltered = userMessages.where((message) => message['userId'] == id).toList();

                        // Sort messages by timestamp
                        userMessagesFiltered.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

                        final Map<String, dynamic>? newestMessageData = userMessagesFiltered.isNotEmpty ? userMessagesFiltered.first : null;

                        final String newestMessage = newestMessageData != null ? _truncateMessage(newestMessageData['text'] ?? '', 32) : '';
                        final DateTime timestamp = newestMessageData != null && newestMessageData['createdAt'] != null
                            ? DateTime.parse(newestMessageData['createdAt'])
                            : DateTime.now();

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(userData['profile']),
                            radius: 24,
                          ),
                          title: Text(name, style: const TextStyle(fontSize: 20),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(newestMessage),
                              if (newestMessage.isNotEmpty) // Check if lastMessage is not empty
                                Text(
                                  formatter.format(timestamp),
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  age: age,
                                  name: name,
                                  gender: gender,
                                  id: id,
                                  userId: userId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
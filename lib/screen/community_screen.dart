import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}


class _CommunityScreenState extends State<CommunityScreen> {
  late Timer _timer;
  List<PostCard> posts = [];

  @override
  void initState() {
    super.initState(); 
     
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      generateGeminiPost(); // Generate a Gemini post every 30 minutes
    });
    loadPosts(); 
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

void generateGeminiPost() {
  final gemini = Gemini.instance;
  gemini.text("I want u to roleplay as a character called Mei, gender: Female, ,age: 35 and i want u to write a post of anything as the character think of ")
      .then((value) {
    if (mounted) { // Check if the widget is mounted
      setState(() {
        posts.insert(0, PostCard(
          username: 'Mei',
          imageUrl: 'https://designerapp.officeapps.live.com/designerapp/document.ashx?path=/73681d9a-9775-4e45-8ead-38b4941b277a/DallEGeneratedImages/dalle-dc470507-734c-482b-bf4f-e0c7fa04a5800251687729091967176200.jpg&dcHint=IndiaCentral&fileToken=b62ed7fa-b55d-47f9-a562-92e478ab516a',
          caption: value?.content?.parts?.last.text ?? 'No caption',
        ));
        savePosts();
      });
    }
  });
}


  // Method to convert List<PostCard> to JSON and save it
  void savePosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> postJsonList = posts.map((post) => json.encode(post.toJson())).toList();
    prefs.setStringList('posts', postJsonList);
  }

  // Method to load saved JSON data and convert it back to List<PostCard>
  void loadPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? postJsonList = prefs.getStringList('posts');
    if (postJsonList != null) {
      setState(() {
        posts = postJsonList.map((jsonString) => PostCard.fromJson(json.decode(jsonString))).toList();
        _timer.cancel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return posts[index];
        },
      ),

    );
  }
}

class PostCard extends StatefulWidget  {
  final String username;
  final String imageUrl;
  final String caption;

  const PostCard({super.key, 
    required this.username,
    required this.imageUrl,
    required this.caption,
  });

    // Create a named constructor for creating PostCard objects from JSON
  PostCard.fromJson(Map<String, dynamic> json, {super.key})
      : username = json['username'],
        imageUrl = json['imageUrl'],
        caption = json['caption'];

  // Method to convert PostCard object to JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'imageUrl': imageUrl,
        'caption': caption,
      };

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  TextEditingController commentController = TextEditingController();
  List<String> comments = [];
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    loadPostStatus();
    loadComments();
  }

  Future<void> loadPostStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? liked = prefs.getBool('liked_${widget.username}');
    if (liked != null) {
      setState(() {
        isLiked = liked;
      });
    }
  }

  Future<void> loadComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      comments = prefs.getStringList('comments_${widget.username}') ?? [];
    });
  }

  Future<void> addComment(String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    comments.add(comment);
    prefs.setStringList('comments_${widget.username}', comments);
    setState(() {
      commentController.clear();
    });
  }

  Future<void> toggleLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool newLikedStatus = !isLiked;
    setState(() {
      isLiked = newLikedStatus;
    });
    prefs.setBool('liked_${widget.username}', newLikedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(widget.imageUrl),
                ),
                const SizedBox(width: 8.0),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Image.network(
            widget.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.caption,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: toggleLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Add Comment'),
                        content: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your comment',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              String comment = commentController.text;
                              if (comment.isNotEmpty) {
                                addComment(comment);
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.comment),
              ),
            ],
          ),
          if (comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comments:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: comments.map((comment) {
                      return Text('- $comment');
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
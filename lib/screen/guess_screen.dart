import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GuessingGameScreen extends StatefulWidget {
  const GuessingGameScreen({super.key});

  @override
  _GuessingGameScreenState createState() => _GuessingGameScreenState();
}

class _GuessingGameScreenState extends State<GuessingGameScreen> {
  File? _image;
  String? geminiGuess;
  String? geminiResponse;
  bool isLoading = false;
  bool isRightLoading = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _getImage() async {
    if (_isMounted) {
      ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          geminiGuess = null; // Reset Gemini's guess when a new image is selected
          geminiResponse = null;
        });

        // Process the image and get its contents
        String imageContents = await processImage(_image!);

        // Pass image contents to Gemini to make a guess
        makeGeminiGuess(imageContents);
      }
    }
  }

  Future<String> processImage(File image) async {
    // Implement image processing logic here
    // This could involve using an image recognition API or model
    // Example:
    // Send image to image recognition API and get the result
    String imageContents = "Example image contents"; // Placeholder for actual image contents
    return imageContents;
  }

  Future<void> makeGeminiGuess(String imageContents) async {
    if (_isMounted) {
      setState(() {
        isLoading = true; // Start loading
      });
      final gemini = Gemini.instance;
      gemini
          .textAndImage(text: "I want u to roleplay as a character called Mei, gender: Female, ,age: 35, reply the message and image only. Message:  What Mei think about this image?",
           images: [_image!.readAsBytesSync()])
          .then((value) {
        if (_isMounted) {
          setState(() {
            geminiGuess = value?.content?.parts?.last.text;
            isLoading = false;
          });
        }
      });
    }
  }

  void handleRightAnswer() {
    if (_isMounted) {
      setState(() {
        isRightLoading = true; // Start loading
      });
      final gemini = Gemini.instance;
      gemini
          .text("I want u to roleplay as a character called Mei, gender: Female, ,age: 35, reply the message only. Message: Mei, u got it right! The image is accurate.")
          .then((value) {
        if (_isMounted) {
          setState(() {
            geminiResponse = value?.content?.parts?.last.text;
            isRightLoading = false;
          });
        }
      });
    }
  }

  void handleWrongAnswer() {
    if (_isMounted) {
      setState(() {
        isRightLoading = true; // Start loading
      });
      final gemini = Gemini.instance;
      gemini
          .text("I want u to roleplay as a character called Mei, gender: Female, ,age: 35, reply the message only. Message: Oops! It seems my guess was not accurate. Can u try again, Mei?")
          .then((value) {
        if (_isMounted) {
          setState(() {
            geminiResponse = value?.content?.parts?.last.text;
            isRightLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guessing Game'),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 250, 170, 21), 
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator(), 
              if (geminiGuess != null) 
                const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://designerapp.officeapps.live.com/designerapp/document.ashx?path=/73681d9a-9775-4e45-8ead-38b4941b277a/DallEGeneratedImages/dalle-dc470507-734c-482b-bf4f-e0c7fa04a5800251687729091967176200.jpg&dcHint=IndiaCentral&fileToken=b62ed7fa-b55d-47f9-a562-92e478ab516a',
                  ),
                ),
              if (geminiGuess != null) ...[
                Text(
                  'Mei\'s Guess: $geminiGuess',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => handleRightAnswer(),
                      child: const Text('Right'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => handleWrongAnswer(),
                      child: const Text('Wrong'),
                    ),
                  ],
                ),
              ],
              if (isRightLoading)
                const CircularProgressIndicator(), 
              if (geminiResponse != null) ...[
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200), // Set the maximum height here
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Mei\'s Response: $geminiResponse',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

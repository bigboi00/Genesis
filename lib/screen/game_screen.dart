import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:genesis/screen/punch_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? geminiMessage;
  String? geminiChoice;
  String? resultMessage;
  String? geminiResponse;
  bool isLoading = false; // Track loading state
  bool isPromptLoading = false;
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

  void startGame() {
    setState(() {
      geminiMessage = null;
      geminiChoice = null;
      resultMessage = null;
      geminiResponse = null;
    });
  }

  void playGame(String playerChoice) {
    if (_isMounted) {
      setState(() {
        isLoading = true; // Start loading
      });
      final gemini = Gemini.instance;
      gemini
          .text("Play rock-paper-scissors with me, give me response of rock-paper-scissors only")
          .then((value) {
        if (_isMounted) {
          setState(() {
            geminiChoice = value?.content?.parts?.last.text;
            if (geminiChoice != null) {
              resultMessage = getResultMessage(playerChoice, geminiChoice!);
              geminiResponse = "Gemini chose $geminiChoice";
            } else {
              resultMessage = "Gemini didn't provide a response.";
            }
            isLoading = false; // Stop loading
          });
        }
      });
    }
  }

  void interactMessage(String playerChoice, String geminiChoice) {
    if (_isMounted) {
      setState(() {
        isPromptLoading = true; // Start loading
      });
      final gemini = Gemini.instance;
      gemini
          .text(
              "I want u to roleplay as a character called Mei, gender: Female, ,age: 35, I had play rock-paper-scissors with Mei, and Mei choosen $geminiChoice and me choosen $playerChoice,what is the result with emoji, and Mei reply")
          .then((value) {
        if (_isMounted) {
          setState(() {
            geminiMessage = value?.content?.parts?.last.text;
            if (geminiMessage != null) {
              geminiMessage = geminiMessage;
              isPromptLoading = false;
            }
          });
        }
      });
    }
  }

  String getResultMessage(String playerChoice, String geminiChoice) {
    interactMessage(playerChoice, geminiChoice);
    if (playerChoice == geminiChoice) {
      return "It's a tie! ✌️";
    } else if ((playerChoice == 'Rock' && geminiChoice == 'Scissors') ||
        (playerChoice == 'Paper' && geminiChoice == 'Rock') ||
        (playerChoice == 'Scissors' && geminiChoice == 'Paper')) {
      return "You win! 🎉";  
    } else {
      return "You lose! 😿";
    }
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Paper Scissors'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PunchingGameScreen()),
              );
            },
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (geminiChoice == null) 
            const Text(
              'Choose your choice:',
              style: TextStyle(fontSize: 20),
            ),  
            const SizedBox(height: 20),
            if (geminiMessage != null) // Only show the button if the game has ended
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://designerapp.officeapps.live.com/designerapp/document.ashx?path=/73681d9a-9775-4e45-8ead-38b4941b277a/DallEGeneratedImages/dalle-dc470507-734c-482b-bf4f-e0c7fa04a5800251687729091967176200.jpg&dcHint=IndiaCentral&fileToken=b62ed7fa-b55d-47f9-a562-92e478ab516a',
                ),
              ),
              const SizedBox(height: 50),
            if (geminiMessage != null)
              Text(
                geminiMessage!,
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 20),
            if (isPromptLoading)
              const CircularProgressIndicator(),
            const SizedBox(height: 20),
            if (geminiChoice != null)
              ElevatedButton(
                onPressed: startGame,
                child: const Text('Play Again'),
              ),
            const SizedBox(height: 20),
            if (geminiChoice == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => playGame('Rock'),
                    child: const Text('🪨 Rock'),
                  ),
                  ElevatedButton(
                    onPressed: () => playGame('Paper'),
                    child: const Text('📄 Paper'),
                  ),
                  ElevatedButton(
                    onPressed: () => playGame('Scissors'),
                    child: const Text('✂️ Scissors'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator(), // Show loading indicator
          ],
        ),
      ),
    );
  }
}
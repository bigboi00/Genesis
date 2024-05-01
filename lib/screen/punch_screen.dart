import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:genesis/screen/guess_screen.dart';

class PunchingGameScreen extends StatefulWidget {
  const PunchingGameScreen({super.key});

  @override
  _PunchingGameScreenState createState() => _PunchingGameScreenState();

}

class _PunchingGameScreenState extends State<PunchingGameScreen> {
  bool _isMounted = false;
  int playerHealth = 20;
  int geminiHealth = 20;
  bool playerTurn = true;
  bool gameOver = false;
  String? geminiResponse;
  bool isLoading = false;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    startGame();
  }

  void startGame() {
    setState(() {
      playerHealth = 20;
      geminiHealth = 20;
      playerTurn = random.nextBool(); // Randomly determine first turn
      gameOver = false;
      geminiResponse = null; // Reset Gemini's response
    });
  }

  void attack(String attacker) {
    final int damage = random.nextInt(5) + 1; // Random damage between 1 and 5
    setState(() {
      if (attacker == 'player') {
        geminiHealth -= damage;
      } else {
        playerHealth -= damage;
      }
      // Check for game over
      if (playerHealth <= 0 || geminiHealth <= 0) {
        gameOver = true;
      } else {
        // Switch turns
        playerTurn = !playerTurn;
        // Get Gemini's response
        getGeminiResponse();
      }
    });
  }

  void getGeminiResponse() {
    setState(() {
      isLoading = true; // Start loading
    });
    final gemini = Gemini.instance;
    final damage = playerTurn ? 20 - playerHealth : 20 - geminiHealth;
    print(playerTurn);
    gemini
        .text(" want u to roleplay as a character called Mei, gender: Female, ,age: 35, Let's play a punch game, with us both having the same health of 20. Here the scenario ${playerTurn ? 'Mei' : 'Player'} is attacking now, damage: $damage,  reply the message only. Message: just response this situation, the damage, add commentary, do not continue the game")
        .then((value) {
      if (_isMounted) { // Check if the widget is still mounted
        setState(() {
          geminiResponse = value?.content?.parts?.last.text;
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punching Game'),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 250, 170, 21), 
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GuessingGameScreen()),
              );
            },
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Player Health: $playerHealth',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Mei Health: $geminiHealth',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              if (!gameOver)
                Text(
                  '${playerTurn ? 'Player' : 'Mei'}\'s Turn',
                  style: const TextStyle(fontSize: 20),
                ),
              if (isLoading)
                const SizedBox(
                  width: 20, // Specify the width of the container
                  height: 20, // Specify the height of the container
                  child: CircularProgressIndicator(),
                ),
              if (gameOver)
                Text(
                  '${playerHealth <= 0 ? 'Mei' : 'Player'} Wins!',
                  style: const TextStyle(fontSize: 20),
                ),
              const SizedBox(height: 20),
              if (geminiResponse != null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 480),
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Text(
                      'Mei Response: \n $geminiResponse',
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (!gameOver && playerTurn)
                ElevatedButton(
                  onPressed: () => attack('player'),
                  child: const Text('Punch Mei'),
                ),
              if (!gameOver && !playerTurn)
                ElevatedButton(
                  onPressed: () => attack('Mei'),
                  child: const Text('Mei Attacks'),
                ),
              const SizedBox(height: 20),
              if (gameOver)
                ElevatedButton(
                  onPressed: startGame,
                  child: const Text('Play Again'),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

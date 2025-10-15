import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Who is the Spy',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const StartGameScreen(),
    );
  }
}

// --- 1. Game Data ---

class GameData {
  final int totalPlayers;
  final int spyIndex;
  final String secretWord;
  final String location;

  GameData(this.totalPlayers, List<String> availableWords, List<String> availableLocations)
      : spyIndex = Random().nextInt(totalPlayers),
        secretWord = availableWords[Random().nextInt(availableWords.length)],
        location = availableLocations[Random().nextInt(availableLocations.length)];
}

// --- Default Word Lists ---

class DefaultWords {
  static List<String> locations = [
    "School", "Hospital", "Airport", "Park", "Bank", "Restaurant", "Cinema"
  ];
  static List<String> words = [
    "Chair", "Pen", "Book", "Tree", "Cloud", "Water", "Door"
  ];
}

// --- 2. Start Game Screen ---

class StartGameScreen extends StatefulWidget {
  const StartGameScreen({super.key});

  @override
  State<StartGameScreen> createState() => _StartGameScreenState();
}

class _StartGameScreenState extends State<StartGameScreen> {
  int _playerCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Who is the Spy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Select number of players:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, size: 40, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        if (_playerCount > 3) _playerCount--;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      '$_playerCount',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 40, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        if (_playerCount < 10) _playerCount++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordSelectionScreen(playerCount: _playerCount),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text(
                  'Choose Words/Places and Start Game',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. Word Selection Screen ---

class WordSelectionScreen extends StatefulWidget {
  final int playerCount;
  const WordSelectionScreen({super.key, required this.playerCount});

  @override
  State<WordSelectionScreen> createState() => _WordSelectionScreenState();
}

class _WordSelectionScreenState extends State<WordSelectionScreen> {
  List<String> _currentWords = List.from(DefaultWords.words);
  List<String> _currentLocations = List.from(DefaultWords.locations);

  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void _addWord() {
    final newWord = _wordController.text.trim();
    if (newWord.isNotEmpty) {
      setState(() {
        _currentWords.add(newWord);
        _wordController.clear();
      });
    }
  }

  void _addLocation() {
    final newLocation = _locationController.text.trim();
    if (newLocation.isNotEmpty) {
      setState(() {
        _currentLocations.add(newLocation);
        _locationController.clear();
      });
    }
  }

  void _confirmAndStartGame() {
    if (_currentWords.isEmpty || _currentLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one word and one location!')),
      );
      return;
    }

    final gameData = GameData(widget.playerCount, _currentWords, _currentLocations);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoleRevealScreen(gameData: gameData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Words and Locations'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text('Secret Words (${_currentWords.length}):',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _wordController,
                  decoration: const InputDecoration(hintText: 'New word (e.g., Remote, Fan)'),
                ),
              ),
              IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _addWord),
            ],
          ),
          Wrap(
            spacing: 8.0,
            children: _currentWords
                .map((word) => Chip(
              label: Text(word),
              onDeleted: () => setState(() => _currentWords.remove(word)),
            ))
                .toList(),
          ),
          const Divider(height: 30, thickness: 2),
          Text('Locations (${_currentLocations.length}):',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(hintText: 'New location (e.g., Jungle, Cruise Ship)'),
                ),
              ),
              IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _addLocation),
            ],
          ),
          Wrap(
            spacing: 8.0,
            children: _currentLocations
                .map((loc) => Chip(
              label: Text(loc),
              onDeleted: () => setState(() => _currentLocations.remove(loc)),
            ))
                .toList(),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _confirmAndStartGame,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              'Start with ${widget.playerCount} players!',
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. Role Reveal Screen ---

class RoleRevealScreen extends StatefulWidget {
  final GameData gameData;
  const RoleRevealScreen({super.key, required this.gameData});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  int _currentPlayer = 0;
  bool _isCardVisible = false;

  void _nextPlayer() {
    setState(() {
      _isCardVisible = false;
      _currentPlayer++;
    });
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GamePlayScreen(gameData: widget.gameData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPlayer >= widget.gameData.totalPlayers) {
      return Scaffold(
        appBar: AppBar(title: const Text('Roles Revealed')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('All players have seen their roles.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.gavel),
                label: const Text('Start Discussion'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    bool isSpy = _currentPlayer == widget.gameData.spyIndex;
    String roleText = isSpy ? 'You are the Spy' : 'You are a Player';
    String wordText = isSpy ? '???' : widget.gameData.secretWord;
    String locationText = isSpy ? '???' : widget.gameData.location;
    String instructionText = isSpy ? 'Try to guess the secret word!' : 'Your word is: $wordText';

    return Scaffold(
      appBar: AppBar(title: Text('Player ${_currentPlayer + 1}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Player ${_currentPlayer + 1}',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const Text('Do not give your phone to anyone.',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => setState(() => _isCardVisible = !_isCardVisible),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 250,
                width: 300,
                decoration: BoxDecoration(
                  color: _isCardVisible
                      ? (isSpy ? Colors.red.shade700 : Colors.green.shade700)
                      : Colors.deepPurple.shade900,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isCardVisible
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(roleText,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    const Text('Secret Word:', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    Text(wordText,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 5),
                    const Text('Location:', style: TextStyle(fontSize: 16, color: Colors.white70)),
                    Text(locationText,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                )
                    : const Text('Tap to Reveal',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
            if (_isCardVisible)
              ElevatedButton(
                onPressed: _nextPlayer,
                child: Text(
                  _currentPlayer < widget.gameData.totalPlayers - 1
                      ? 'Got it, Next Player'
                      : 'Everyone Seen, Start Discussion',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- 5. Game Play Screen ---

class GamePlayScreen extends StatefulWidget {
  final GameData gameData;
  const GamePlayScreen({super.key, required this.gameData});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _timeRemaining = 120;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: _timeRemaining))
      ..addListener(() {
        setState(() {
          _timeRemaining = (120 * (1.0 - _controller.value)).round();
        });
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showVotingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vote for the Spy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Time to vote! Discuss and choose who you think the spy is.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showResultDialog();
                },
                child: const Text('Done Voting - See Result'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String spyName = "Player ${widget.gameData.spyIndex + 1}";
        String resultMessage =
            "The spy was: $spyName\n\nSecret Word: ${widget.gameData.secretWord}\nLocation: ${widget.gameData.location}";

        return AlertDialog(
          title: const Text('Game Result'),
          content: Text(resultMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Start New Game'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const StartGameScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          _controller.stop();
          _showVotingDialog();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion Time'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Start Discussing!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const SizedBox(height: 10),
              Text(
                'Players: ${widget.gameData.totalPlayers}, Spy: 1',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: _controller.value,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  ),
                  Text(
                    '$_timeRemaining',
                    style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                'Each player gives a clue about their word.\nTry to catch the spy!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _showVotingDialog,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Voting / Results'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

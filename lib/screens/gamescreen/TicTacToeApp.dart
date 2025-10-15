import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // The purple theme
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> _board = List.filled(9, "");
  String _currentPlayer = "X"; // Player is always X
  bool _gameOver = false;

  final Random _random = Random();

  final List<List<int>> _winningCombinations = const [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6]             // Diagonals
  ];

  void _handleTap(int index) {
    if (_board[index] == "" && !_gameOver && _currentPlayer == "X") {
      setState(() {
        _board[index] = "X";

        if (_checkWinner("X")) {
          _showDialog("You Win! 🎉");
          _gameOver = true;
          return;
        } else if (!_board.contains("")) {
          _showDialog("It's a Draw 🤝");
          _gameOver = true;
          return;
        }

        _currentPlayer = "O"; // Computer's turn
      });

      // Computer's move after a slight delay for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        _computerMove();
      });
    }
  }

  // --- AI Logic Functions ---

  // Helper function to check if a specific move leads to a win or blocks one
  int? _findWinningOrBlockingMove(String player) {
    for (var combo in _winningCombinations) {
      int count = 0;
      int emptyIndex = -1;

      // Check how many spots the player has in this combo
      for (int index in combo) {
        if (_board[index] == player) {
          count++;
        } else if (_board[index] == "") {
          emptyIndex = index;
        }
      }

      // If the player has 2 spots and the 3rd is empty, that empty spot is the target move.
      if (count == 2 && emptyIndex != -1) {
        return emptyIndex;
      }
    }
    return null;
  }

  // CORE AI LOGIC: Implements optimal strategy (Win or Draw)
  void _computerMove() {
    if (_gameOver) return;

    // 1. Check for a winning move for the Computer ("O")
    int? winningMove = _findWinningOrBlockingMove("O");
    if (winningMove != null) {
      _makeMove(winningMove);
      return;
    }

    // 2. Check for a blocking move for the Player ("X")
    int? blockingMove = _findWinningOrBlockingMove("X");
    if (blockingMove != null) {
      _makeMove(blockingMove);
      return;
    }

    // 3. Take the Center (index 4) if available
    if (_board[4] == "") {
      _makeMove(4);
      return;
    }

    // 4. Take a Corner if available (0, 2, 6, 8)
    List<int> corners = [0, 2, 6, 8];
    // Shuffle corners to add minor variety if multiple are available
    corners.shuffle(_random);
    for (int corner in corners) {
      if (_board[corner] == "") {
        _makeMove(corner);
        return;
      }
    }

    // 5. Take any available spot (Side/Edge)
    List<int> emptyIndexes = [];
    for (int i = 0; i < _board.length; i++) {
      if (_board[i] == "") emptyIndexes.add(i);
    }

    if (emptyIndexes.isNotEmpty) {
      int move = emptyIndexes[_random.nextInt(emptyIndexes.length)];
      _makeMove(move);
      return;
    }
  }

  // Helper function to execute the move and check game state
  void _makeMove(int move) {
    setState(() {
      _board[move] = "O";

      if (_checkWinner("O")) {
        _showDialog("Computer Wins! 🤖");
        _gameOver = true;
      } else if (!_board.contains("")) {
        _showDialog("It's a Draw 🤝");
        _gameOver = true;
      } else {
        _currentPlayer = "X"; // Back to player
      }
    });
  }

  // --- Game State Check and UI ---

  bool _checkWinner(String player) {
    for (var combo in _winningCombinations) {
      if (_board[combo[0]] == player &&
          _board[combo[1]] == player &&
          _board[combo[2]] == player) {
        return true;
      }
    }
    return false;
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, "");
      _currentPlayer = "X"; // Always player first
      _gameOver = false;
    });
  }

  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () => _handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 2),
        ),
        child: Center(
          child: Text(
            _board[index],
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              // X (Player) is Red, O (Computer) is Blue
              color: _board[index] == "X" ? Colors.red : Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tic Tac Toe AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            _gameOver
                ? "Game Over"
                : "Your Turn (X)",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _gameOver ? Colors.red : Colors.purple,
            ),
          ),
          const SizedBox(height: 20),

          // Game Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 9,
              itemBuilder: (context, index) => _buildGridItem(index),
            ),
          ),

          // Reset Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: _resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Reset Game",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
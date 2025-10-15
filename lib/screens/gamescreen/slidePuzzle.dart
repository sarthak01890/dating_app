import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SliderPuzzleGame extends StatefulWidget {
  const SliderPuzzleGame({super.key});

  @override
  State<SliderPuzzleGame> createState() => _SliderPuzzleGameState();
}

class _SliderPuzzleGameState extends State<SliderPuzzleGame> {
  List<int> _board = [];
  int _gridSize = 3;
  int _moves = 0;
  bool _isSolved = false;

  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 🔢 Count inversions
  int _getInversions() {
    int inversions = 0;
    List<int> tiles = _board.where((val) => val != 0).toList();

    for (int i = 0; i < tiles.length; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] > tiles[j]) inversions++;
      }
    }
    return inversions;
  }

  // 🧮 Check solvability
  bool _isSolvable() {
    int inversions = _getInversions();
    int n = _gridSize;

    if (n.isOdd) return inversions.isEven;

    int zeroIndex = _board.indexOf(0);
    int rowFromBottom = n - (zeroIndex ~/ n);
    return rowFromBottom.isOdd ? inversions.isOdd : inversions.isEven;
  }

  // 🎲 Shuffle board
  void _shuffleBoard() {
    List<int> solvedBoard = List.generate(_gridSize * _gridSize, (i) => i + 1);
    solvedBoard[solvedBoard.length - 1] = 0;

    List<int> shuffled;
    do {
      shuffled = List.of(solvedBoard)..shuffle(Random());
      _board = shuffled;
    } while (!_isSolvable());

    setState(() {
      _board = shuffled;
      _moves = 0;
      _isSolved = false;
      _secondsElapsed = 0;
      _isStarted = false;
    });
    _stopTimer();
  }

  void _resetGame() => _shuffleBoard();

  // ⏱ Timer controls
  void _startTimer() {
    if (_isStarted) return;
    _isStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isSolved) {
        setState(() => _secondsElapsed++);
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isStarted = false;
  }

  // 🎮 Handle tile tap
  void _handleTap(int index) {
    if (_isSolved) return;

    int zeroIndex = _board.indexOf(0);
    int zeroRow = zeroIndex ~/ _gridSize;
    int zeroCol = zeroIndex % _gridSize;
    int tapRow = index ~/ _gridSize;
    int tapCol = index % _gridSize;

    bool isAdjacent = (zeroRow == tapRow && (zeroCol - tapCol).abs() == 1) ||
        (zeroCol == tapCol && (zeroRow - tapRow).abs() == 1);

    if (isAdjacent) {
      if (!_isStarted) _startTimer();

      setState(() {
        int temp = _board[index];
        _board[index] = 0;
        _board[zeroIndex] = temp;
        _moves++;

        if (_checkWin()) {
          _isSolved = true;
          _stopTimer();
          _showWinDialog();
        }
      });
    }
  }

  bool _checkWin() {
    for (int i = 0; i < _board.length - 1; i++) {
      if (_board[i] != i + 1) return false;
    }
    return _board.last == 0;
  }

  // 🏆 Show Win Dialog
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white,
          title: const Text(
            '🎉 Puzzle Solved! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('शानदार! आपने पज़ल हल कर ली।', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 15),
              _buildStatRow(Icons.swap_vert, 'Total Moves', _moves.toString()),
              _buildStatRow(Icons.timer, 'Time Taken', _formatTime(_secondsElapsed)),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('New Game', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  // 🧾 Helper widgets
  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, color: Colors.indigoAccent, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ]),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _buildTile(int number, int index) {
    if (number == 0) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isSolved ? Colors.green.shade400 : Colors.indigo.shade400,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _gridSize,
              decoration: InputDecoration(
                labelText: 'Grid Size',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 3, child: Text("3x3 (Easy)")),
                DropdownMenuItem(value: 4, child: Text("4x4 (Hard)")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _gridSize = val;
                    _shuffleBoard();
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 15),
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Reset', style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int boardLength = _gridSize * _gridSize;

    if (_board.length != boardLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _shuffleBoard());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रोफेशनल स्लाइडर पज़ल', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatDisplay(Icons.swap_vert, 'चालें (Moves)', _moves.toString(), Colors.blueAccent),
                _buildStatDisplay(Icons.timer, 'समय (Time)', _formatTime(_secondsElapsed), Colors.orangeAccent),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: min(MediaQuery.of(context).size.width * 0.9, 450),
                  maxHeight: min(MediaQuery.of(context).size.width * 0.9, 450),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: boardLength,
                    itemBuilder: (context, index) => _buildTile(_board[index], index),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatDisplay(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.indigo.shade700),
        ),
      ],
    );
  }
}

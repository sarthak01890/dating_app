import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dating_app/screens/gamescreen/ConfettiOverlay.dart'; // ✅ Correct import

// --- 💡 Game Configuration ---
const List<int> _levelPairs = [
  3, 4, 6, 8, 10, 12, 15, 18, 21, 25,
];

const List<String> _emojis = [
  '🚀', '💡', '🔥', '🎉', '🌟', '💖', '💰', '👑', '🔑', '🌍',
  '🍏', '🍊', '🍓', '🍒', '🍇', '🍉', '🍍', '🥭', '🥝', '🥥',
  '⚽', '🏀', '🏈', '⚾', '🎾',
];

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  int _currentLevel = 1;
  List<String> _gameCards = [];
  List<bool> _isFlipped = [];
  List<bool> _isMatched = [];
  List<int> _flippedIndices = [];
  int _score = 0;
  bool _isProcessing = false;
  bool _showConfetti = false;
  int _targetPairs = 0;

  @override
  void initState() {
    super.initState();
    _setupLevel(_currentLevel);
  }

  // --- Game Logic ---
  void _setupLevel(int level) {
    if (level > _levelPairs.length) {
      _showFinalWinDialog();
      return;
    }

    _targetPairs = _levelPairs[level - 1];
    int totalCards = _targetPairs * 2;

    final random = Random();
    List<String> tempEmojis = List.from(_emojis);
    tempEmojis.shuffle(random);
    List<String> selectedEmojis = tempEmojis.sublist(0, _targetPairs);

    _gameCards = [...selectedEmojis, ...selectedEmojis];
    _gameCards.shuffle(random);

    _isFlipped = List.filled(totalCards, false);
    _isMatched = List.filled(totalCards, false);
    _flippedIndices = [];
    _score = 0;
    _isProcessing = false;
    _showConfetti = false;

    // Show all cards briefly at start
    _previewCards(totalCards);
  }

  void _previewCards(int totalCards) {
    setState(() => _isFlipped = List.filled(totalCards, true));
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isFlipped = List.filled(totalCards, false));
      }
    });
  }

  void _handleCardTap(int index) {
    if (_isProcessing || _isFlipped[index] || _isMatched[index]) return;

    setState(() {
      _isFlipped[index] = true;
      _flippedIndices.add(index);
    });

    if (_flippedIndices.length == 2) {
      _isProcessing = true;
      _checkMatch();
    }
  }

  void _checkMatch() {
    int firstIndex = _flippedIndices[0];
    int secondIndex = _flippedIndices[1];
    String firstCard = _gameCards[firstIndex];
    String secondCard = _gameCards[secondIndex];

    if (firstCard == secondCard) {
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _isMatched[firstIndex] = true;
            _isMatched[secondIndex] = true;
            _score++;
            _isProcessing = false;
          });
          _checkLevelComplete();
        }
      });
    } else {
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isFlipped[firstIndex] = false;
            _isFlipped[secondIndex] = false;
            _isProcessing = false;
          });
        }
      });
    }
    _flippedIndices = [];
  }

  void _checkLevelComplete() {
    if (_score == _targetPairs) {
      setState(() => _showConfetti = true);
      Future.delayed(const Duration(seconds: 2), _showLevelCompleteDialog);
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Level Complete! 🎉', textAlign: TextAlign.center),
          content: Text(
            'You matched all $_targetPairs pairs on Level $_currentLevel!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentLevel++;
                  _setupLevel(_currentLevel);
                });
              },
              child: Text(
                _currentLevel < 10
                    ? 'Next Level (${_currentLevel + 1})'
                    : 'Finish',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFinalWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🏆 Congratulations!', textAlign: TextAlign.center),
          content: const Text(
            'You have mastered all 10 levels of the Memory Match Game!',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentLevel = 1;
                  _setupLevel(_currentLevel);
                });
              },
              child: const Text('Play Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- UI Builder ---
  Widget _buildCard(int index) {
    bool isVisible = _isFlipped[index] || _isMatched[index];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final rotate = Tween(begin: 0.0, end: 1.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final angle = rotate.value * pi;
            return Transform(
              transform: Matrix4.rotationY(angle),
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      child: Container(
        key: ValueKey<bool>(isVisible),
        decoration: BoxDecoration(
          gradient: isVisible
              ? const LinearGradient(
            colors: [Colors.white, Colors.white70],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
          ],
        ),
        child: Center(
          child: Text(
            isVisible ? _gameCards[index] : '❓',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isVisible ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalCards = _targetPairs * 2;
    int crossAxisCount = sqrt(totalCards).ceil();

    return ConfettiOverlay(
      showConfetti: _showConfetti,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Level $_currentLevel / 10',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _setupLevel(_currentLevel),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text('Pairs Matched', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        Text(
                          '$_score / $_targetPairs',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: totalCards,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _handleCardTap(index),
                      child: _buildCard(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

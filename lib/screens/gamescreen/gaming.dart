import 'package:dating_app/screens/gamescreen/MemoryMatch.dart';
import 'package:dating_app/screens/gamescreen/slidePuzzle.dart';
import 'package:dating_app/screens/gamescreen/whoisthespy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dating_app/screens/down_button.dart';
import 'package:dating_app/screens/gamescreen/tictactoeapp.dart';


class GamingPage extends StatefulWidget {
  const GamingPage({Key? key}) : super(key: key);

  @override
  State<GamingPage> createState() => _GamingPageState();
}

class _GamingPageState extends State<GamingPage> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> games = [
    {'name': 'Tic-Tac-Toe', 'icon': Icons.close, 'color': Colors.redAccent.shade700},
    {'name': 'Memory Match', 'icon': Icons.memory, 'color': Colors.blueAccent.shade700},
    {'name': 'Puzzle Slider', 'icon': Icons.extension, 'color': Colors.orange.shade700},
    {'name': 'Flappy Bird Clone', 'icon': Icons.flight_takeoff, 'color': Colors.green.shade700},
    {'name': 'Who is the Spy', 'icon': Icons.visibility, 'color': Colors.deepPurple.shade700}, // ✅ New Game Added
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void _openGame(String gameName) {
    HapticFeedback.mediumImpact();

    if (gameName == "Tic-Tac-Toe") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TicTacToeGame()),
      );
    } else if (gameName == "Memory Match") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MemoryGameScreen()),
      );
    } else if (gameName == "Puzzle Slider") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SliderPuzzleGame()),
      );
    } else if (gameName == "Who is the Spy") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StartGameScreen()), // ✅ Linked to Spy Game
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$gameName coming soon!"),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            "Gaming Hub",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: games.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final game = games[index];
            return _buildGameCard(game);
          },
        ),
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openGame(game['name']),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: game['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  game['icon'],
                  size: 40,
                  color: game['color'],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  game['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 30,
                height: 3,
                decoration: BoxDecoration(
                  color: game['color'],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../widgets/top_tabs.dart';
import '../../widgets/filter_chip.dart';
import '../swipe_screen.dart';
import '../../models/user_model.dart';

// 💜 Global color
const Color primaryPurple = Color(0xFF8A2BE2);

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  int _selectedTab = 0;
  String? _selectedLanguage;
  final List<String> _fixedFilters = [
    "All",
    "Online",
    "New Users",
    "Verified",
  ];
  String _selectedFilter = "All";

  // 💖 Fake Demo Users
  late final List<UserModel> _demoUsers;

  @override
  void initState() {
    super.initState();
    _demoUsers = _generateDemoUsers();
  }

  // --- Generate Dummy Users ---
  List<UserModel> _generateDemoUsers() {
    return List<UserModel>.generate(
      10,
          (index) => UserModel(
        id: 'demo_$index',
        username: 'DemoUser$index',

        imageUrl: 'https://i.pravatar.cc/150?img=${index + 1}',

      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final List<String> languages = [
      "English",
      "Hindi",
      "Tamil",
      "Telugu",
      "Bengali",
      "Marathi",
      "Gujarati",
      "Punjabi",
      "Kannada",
      "Malayalam",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter by Language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 8.0,
                  children: languages.map((lang) {
                    return ChoiceChip(
                      label: Text(lang),
                      selected: _selectedLanguage == lang,
                      selectedColor: primaryPurple.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _selectedLanguage == lang
                            ? primaryPurple
                            : Colors.black87,
                      ),
                      checkmarkColor: primaryPurple,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedLanguage = selected ? lang : null;
                        });
                        setState(() {
                          _selectedFilter = "Language";
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Done",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: TopSearchBar(),
      ),
      body: Column(
        children: [
          // 🌟 Language & Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const SizedBox(width: 12),
                ..._fixedFilters.map((filterText) {
                  final isSelected = filterText == _selectedFilter;
                  return FilterChipWidget(
                    text: filterText,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedFilter = filterText;
                        _selectedLanguage = null;
                      });
                    },
                  );
                }).toList(),
                const SizedBox(width: 12),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // 🃏 Swipe Screen Area
          Expanded(child: SwipeScreen(users: _demoUsers)),
        ],
      ),
    );
  }
}

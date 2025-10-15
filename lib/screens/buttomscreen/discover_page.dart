import 'package:dating_app/screens/buttomscreen/search.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your custom files
import '../../widgets/top_tabs.dart'; // मान लीजिए यह TopSearchBar को होस्ट करता है
import '../../widgets/filter_chip.dart';
import '../swipe_screen.dart';
import '../message.dart';
import '../buttomscreen/likepage.dart';
import '../../models/user_model.dart';

// --- Global Color Definitions ---
const Color primaryPurple = Color(0xFF8A2BE2); // Discover Page के लिए उपयोग किया गया

class DiscoverPage extends StatefulWidget {
  final bool isDemoUser;
  const DiscoverPage({Key? key,required this.isDemoUser}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
 
  String? _selectedLanguage;
  final List<String> _fixedFilters = [
    "All",
    "Online",
    "New Users",
    "Verified",
  ];
  String _selectedFilter = "All";

  // 🔑 Supabase and Data Variables
  late Future<List<UserModel>> _profilesFuture;
  late Stream<List<Map<String, dynamic>>> _newLikesStream;
  final supabase = Supabase.instance.client;

  // 💖 Variable to hold the count of new/unseen likes
  int _newLikesCount = 0;

  @override
  void initState() {
    super.initState();
    _profilesFuture = _fetchProfiles();
    _newLikesStream = _fetchNewLikesStream(); // Initialize the likes stream
  }

  // --- Data Fetching Functions ---

  Future<List<UserModel>> _fetchProfiles() async {
    final currentUserId = widget.isDemoUser
      ? '95ea97ca-2949-401c-9b09-eef5c3c219b3'
      : supabase.auth.currentUser?.id;

  if (currentUserId == null) {
    // Handle the case when there is no logged-in user
    return [];
  }
    final response =
    await supabase.from('users').select().neq('id', currentUserId);

    if (response == null) return [];

    return List<Map<String, dynamic>>.from(response)
        .map((map) => UserModel.fromJson(map))
        .toList();
  }

  // 🚀 Real-time Likes Stream (Fetches ALL likes for the user)
  Stream<List<Map<String, dynamic>>> _fetchNewLikesStream() {
    // final currentUserId = supabase.auth.currentUser!.id;
       final currentUserId = widget.isDemoUser
      ? '95ea97ca-2949-401c-9b09-eef5c3c219b3'
      : supabase.auth.currentUser?.id;

  if (currentUserId == null) {
    // Handle the case when there is no logged-in user
    return Stream.value([]);
  }

    return supabase
        .from('likes')
        .stream(primaryKey: ['id'])
        .eq('target_id', currentUserId)
        .order('created_at', ascending: false)
        .execute();
  }

  // --- UI Functions ---

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
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        onSelected: (bool selected) {
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
          },
        );
      },
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // ✅ SearchUsersPage पर नेविगेट करने के लिए onTap जोड़ा गया
        title: TopSearchBar(
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 💜 Heart icon with Real-time Notification Badge
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _newLikesStream,
                  builder: (context, snapshot) {
                    final allLikes = snapshot.data ?? [];
                    _newLikesCount = allLikes
                        .where((like) => like['is_new'] == true)
                        .length;

                    return GestureDetector(
                      onTap: () {
                        // Navigate to LikesPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  LikesPage(isDemoUser:widget.isDemoUser)),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.favorite_border,
                              color: primaryPurple, size: 24),

                          // 🔴 Notification Badge
                          if (_newLikesCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    _newLikesCount > 9
                                        ? '9+'
                                        : '$_newLikesCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(width: 10),

                // 💬 Message icon → opens MessageScreen
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                         MessageScreen(otherUserid: "username",isDemoUser:widget.isDemoUser),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade100,
                    child:
                    const Icon(Icons.message_rounded, color: primaryPurple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🌟 Language & Filter Bar
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 0.03, 0.97, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  if (_selectedLanguage != null)
                    FilterChipWidget(
                      text: _selectedLanguage!,
                      isSelected: true,
                      onTap: () => _showLanguageSelector(context),
                    ),
                  ..._fixedFilters.map((filterText) {
                    if (filterText == "All" && _selectedLanguage != null) {
                      return const SizedBox.shrink();
                    }
                    final isSelected = (_selectedLanguage == null &&
                        filterText == _selectedFilter) ||
                        (_selectedFilter == filterText &&
                            _selectedLanguage == null);
                    return FilterChipWidget(
                      text: filterText,
                      isSelected: isSelected,
                      onTap: () {
                        if (filterText == "All") {
                          _showLanguageSelector(context);
                        } else {
                          setState(() {
                            _selectedFilter = filterText;
                            _selectedLanguage = null;
                          });
                        }
                      },
                    );
                  }).toList(),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // 🃏 Swipe Screen Area
          FutureBuilder<List<UserModel>>(
            future: _profilesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Expanded(
                    child: Center(
                        child:
                        CircularProgressIndicator(color: primaryPurple)));
              }
              if (snapshot.hasError) {
                return Expanded(
                    child: Center(
                        child: Text(
                            "Error loading profiles: ${snapshot.error}")));
              }
              final users = snapshot.data ?? [];
              if (users.isEmpty) {
                return const Expanded(
                    child: Center(
                        child: Text("No users found based on filters.")));
              }
              return Expanded(child: SwipeScreen(users: users));
            },
          ),
        ],
      ),
    );
  }
}
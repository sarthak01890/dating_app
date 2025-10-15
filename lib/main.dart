import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/SplashScreen.dart';

// --- THEME CONSTANTS ---
// These are necessary for defining both light and dark modes consistently.
const Color kPrimaryPurple = Color(0xFF9C27B0); // Deep Purple
const Color kDarkSurface = Color(0xFF121212); // Deep dark background for Scaffold
const Color kCardColorDark = Color(0xFF1E1E1E); // Card/Container color in dark mode

// --- THEME DEFINITIONS ---

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kPrimaryPurple,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
    iconTheme: IconThemeData(color: kPrimaryPurple),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimaryPurple,
  ),
  useMaterial3: true,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryPurple,
  scaffoldBackgroundColor: kDarkSurface,
  cardColor: kCardColorDark,
  colorScheme: const ColorScheme.dark(
    primary: kPrimaryPurple,
    secondary: kPrimaryPurple,
    surface: kDarkSurface,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkSurface,
    foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: kPrimaryPurple),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimaryPurple,
  ),
  // Ensuring TextFields look good in dark mode
  inputDecorationTheme: InputDecorationTheme(
    fillColor: kCardColorDark,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  useMaterial3: true,
);


// Global notifier for theme
ValueNotifier<bool> isDarkMode = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kfxfxmqurocdtorisgul.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtmeGZ4bXF1cm9jZHRvcmlzZ3VsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyNDM3NjIsImV4cCI6MjA3MTgxOTc2Mn0.zxHUTz-UgjSmX7l0EYkoiieI4w2svxJj1KblJQCrwfU',
  );

  runApp(const DatingApp());
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, darkModeEnabled, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Dating App",

          // --- FIXED THEME SETUP ---
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
          // -------------------------

          home: const SplashScreen(),
        );
      },
    );
  }
}

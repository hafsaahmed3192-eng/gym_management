import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gym_management/screens/article_screen.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //////////////////////////////////////////////////////
  /// LOAD SAVED THEME BEFORE RUNNING APP
  //////////////////////////////////////////////////////
  final isDark =
  await ThemeProvider.loadThemeFromPrefs();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDark),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      //////////////////////////////////////////////////////
      /// LIGHT THEME
      //////////////////////////////////////////////////////
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,

        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFD700), // Gold
          surface: Color(0xFFF2F2F2),
          onSurface: Colors.black,
        ),

        cardColor: const Color(0xFFF2F2F2),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        iconTheme: const IconThemeData(
          color: Color(0xFFFFD700),
        ),

        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ),

      //////////////////////////////////////////////////////
      /// DARK THEME
      //////////////////////////////////////////////////////
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
        const Color(0xFF0D0F14),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700), // Gold
          surface: Color(0xFF1C1F26),
          onSurface: Colors.white,
        ),

        cardColor: const Color(0xFF1C1F26),

        appBarTheme: const AppBarTheme(
          backgroundColor:
          Color(0xFF0D0F14),
          elevation: 0,
        ),

        iconTheme: const IconThemeData(
          color: Color(0xFFFFD700),
        ),

        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
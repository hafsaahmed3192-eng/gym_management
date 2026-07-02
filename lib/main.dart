import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:gym_management/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //////////////////////////////////////////////////////
  /// LOAD SAVED THEME BEFORE RUNNING APP
  //////////////////////////////////////////////////////
  final isDark = await ThemeProvider.loadThemeFromPrefs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDark)),
        ChangeNotifierProvider(create: (_) => UserProvider()..fetchUserData()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Gold by default until userData loads, then switches to the
    // gender-based accent (rose-gold for female, gold for male/other).
    final accentColor = userProvider.genderTheme.accentColor;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      //////////////////////////////////////////////////////
      /// LIGHT THEME
      //////////////////////////////////////////////////////
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,

        colorScheme: ColorScheme.light(
          primary: accentColor,
          surface: const Color(0xFFF2F2F2),
          onSurface: Colors.black,
        ),

        cardColor: const Color(0xFFF2F2F2),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        iconTheme: IconThemeData(
          color: accentColor,
        ),

        textTheme: TextTheme(
          headlineMedium: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: const TextStyle(
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
        scaffoldBackgroundColor: const Color(0xFF0D0F14),

        colorScheme: ColorScheme.dark(
          primary: accentColor,
          surface: const Color(0xFF1C1F26),
          onSurface: Colors.white,
        ),

        cardColor: const Color(0xFF1C1F26),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0F14),
          elevation: 0,
        ),

        iconTheme: IconThemeData(
          color: accentColor,
        ),

        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/playlist_input_screen.dart';
import 'screens/media_browser_screen.dart';
import 'screens/player_screen.dart';
import 'screens/pro_upgrade_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StreamiaApp());
}

class StreamiaApp extends StatelessWidget {
  const StreamiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamia Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        primaryColor: const Color(0xFFE50914),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1A1D29),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1D29),
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/playlist_input': (context) => const PlaylistInputScreen(),
        '/media_browser': (context) => const MediaBrowserScreen(),
        '/player': (context) => const PlayerScreen(),
        '/pro_upgrade': (context) => const ProUpgradeScreen(),
      },
    );
  }
}

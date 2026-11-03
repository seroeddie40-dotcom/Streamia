import 'package:flutter/material.dart';
import '../services/playlist_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login({bool asGuest = false}) {
    if (!asGuest && _userController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Benutzernamen eingeben oder Gastzugang wählen.')),
      );
      return;
    }
    if (PlaylistService().playlists.isEmpty) {
      PlaylistService().loadDemoPlaylist();
    }
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_logo.jpg',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.live_tv,
                      size: 80,
                      color: Color(0xFFE50914),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Willkommen bei Streamia',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Melde dich an oder starte direkt im Gastmodus',
                  style: TextStyle(color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: 'Benutzername / E-Mail',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: const Color(0xFF1A1D29),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: const Color(0xFF1A1D29),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _login(asGuest: false),
                    child: const Text('Anmelden', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _login(asGuest: true),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Ohne Konto als Gast starten'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

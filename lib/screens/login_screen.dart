import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../services/playlist_parser_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  String _loginType = 'qr'; // 'qr', 'xtream', 'm3u'
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _saveAndEnter() async {
    final name = _nameController.text.trim();
    if (name.isEmpty && _loginType != 'qr') {
      setState(() => _errorMessage = 'Bitte einen Namen für die Playlist eingeben');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_loginType == 'xtream') {
        final url = _urlController.text.trim();
        final user = _userController.text.trim();
        final pass = _passController.text.trim();

        // Echten Test-Abruf über den PlaylistParserService starten
        final result = await PlaylistParserService.fetchXtreamData(
          serverUrl: url,
          username: user,
          password: pass,
        );

        if (!result['success']) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Verbindung fehlgeschlagen: ${result['error']}';
          });
          return;
        }

        // Daten erfolgreich validiert, als Xtream-String speichern
        final data = '$url|$user|$pass';
        await PlaylistService.savePlaylist(type: 'xtream', data: data, name: name.isEmpty ? 'Xtream Playlist' : name);

      } else if (_loginType == 'm3u') {
        final m3uUrlOrPath = _urlController.text.trim();
        if (m3uUrlOrPath.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Bitte M3U Link oder Pfad eingeben';
          });
          return;
        }
        await PlaylistService.savePlaylist(type: 'm3u', data: m3uUrlOrPath, name: name.isEmpty ? 'M3U Playlist' : name);

      } else {
        // QR-Code Pairing Session
        final qrData = 'qr_paired_session_${DateTime.now().millisecondsSinceEpoch}';
        await PlaylistService.savePlaylist(type: 'qr', data: qrData, name: 'QR Pairing Gerät');
      }

      // Erfolgreich zum Dashboard wechseln
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Streamia Player – Anmeldung',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Freemium-Modus: 1 Playlist aktiv speicherbar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              // Auswahl der Login-Methode (Tabs)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabButton('QR-Code Pairing', 'qr'),
                  const SizedBox(width: 10),
                  _buildTabButton('Xtream Codes', 'xtream'),
                  const SizedBox(width: 10),
                  _buildTabButton('M3U / USB', 'm3u'),
                ],
              ),
              const SizedBox(height: 24),

              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                ),

              // Inhalt je nach gewählter Methode
              if (_loginType == 'qr') ...[
                const Icon(Icons.qr_code_2, size: 100, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Scannen Sie den QR-Code mit Ihrem Smartphone,\num die Playlist unkompliziert zu koppeln.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ] else ...[
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Playlist Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _loginType == 'xtream' ? 'Server URL (z.B. http://line.tv:8080)' : 'M3U Link oder Dateipfad',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                  ),
                ),
                if (_loginType == 'xtream') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _userController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Benutzername',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Passwort',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _saveAndEnter,
                      child: const Text('Verbinden & Starten', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, String type) {
    bool isSelected = _loginType == type;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blueAccent : Colors.transparent,
          side: const BorderSide(color: Colors.blueAccent),
        ),
        onPressed: () => setState(() => _loginType = type),
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ),
    );
  }
}

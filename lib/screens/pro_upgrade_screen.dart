import 'package:flutter/material.dart';
import '../services/pro_guard_service.dart';

class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  final _proService = ProGuardService();

  @override
  Widget build(BuildContext context) {
    final isPro = _proService.isProUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Streamia PRO')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              isPro ? 'Du nutzt bereits Streamia PRO!' : 'Hol dir Streamia PRO',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.greenAccent),
              title: Text('Live-Streams direkt aufnehmen & herunterladen'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.greenAccent),
              title: Text('Unbegrenzt viele M3U-Playlists verwalten'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.greenAccent),
              title: Text('Werbefreies Streaming in voller Auflösung'),
            ),
            const Spacer(),
            if (!isPro)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  setState(() {
                    _proService.unlockPro();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Streamia PRO wurde erfolgreich aktiviert!')),
                  );
                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Jetzt kostenlos freischalten (Test-Modus)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            else
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _proService.resetPro();
                  });
                },
                child: const Text('Auf Basis-Version zurücksetzen'),
              ),
          ],
        ),
      ),
    );
  }
}

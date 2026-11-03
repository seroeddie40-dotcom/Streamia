import 'package:flutter/material.dart';
import '../screens/pro_upgrade_screen.dart';

class ProGuardService {
  static bool _isProActive = false; 

  static void setProStatus(bool status) {
    _isProActive = status;
  }

  static bool isPro() {
    return _isProActive;
  }

  static void checkFeatureAccess({
    required BuildContext context,
    required String featureName,
    required VoidCallback onAccessGranted,
  }) {
    if (_isProActive) {
      onAccessGranted();
    } else {
      _showUpgradeDialog(context, featureName);
    }
  }

  static void _showUpgradeDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: const [
            Icon(Icons.lock, color: Colors.amber),
            SizedBox(width: 8),
            Text('Pro-Feature', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Das Feature "$featureName" ist in deinem aktuellen Tarif nicht enthalten.\n\n'
          'Sichere dir jetzt das Pro-Paket (1, 3 oder 5 Geräte) und schalte '
          'Downloads, Sprachsuche mit Dialekten und die Verlauf-Sidebar frei!',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(context);
              // Leitet direkt zum Pro-Upgrade-Bildschirm mit QR-Code Checkout weiter
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProUpgradeScreen()),
              );
            },
            child: const Text('Pro-Paket wählen', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

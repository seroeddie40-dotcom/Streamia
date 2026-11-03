import 'package:flutter/material.dart';
import '../services/pro_guard_service.dart';

class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({Key? key}) : super(key: key);

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  int _selectedDeviceCount = 3; // Standard: 3 Geräte Paket
  String _selectedPaymentMethod = 'paypal'; // 'google_play', 'credit_card', 'paypal'
  bool _showQRCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Streamia Player – Pro Upgrade & Checkout'),
      ),
      body: Center(
        child: Container(
          width: 750,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.4)),
          ),
          child: _showQRCode ? _buildQRCodeCheckoutView() : _buildSelectionView(),
        ),
      ),
    );
  }

  // Ansicht 1: Paket- und Zahlungsauswahl
  Widget _buildSelectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Wähle dein Pro-Paket',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kein tippen am TV nötig – Bezahlen ganz einfach per Handy-QR-Code',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Geräte-Auswahl (1, 3, 5 Geräte)
        const Text('1. Anzahl der Endgeräte:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDeviceCard(1, '1 Gerät', 'Einzelnutzer'),
            _buildDeviceCard(3, '3 Geräte', 'Familien-Paket'),
            _buildDeviceCard(5, '5 Geräte', 'Multi-Room (Max)'),
          ],
        ),
        const SizedBox(height: 24),

        // Zahlungsmethode
        const Text('2. Bevorzugte Zahlungsmethode:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPaymentButton('Google Play', 'google_play', Icons.shop),
            _buildPaymentButton('Kreditkarte', 'credit_card', Icons.credit_card),
            _buildPaymentButton('PayPal', 'paypal', Icons.payment),
          ],
        ),
        const SizedBox(height: 32),

        // Weiter zum QR-Code
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            setState(() {
              _showQRCode = true; // Zeigt den QR-Code für das Handy an
            });
          },
          child: Text(
            'QR-Code für $_selectedDeviceCount Gerät(e) anzeigen',
            style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Ansicht 2: QR-Code fürs Handy (verhindert TV-Tippstress)
  Widget _buildQRCodeCheckoutView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Mit dem Handy scannen & bezahlen',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Paket: $_selectedDeviceCount Gerät(e) | Methode: ${_selectedPaymentMethod.toUpperCase()}',
          style: const TextStyle(color: Colors.amber, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Platzhalter für den echten QR-Code (wird vom Smartphone gescannt)
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.qr_code_2, size: 160, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Öffne die Kamera deines Smartphones und scanne diesen Code.\n'
          'Die App schaltet sich automatisch frei, sobald die Zahlung erfolgreich ist.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
              onPressed: () => setState(() => _showQRCode = false),
              child: const Text('Zurück', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              onPressed: () {
                // Simuliert erfolgreiche Zahlung via Handy
                ProGuardService.setProStatus(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Zahlung erfolgreich bestätigt! Pro-Features sind aktiv.')),
                );
                Navigator.pop(context); // Schließt den Upgrade-Screen
              },
              child: const Text('Simuliere erfolgreiche Handy-Zahlung', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceCard(int count, String title, String subtitle) {
    bool isSelected = _selectedDeviceCount == count;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDeviceCount = count),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent.withOpacity(0.2) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade800, width: 2),
          ),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentButton(String title, String method, IconData icon) {
    bool isSelected = _selectedPaymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = method),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.withOpacity(0.2) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.greenAccent : Colors.grey.shade800, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.greenAccent : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

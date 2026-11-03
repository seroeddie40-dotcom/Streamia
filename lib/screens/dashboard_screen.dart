import 'package:flutter/material.dart';
import '../services/pro_guard_service.dart';
import 'pro_upgrade_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Aktivierter Menüpunkt (Live TV, Filme, Serien, Favoriten, Einstellungen)
  int _selectedCategoryIndex = 0;

  final List> _categories = [
    {'title': 'Live TV', 'icon': Icons.live_tv, 'count': '1,240 Sender'},
    {'title': 'Filme (VOD)', 'icon': Icons.movie, 'count': '3,500 Titel'},
    {'title': 'Serien', 'icon': Icons.tv, 'count': '420 Staffeln'},
    {'title': 'Favoriten', 'icon': Icons.star, 'count': '12 Sender'},
    {'title': 'Einstellungen', 'icon': Icons.settings, 'count': 'Setup & Konto'},
  ];

  @override
  Widget build(BuildContext context) {
    bool isPro = ProGuardService.isPro();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Edles Dunkelblau/Schwarz
      body: Row(
        children: [
          // 1. LINKE NAVIGATION (Hauptkategorien)
          Container(
            width: 260,
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo / Titel
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.blueAccent, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Streamia',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Kategorien-Liste
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedCategoryIndex == index;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent.withOpacity(0.3) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? Colors.blueAccent : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            _categories[index]['icon'],
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          title: Text(
                            _categories[index]['title'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade400,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            _categories[index]['count'],
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Pro-Status Anzeige unten in der Sidebar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProUpgradeScreen()),
                    ).then((_) => setState(() {})); // Aktualisiert den Status nach Rückkehr
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isPro ? Colors.amber.withOpacity(0.2) : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isPro ? Colors.amber : Colors.grey.shade800),
                    ),
                    child: Row(
                      children: [
                        Icon(isPro ? Icons.star : Icons.lock, color: isPro ? Colors.amber : Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPro ? 'Pro-Paket aktiv' : 'Kostenlos (Free)',
                                style: TextStyle(color: isPro ? Colors.amber : Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isPro ? 'Multi-Device & Features' : 'Jetzt upgraden',
                                style: const TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. HAUPTBEREICH (Mitte: Medien-Kacheln)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Oben: Begrüßung & Schnellsuche
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Willkommen zurück, ${_categories[_selectedCategoryIndex]['title']}',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Wähle einen Inhalt oder starte die Sprachsuche',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      // Sprachsuche Button (Gezügelt durch ProGuard)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          ProGuardService.checkFeatureAccess(
                            context: context,
                            featureName: 'Sprachsuche mit Dialekt-Erkennung',
                            onAccessGranted: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sprachsuche gestartet (8 Sprachen aktiv)...')),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.mic, color: Colors.blueAccent),
                        label: const Text('Sprachsuche', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Raster mit Inhalten (Kacheln im TV-Smarters Stil)
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Stream Kanal #${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              // Download / Aufnahme Button (Pro-Feature Test)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.download, color: Colors.grey, size: 20),
                                  onPressed: () {
                                    ProGuardService.checkFeatureAccess(
                                      context: context,
                                      featureName: 'USB & Offline Downloads',
                                      onAccessGranted: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Download auf USB gestartet...')),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. RECHTE TRANSPARENTE SIDEBAR ("Zuletzt geschaut" / Verlauf)
          Container(
            width: 280,
            color: const Color(0xFF1E293B).withOpacity(0.7), // Transparent-Effekt
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Zuletzt geschaut',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (!isPro)
                      const Icon(Icons.lock, color: Colors.amber, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Live-TV, Filme & Serien Verlauf',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 20),

                // Verlauf-Einträge (Gesperrt oder aktiv)
                Expanded(
                  child: isPro
                      ? ListView.builder(
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.history, color: Colors.blueAccent, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Sendung #${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        const Text('Vor 15 Minuten', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline, color: Colors.amber, size: 40),
                              const SizedBox(height: 12),
                              const Text(
                                'Verlauf-Sidebar\nist ein Pro-Feature',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Schalte die rechte Sidebar durch ein Upgrade frei.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProUpgradeScreen()),
                                  ).then((_) => setState(() {}));
                                },
                                child: const Text('Jetzt freischalten', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

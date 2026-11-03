import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;
  final bool isSeries;

  const PlayerScreen({
    Key? key,
    required this.streamUrl,
    required this.title,
    this.isSeries = false,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showControls = true;
  bool _showSidebar = false; // Transparente Sidebar für Serien (Staffel/Episoden)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // D-Pad Steuerung für TV-Fernbedienung
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.mediaPlay) {
              setState(() {
                _showControls = !_showControls;
              });
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft && widget.isSeries) {
              setState(() {
                _showSidebar = !_showSidebar; // Sidebar per Pfeiltaste ein-/ausblenden
              });
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // 1. Eigentlicher Videobereich (Platzhalter für den Stream)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_filled, size: 80, color: Colors.white54),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const Text(
                    '(Stream-Wiedergabe aktiv)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // 2. Transparente Sidebar für Serien (Staffel- & Episoden-Auswahl)
            if (widget.isSeries && _showSidebar)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 320,
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Staffeln & Episoden',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white30),
                      // Beispiel für Staffel-Auswahl
                      DropdownButton<String>(
                        dropdownColor: Colors.grey[900],
                        value: 'Staffel 1',
                        style: const TextStyle(color: Colors.white),
                        items: ['Staffel 1', 'Staffel 2'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).onChanged,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 10),
                      // Episoden-Liste
                      Expanded(
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Episode ${index + 1}', style: const TextStyle(color: Colors.white)),
                              subtitle: const Text('Titel der Folge', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              onTap: () {
                                // Logik zum Umschalten der Episode
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. OSD Overlay-Steuerung (Play/Pause, Zurück zum Anfang, etc.)
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Zum Anfang der Folge springen
                      IconButton(
                        color: Colors.white,
                        iconSize: 32,
                        icon: const Icon(Icons.skip_previous),
                        onPressed: () {
                          // Logik: Spult an den Anfang zurück (0:00)
                        },
                        tooltip: 'Zum Anfang zurück',
                      ),
                      // Play / Pause
                      IconButton(
                        color: Colors.white,
                        iconSize: 48,
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {},
                      ),
                      // Bei Serien: Sidebar direkt per Button öffnen
                      if (widget.isSeries)
                        IconButton(
                          color: Colors.white,
                          iconSize: 32,
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            setState(() {
                              _showSidebar = !_showSidebar;
                            });
                          },
                          tooltip: 'Staffeln & Episoden',
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

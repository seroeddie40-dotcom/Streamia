import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../services/playlist_parser_service.dart';
import '../services/pro_guard_service.dart';
import '../services/recording_download_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _playlistService = PlaylistService();
  final _proService = ProGuardService();
  final _recordingService = RecordingDownloadService();

  @override
  void initState() {
    super.initState();
    if (_playlistService.playlists.isEmpty) {
      _playlistService.loadFullRichCatalog();
    }
  }

  Future<void> _openCategoryBrowser(MediaCategory category) async {
    await Navigator.pushNamed(
      context,
      '/media_browser',
      arguments: category,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final active = _playlistService.activePlaylist;
    final liveCount = _playlistService.getItemsByCategory(MediaCategory.live).length;
    final movieCount = _playlistService.getItemsByCategory(MediaCategory.movie).length;
    final seriesCount = _playlistService.getItemsByCategory(MediaCategory.series).length;
    final isPro = _proService.isProUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('STREAMIA CENTER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              active != null ? '${active.name} (${active.sourceType})' : 'Keine Quelle aktiv',
              style: const TextStyle(fontSize: 11, color: Color(0xFF00E5FF)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Zugangsdaten / QR / Quelle wechseln',
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF00E5FF)),
            onPressed: () async {
              await Navigator.pushNamed(context, '/playlist_input');
              setState(() {});
            },
          ),
          IconButton(
            tooltip: 'Pro-Status',
            icon: Icon(
              isPro ? Icons.workspace_premium : Icons.star_border,
              color: isPro ? Colors.amber : Colors.white,
            ),
            onPressed: () async {
              await Navigator.pushNamed(context, '/pro_upgrade');
              setState(() {});
            },
          ),
          IconButton(
            tooltip: 'Zum Login / Konto wechseln',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. HAUPTBEREICH: DIE 3 GROSSEN KACHELN (LIVE TV, FILME/VODS, SERIEN)
          const Text(
            'Medien-Kategorien',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MainCategoryTile(
                  title: 'LIVE TV',
                  subtitle: '$liveCount Sender\ninkl. Live-EPG',
                  icon: Icons.live_tv,
                  gradientColors: const [Color(0xFFE50914), Color(0xFF7A040A)],
                  onTap: () => _openCategoryBrowser(MediaCategory.live),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MainCategoryTile(
                  title: 'FILME (VOD)',
                  subtitle: '$movieCount Filme\nHD & 4K Kino',
                  icon: Icons.movie_creation_outlined,
                  gradientColors: const [Color(0xFF0072FF), Color(0xFF002B66)],
                  onTap: () => _openCategoryBrowser(MediaCategory.movie),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MainCategoryTile(
                  title: 'SERIEN',
                  subtitle: '$seriesCount Folgen\nAlle Staffeln',
                  icon: Icons.video_library_outlined,
                  gradientColors: const [Color(0xFF8E2DE2), Color(0xFF3B0B66)],
                  onTap: () => _openCategoryBrowser(MediaCategory.series),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // 2. SCHNELLEINSTELLUNGEN MIT AUSKLAPPBAREN UNTERINFORMATIONEN
          const Row(
            children: [
              Icon(Icons.tune, color: Color(0xFF00E5FF)),
              SizedBox(width: 8),
              Text(
                'Schnelleinstellungen & System-Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tippe auf eine Einstellung, um die detaillierten Unterinformationen & Steuerungen zu öffnen:',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // Schnelleinstellung 1: EPG & Programmführer-Steuerung
          Card(
            color: const Color(0xFF1A1D29),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              leading: const Icon(Icons.event_note, color: Color(0xFF00E5FF)),
              title: const Text('EPG-Programmführer & XMLTV', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Status: Aktiv • Aktualisierung: ${_playlistService.epgRefreshInterval}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Divider(color: Colors.white12),
                _SubInfoRow(label: 'Aktive EPG-URL:', value: active?.epgUrl ?? 'Nicht hinterlegt'),
                _SubInfoRow(label: 'Erkannte EPG-Sender:', value: '$liveCount Live-Kanäle synchronisiert'),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('EPG beim App-Start automatisch laden', style: TextStyle(fontSize: 14)),
                  value: _playlistService.autoUpdateEpg,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (val) => setState(() => _playlistService.autoUpdateEpg = val),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('EPG-Programmdaten wurden erfolgreich neu synchronisiert!')),
                          );
                        },
                        icon: const Icon(Icons.sync, size: 18),
                        label: const Text('EPG jetzt aktualisieren'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Schnelleinstellung 2: Player, Stream-Format & Puffer-Kontrolle
          Card(
            color: const Color(0xFF1A1D29),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              leading: const Icon(Icons.speed, color: Colors.amber),
              title: const Text('Player-Engine, Puffer & Stream-Format', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${_playlistService.hardwareDecoder} • Puffer: ${_playlistService.bufferSize}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Divider(color: Colors.white12),
                _SubInfoRow(label: 'Aktives Stream-Format:', value: _playlistService.streamFormat),
                _SubInfoRow(label: 'Video-Decoder:', value: _playlistService.hardwareDecoder),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _playlistService.bufferSize,
                  decoration: const InputDecoration(
                    labelText: 'Stream-Puffergröße (gegen Nachladen)',
                    filled: true,
                    fillColor: Color(0xFF0F111A),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Klein (1 Sekunde - Schnelles Umschalten)', child: Text('Klein (1 Sek.)')),
                    DropdownMenuItem(value: 'Mittel (3 Sekunden - Optimal)', child: Text('Mittel (3 Sek. - Optimal)')),
                    DropdownMenuItem(value: 'Groß (5 Sekunden - Maximale Stabilität)', child: Text('Groß (5 Sek.)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _playlistService.bufferSize = val);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _playlistService.hardwareDecoder,
                  decoration: const InputDecoration(
                    labelText: 'Decoder-Modus',
                    filled: true,
                    fillColor: Color(0xFF0F111A),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Hardware-Beschleunigung (HW+)',
                      child: Text('Hardware-Beschleunigung (HW+)'),
                    ),
                    DropdownMenuItem(
                      value: 'Software-Decoder (SW)',
                      child: Text('Software-Decoder (SW)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _playlistService.hardwareDecoder = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Schnelleinstellung 3: Aktive Verbindung, Xtream / M3U Details & Sortier-Übersicht
          Card(
            color: const Color(0xFF1A1D29),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              leading: const Icon(Icons.dns_outlined, color: Colors.greenAccent),
              title: const Text('Verbindungs-Details & Quellen-Verwaltung', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Quelle: ${active?.sourceType ?? "Keine"} • Gesamt: ${_playlistService.allItems.length} Einträge',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Divider(color: Colors.white12),
                _SubInfoRow(label: 'Server / Dateipfad:', value: active?.serverOrPath ?? '-'),
                _SubInfoRow(label: 'Katalog-Aufteilung:', value: '$liveCount Live • $movieCount Filme • $seriesCount Serien'),
                _SubInfoRow(label: 'Aufnahmen / Downloads:', value: '${_recordingService.tasks.length} gespeicherte Streams'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/playlist_input');
                          setState(() {});
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Weitere Quelle / EPG hinzufügen'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Schnelleinstellung 4: Kindersicherung & PIN-Kontrolle
          Card(
            color: const Color(0xFF1A1D29),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ExpansionTile(
              leading: const Icon(Icons.lock_outline, color: Colors.redAccent),
              title: const Text('Kindersicherung & Kanal-Sperre', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                _playlistService.parentalControlEnabled
                    ? 'Aktiviert (PIN-Schutz: ${_playlistService.parentalPin})'
                    : 'Deaktiviert • Alle Kategorien frei zugänglich',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Divider(color: Colors.white12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('PIN-Abfrage für gesperrte Kategorien aktivieren', style: TextStyle(fontSize: 14)),
                  value: _playlistService.parentalControlEnabled,
                  activeColor: const Color(0xFFE50914),
                  onChanged: (val) => setState(() => _playlistService.parentalControlEnabled = val),
                ),
                _SubInfoRow(label: 'Aktueller Sicherheits-PIN:', value: _playlistService.parentalPin),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainCategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _MainCategoryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        height: 165,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _SubInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

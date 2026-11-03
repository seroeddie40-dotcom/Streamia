import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../services/playlist_parser_service.dart';
import '../services/pro_guard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _playlistService = PlaylistService();
  final _proService = ProGuardService();

  @override
  void initState() {
    super.initState();
    if (_playlistService.playlists.isEmpty) {
      _playlistService.loadFullRichCatalog();
    }
  }

  void _openCategory(MediaCategory cat) {
    Navigator.pushNamed(context, '/media_browser', arguments: cat);
  }

  @override
  Widget build(BuildContext context) {
    final active = _playlistService.activePlaylist;
    final liveCount = _playlistService.getItemsByCategory(MediaCategory.live).length;
    final movieCount = _playlistService.getItemsByCategory(MediaCategory.movie).length;
    final seriesCount = _playlistService.getItemsByCategory(MediaCategory.series).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'STREAMIA TV • ${active?.name ?? "Keine Playlist"} (${_playlistService.macAddress})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Konto / QR-Code / MAC wechseln',
            icon: const Icon(Icons.qr_code_2, color: Color(0xFF00E5FF)),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 3 GROSSE FERNBEDIENUNGS-KACHELN
          Row(
            children: [
              Expanded(
                child: _TvCategoryCard(
                  title: 'LIVE TV',
                  subtitle: '$liveCount Sender mit EPG',
                  icon: Icons.live_tv,
                  gradient: const [Color(0xFFE50914), Color(0xFF80050B)],
                  onTap: () => _openCategory(MediaCategory.live),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TvCategoryCard(
                  title: 'FILME (VOD)',
                  subtitle: '$movieCount Filme in HD/4K',
                  icon: Icons.movie,
                  gradient: const [Color(0xFF0072FF), Color(0xFF003366)],
                  onTap: () => _openCategory(MediaCategory.movie),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TvCategoryCard(
                  title: 'SERIEN',
                  subtitle: '$seriesCount Staffeln & Folgen',
                  icon: Icons.video_library,
                  gradient: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  onTap: () => _openCategory(MediaCategory.series),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SCHNELLEINSTELLUNGEN
          const Text('Schnelleinstellungen & TV-Steuerung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Card(
            color: const Color(0xFF1A1D29),
            child: ListTile(
              leading: const Icon(Icons.event_note, color: Color(0xFF00E5FF)),
              title: const Text('EPG-Programmführer & TV-Guide'),
              subtitle: Text('Status: Aktiv • Synchronisiert für alle $liveCount Live-Kanäle'),
              trailing: const Icon(Icons.sync, color: Colors.greenAccent),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('EPG-Daten wurden erfolgreich aktualisiert!')),
                );
              },
            ),
          ),
          Card(
            color: const Color(0xFF1A1D29),
            child: ListTile(
              leading: const Icon(Icons.speed, color: Colors.amber),
              title: const Text('Stream-Puffer & Video-Decoder'),
              subtitle: Text('${_playlistService.hardwareDecoder} • Puffer: ${_playlistService.bufferSize}'),
            ),
          ),
          Card(
            color: const Color(0xFF1A1D29),
            child: ListTile(
              leading: const Icon(Icons.settings_ethernet, color: Colors.purpleAccent),
              title: const Text('Geräte-Daten & Online-Upload'),
              subtitle: Text('MAC: ${_playlistService.macAddress} • Key: ${_playlistService.deviceKey}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TvCategoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _TvCategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_TvCategoryCard> createState() => _TvCategoryCardState();
}

class _TvCategoryCardState extends State<_TvCategoryCard> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;
    return InkWell(
      focusNode: _focusNode,
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: widget.gradient),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasFocus ? Colors.white : Colors.transparent,
            width: hasFocus ? 4 : 0,
          ),
          boxShadow: hasFocus
              ? [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 16)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(widget.icon, size: 48, color: Colors.white),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

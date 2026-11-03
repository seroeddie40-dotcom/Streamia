import 'package:flutter/material.dart';
import '../services/playlist_parser_service.dart';
import '../services/pro_guard_service.dart';
import '../services/recording_download_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = true;
  bool _isRecording = false;
  String _selectedQuality = 'Auto (FHD / 4K)';
  String _selectedAudio = 'Deutsch (Dolby 5.1)';

  Future<void> _handleRecord(MediaItem item) async {
    if (!ProGuardService().isProUser) {
      final upgraded = await Navigator.pushNamed(context, '/pro_upgrade');
      if (upgraded != true && !ProGuardService().isProUser) return;
    }

    setState(() => _isRecording = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Aufnahme gestartet: ${item.title}')),
    );
    await RecordingDownloadService().startRecording(item.title, item.url);
    if (mounted) {
      setState(() => _isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aufnahme im Dashboard gespeichert: ${item.title}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final MediaItem item = args is MediaItem
        ? args
        : MediaItem(
            id: 'default_live_1',
            title: 'Streamia Live-Kanal',
            group: 'Live TV',
            url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
            category: MediaCategory.live,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            tooltip: 'Favorit markieren',
            icon: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: item.isFavorite ? Colors.redAccent : Colors.white,
            ),
            onPressed: () {
              setState(() {
                item.isFavorite = !item.isFavorite;
              });
            },
          ),
          IconButton(
            tooltip: 'Stream aufnehmen',
            icon: Icon(
              _isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
              color: Colors.redAccent,
            ),
            onPressed: () => _handleRecord(item),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlaying ? Icons.sensors : Icons.pause_circle_outline,
                          size: 72,
                          color: const Color(0xFFE50914),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isPlaying ? 'STREAM LÄUFT ($_selectedQuality)' : 'PAUSIERT',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            item.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 30,
                            ),
                            onPressed: () =>
                                setState(() => _isPlaying = !_isPlaying),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE50914),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category == MediaCategory.live
                                  ? 'LIVE • EPG AKTIV'
                                  : 'VOD • ${item.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        label: Text(
                          '★ ${item.rating.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategorie: ${item.group} • Jahr: ${item.year}',
                    style: const TextStyle(color: Color(0xFF00E5FF)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D29),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note, color: Color(0xFF00E5FF)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'EPG / Details: ${item.epgCurrentProgram}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedQuality,
                          decoration: const InputDecoration(
                            labelText: 'Auflösung',
                            filled: true,
                            fillColor: Color(0xFF1A1D29),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Auto (FHD / 4K)',
                              child: Text('Auto (FHD / 4K)'),
                            ),
                            DropdownMenuItem(
                              value: '1080p Full HD',
                              child: Text('1080p Full HD'),
                            ),
                            DropdownMenuItem(
                              value: '720p HD',
                              child: Text('720p HD'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedQuality = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedAudio,
                          decoration: const InputDecoration(
                            labelText: 'Tonspur',
                            filled: true,
                            fillColor: Color(0xFF1A1D29),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Deutsch (Dolby 5.1)',
                              child: Text('Deutsch (5.1)'),
                            ),
                            DropdownMenuItem(
                              value: 'Originalton (Stereo)',
                              child: Text('Originalton'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedAudio = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => _handleRecord(item),
                    icon: const Icon(Icons.download_for_offline),
                    label: Text(
                      ProGuardService().isProUser
                          ? 'Stream jetzt aufnehmen / herunterladen'
                          : 'Stream aufnehmen (Pro-Funktion)',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

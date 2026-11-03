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
        SnackBar(content: Text('Aufnahme im Dashboard gespeichert: ${item.title}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final MediaItem item = args is MediaItem
        ? args
        : MediaItem(
            title: 'Streamia Live-Kanal',
            group: 'Live TV',
            url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
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
      body: Column(
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
                        _isPlaying ? 'LIVE STREAM AKTIV' : 'PAUSIERT',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          item.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
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
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 30),
                          onPressed: () => setState(() => _isPlaying = !_isPlaying),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('LIVE • HD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Kategorie: ${item.group}', style: const TextStyle(color: Colors.white60)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1D29),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () => _handleRecord(item),
                  icon: const Icon(Icons.download_for_offline, color: Color(0xFF00E5FF)),
                  label: Text(
                    ProGuardService().isProUser
                        ? 'Sendung jetzt aufnehmen / speichern'
                        : 'Sendung aufnehmen (Pro-Funktion)',
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

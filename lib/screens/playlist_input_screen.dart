import 'package:flutter/material.dart';
import '../services/playlist_parser_service.dart';
import '../services/playlist_service.dart';

class PlaylistInputScreen extends StatefulWidget {
  const PlaylistInputScreen({super.key});

  @override
  State<PlaylistInputScreen> createState() => _PlaylistInputScreenState();
}

class _PlaylistInputScreenState extends State<PlaylistInputScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _m3uTextController = TextEditingController();

  void _savePlaylist() {
    final name = _nameController.text.trim().isEmpty
        ? 'Meine Playlist ${_ PlaylistService().playlists.length + 1}'
        : _nameController.text.trim();
    final url = _urlController.text.trim();
    final rawM3u = _m3uTextController.text.trim();

    if (url.isEmpty && rawM3u.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib eine Stream-URL oder M3U-Einträge ein.')),
      );
      return;
    }

    List<MediaItem> channels = [];
    if (rawM3u.isNotEmpty) {
      channels = PlaylistParserService().parseM3u(rawM3u);
    } else {
      channels = [
        MediaItem(
          title: '$name - Hauptkanal',
          group: 'Live TV',
          url: url,
        ),
      ];
    }

    PlaylistService().addPlaylist(
      name,
      url.isEmpty ? 'Lokaler M3U-Import' : url,
      channels,
    );

    Navigator.pop(context);
  }

  void _loadDemo() {
    PlaylistService().loadDemoPlaylist();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlist hinzufügen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name der Playlist (z. B. Wohnzimmer TV)',
                prefixIcon: const Icon(Icons.label_outline),
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'M3U-URL oder direkter Stream-Link (.m3u8)',
                prefixIcon: const Icon(Icons.link),
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _m3uTextController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Optional: Direkten #EXTM3U Text hier einfügen',
                alignLabelWithHint: true,
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _savePlaylist,
              icon: const Icon(Icons.save),
              label: const Text('Playlist speichern & öffnen', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _loadDemo,
              icon: const Icon(Icons.Bolt),
              label: const Text('Sofortige Demo-Senderliste laden'),
            ),
          ],
        ),
      ),
    );
  }
}

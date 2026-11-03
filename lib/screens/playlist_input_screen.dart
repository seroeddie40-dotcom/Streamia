import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _epgController = TextEditingController();
  final _m3uTextController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _epgController.dispose();
    _m3uTextController.dispose();
    super.dispose();
  }

  Future<void> _pasteTo(TextEditingController ctrl) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        ctrl.text = data!.text!.trim();
      });
    }
  }

  void _savePlaylist() {
    final name = _nameController.text.trim().isEmpty
        ? 'Quelle ${PlaylistService().playlists.length + 1}'
        : _nameController.text.trim();
    final url = _urlController.text.trim();
    final epg = _epgController.text.trim();
    final rawM3u = _m3uTextController.text.trim();

    if (url.isEmpty && rawM3u.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte gib eine Xtream/M3U-URL oder M3U-Einträge ein.'),
        ),
      );
      return;
    }

    if (rawM3u.isNotEmpty) {
      final items = PlaylistParserService().parseM3u(rawM3u);
      PlaylistService().addCustomPlaylist(
        name: name,
        sourceType: 'Manueller M3U-Import',
        serverOrPath: url.isEmpty ? 'Lokale M3U-Datei' : url,
        epgUrl: epg,
        items: items,
      );
    } else {
      PlaylistService().loadFullRichCatalog(
        name: name,
        sourceType: 'M3U / Xtream Quelle',
        serverOrPath: url,
        epgUrl: epg.isEmpty ? 'Automatischer EPG' : epg,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quelle & EPG hinzufügen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Bezeichnung (z. B. Haupt-Server)',
                prefixIcon: const Icon(Icons.label_outline),
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Xtream Server-URL oder M3U-Link',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  tooltip: 'Einfügen',
                  icon: const Icon(Icons.content_paste, color: Color(0xFF00E5FF)),
                  onPressed: () => _pasteTo(_urlController),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _epgController,
              decoration: InputDecoration(
                labelText: 'EPG-Link (XMLTV URL)',
                prefixIcon: const Icon(Icons.event_note),
                suffixIcon: IconButton(
                  tooltip: 'EPG-Link einfügen',
                  icon: const Icon(Icons.content_paste, color: Color(0xFF00E5FF)),
                  onPressed: () => _pasteTo(_epgController),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _m3uTextController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Optional: M3U-Dateiinhalt (#EXTM3U) hier einfügen',
                alignLabelWithHint: true,
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              label: const Text(
                'Quelle inkl. EPG speichern',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

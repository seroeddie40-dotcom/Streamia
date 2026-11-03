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

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _m3uTextController.dispose();
    super.dispose();
  }

  void _savePlaylist() {
    final name = _nameController.text.trim().isEmpty
        ? 'Meine Playlist ${PlaylistService().playlists.length + 1}'
        : _nameController.text.trim();
    final url = _urlController.text.trim();
    final rawM3u = _m3uTextController.text.trim();

    if (url.isEmpty && rawM3u.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte gib eine Stream-URL oder M3U-Einträge ein.'),
        ),
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

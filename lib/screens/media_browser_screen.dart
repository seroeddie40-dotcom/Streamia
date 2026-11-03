import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../services/playlist_parser_service.dart';

class MediaBrowserScreen extends StatefulWidget {
  const MediaBrowserScreen({super.key});

  @override
  State<MediaBrowserScreen> createState() => _MediaBrowserScreenState();
}

class _MediaBrowserScreenState extends State<MediaBrowserScreen> {
  String _searchQuery = '';
  String _selectedGroup = 'Alle';

  @override
  Widget build(BuildContext context) {
    final activePlaylist = PlaylistService().activePlaylist;
    final allChannels = activePlaylist?.channels ?? [];

    final groups = <String>{'Alle', ...allChannels.map((c) => c.group)}.toList();

    final filteredChannels = allChannels.where((channel) {
      final matchesSearch = channel.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGroup = _selectedGroup == 'Alle' || channel.group == _selectedGroup;
      return matchesSearch && matchesGroup;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(activePlaylist?.name ?? 'Senderliste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/playlist_input');
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Sender durchsuchen...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final isSelected = group == _selectedGroup;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(group),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedGroup = group),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredChannels.isEmpty
                ? const Center(child: Text('Keine passenden Sender gefunden.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredChannels.length,
                    itemBuilder: (context, index) {
                      final MediaItem item = filteredChannels[index];
                      return Card(
                        color: const Color(0xFF1A1D29),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE50914),
                            child: Icon(Icons.live_tv, color: Colors.white),
                          ),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.group, style: const TextStyle(color: Colors.white54)),
                          trailing: const Icon(Icons.play_circle_fill, color: Color(0xFF00E5FF), size: 32),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/player',
                              arguments: item,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

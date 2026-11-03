import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../services/playlist_parser_service.dart';

enum SortMode { az, za, ratingDesc, newest, group }

class MediaBrowserScreen extends StatefulWidget {
  const MediaBrowserScreen({super.key});

  @override
  State<MediaBrowserScreen> createState() => _MediaBrowserScreenState();
}

class _MediaBrowserScreenState extends State<MediaBrowserScreen> {
  MediaCategory _activeCategory = MediaCategory.live;
  bool _initializedFromArgs = false;

  String _searchQuery = '';
  String _selectedGroup = 'Alle';
  SortMode _sortMode = SortMode.az;
  bool _onlyFavorites = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is MediaCategory) {
        _activeCategory = args;
      }
      _initializedFromArgs = true;
    }
  }

  String _categoryTitle(MediaCategory cat) {
    switch (cat) {
      case MediaCategory.live:
        return 'Live TV Sender';
      case MediaCategory.movie:
        return 'Filme (VOD)';
      case MediaCategory.series:
        return 'Serien';
    }
  }

  String _sortLabel(SortMode mode) {
    switch (mode) {
      case SortMode.az:
        return 'Name (A → Z)';
      case SortMode.za:
        return 'Name (Z → A)';
      case SortMode.ratingDesc:
        return 'Beste Bewertung zuerst';
      case SortMode.newest:
        return 'Neueste zuerst';
      case SortMode.group:
        return 'Nach Gruppe / Genre';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryItems = PlaylistService().getItemsByCategory(_activeCategory);
    final groups = <String>{'Alle', ...categoryItems.map((c) => c.group)}.toList();
    if (!groups.contains(_selectedGroup)) {
      _selectedGroup = 'Alle';
    }

    // Filtern
    List<MediaItem> filtered = categoryItems.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.group.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGroup = _selectedGroup == 'Alle' || item.group == _selectedGroup;
      final matchesFav = !_onlyFavorites || item.isFavorite;
      return matchesSearch && matchesGroup && matchesFav;
    }).toList();

    // Sortieren
    filtered.sort((a, b) {
      switch (_sortMode) {
        case SortMode.az:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortMode.za:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case SortMode.ratingDesc:
          return b.rating.compareTo(a.rating);
        case SortMode.newest:
          return b.addedAt.compareTo(a.addedAt);
        case SortMode.group:
          return a.group.toLowerCase().compareTo(b.group.toLowerCase());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_categoryTitle(_activeCategory)),
        actions: [
          // Favoriten-Schalter
          IconButton(
            tooltip: 'Nur Favoriten anzeigen',
            icon: Icon(
              _onlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: _onlyFavorites ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => setState(() => _onlyFavorites = !_onlyFavorites),
          ),
          // Sortier-Menü
          PopupMenuButton<SortMode>(
            tooltip: 'Sortierung ändern',
            icon: const Icon(Icons.sort, color: Color(0xFF00E5FF)),
            onSelected: (mode) => setState(() => _sortMode = mode),
            itemBuilder: (ctx) => SortMode.values
                .map(
                  (mode) => PopupMenuItem(
                    value: mode,
                    child: Row(
                      children: [
                        Icon(
                          _sortMode == mode ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: const Color(0xFF00E5FF),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(_sortLabel(mode)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Kategorie-Umschalter (Live TV | Filme | Serien)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                _buildCategorySwitchButton(MediaCategory.live, 'Live TV', Icons.live_tv),
                const SizedBox(width: 8),
                _buildCategorySwitchButton(MediaCategory.movie, 'Filme (VOD)', Icons.movie),
                const SizedBox(width: 8),
                _buildCategorySwitchButton(MediaCategory.series, 'Serien', Icons.video_library),
              ],
            ),
          ),

          // Suchleiste + Aktive Sortier-Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: '${_categoryTitle(_activeCategory)} durchsuchen...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1D29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Gruppen / Genre Filterleiste
          SizedBox(
            height: 40,
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
                    selectedColor: const Color(0xFFE50914),
                    onSelected: (_) => setState(() => _selectedGroup = group),
                  ),
                );
              },
            ),
          ),

          // Statuszeile: Anzahl & aktive Sortierung
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} Einträge gefunden',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                Text(
                  'Sortiert: ${_sortLabel(_sortMode)}',
                  style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Ergebnisliste mit EPG & Details
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('Keine Einträge für diesen Filter gefunden.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        color: const Color(0xFF1A1D29),
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFE50914),
                            child: Icon(
                              item.category == MediaCategory.live
                                  ? Icons.live_tv
                                  : item.category == MediaCategory.movie
                                      ? Icons.movie
                                      : Icons.video_library,
                              color: Colors.white,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 13),
                                    const SizedBox(width: 3),
                                    Text(
                                      item.rating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 11, color: Colors.amber),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${item.group} • ${item.year}',
                                style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'EPG / Info: ${item.epgCurrentProgram}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: item.isFavorite ? Colors.redAccent : Colors.white38,
                                ),
                                onPressed: () {
                                  setState(() {
                                    item.isFavorite = !item.isFavorite;
                                  });
                                },
                              ),
                              const Icon(Icons.play_circle_fill, color: Color(0xFF00E5FF), size: 32),
                            ],
                          ),
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

  Widget _buildCategorySwitchButton(MediaCategory cat, String label, IconData icon) {
    final selected = _activeCategory == cat;
    return Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFFE50914) : const Color(0xFF1A1D29),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          setState(() {
            _activeCategory = cat;
            _selectedGroup = 'Alle';
          });
        },
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

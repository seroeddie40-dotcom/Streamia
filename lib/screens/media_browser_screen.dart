import 'package:flutter/material.dart';
import 'player_screen.dart';
import '../services/recording_download_service.dart';

class MediaBrowserScreen extends StatefulWidget {
  final String categoryTitle;
  final bool isSeries;

  const MediaBrowserScreen({
    Key? key,
    required this.categoryTitle,
    required this.isSeries,
  }) : super(key: key);

  @override
  State<MediaBrowserScreen> createState() => _MediaBrowserScreenState();
}

class _MediaBrowserScreenState extends State<MediaBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSort = 'A-Z';
  String _selectedDialectLanguage = 'Deutsch (Standard / Dialekte)';

  // Beispiel-Daten inklusive Cover-URL und Beschreibung
  final List> _allItems = [
    {
      'title': 'Action Blockbuster 2026',
      'year': '2026',
      'rating': '4.8',
      'cover': 'https://picsum.photos/300/450?random=1',
      'description': 'Ein spannender Actionfilm über die Rettung der Welt im Jahr 2026 mit atemberaubenden Spezialeffekten.',
    },
    {
      'title': 'Abenteuer im Dschungel',
      'year': '2024',
      'rating': '4.2',
      'cover': 'https://picsum.photos/300/450?random=2',
      'description': 'Entdecke die unberührten Tiefen des Urwalds in dieser packenden Dokumentation und Spielfilm-Mischung.',
    },
    {
      'title': '300 Spartans: Legacy',
      'year': '2023',
      'rating': '4.6',
      'cover': 'https://picsum.photos/300/450?random=3',
      'description': 'Die epische Fortsetzung der legendären Schlacht, neu interpretiert mit modernster Kinotechnologie.',
    },
    {
      'title': 'Comedy Night Live',
      'year': '2025',
      'rating': '3.9',
      'cover': 'https://picsum.photos/300/450?random=4',
      'description': 'Die besten Stand-up Comedians des Landes vereint an einem Abend voller Lacher und Überraschungen.',
    },
  ];

  final List<String> _supportedLanguages = [
    'Deutsch (Standard / Dialekte)',
    'Englisch (US / UK / AUS)',
    'Türkisch (Istanbul / Anadoluhügelland)',
    'Spanisch (LatAm / Castellano)',
    'Französisch (Paris / Québec)',
    'Arabisch (Modern / Regional)',
    'Italienisch (Nord / Süd)',
    'Russisch (Standard)',
  ];

  @override
  Widget build(BuildContext context) {
    List> filteredList = _allItems.where((item) {
      final title = item['title'].toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    filteredList.sort((a, b) {
      if (_selectedSort == 'A-Z') {
        return a['title'].compareTo(b['title']);
      } else if (_selectedSort == 'Z-A') {
        return b['title'].compareTo(a['title']);
      } else if (_selectedSort == '0-9 (Zahlen zuerst)') {
        bool aIsNum = RegExp(r'^[0-9]').hasMatch(a['title']);
        bool bIsNum = RegExp(r'^[0-9]').hasMatch(b['title']);
        if (aIsNum && !bIsNum) return -1;
        if (!aIsNum && bIsNum) return 1;
        return a['title'].compareTo(b['title']);
      } else {
        return b['year'].compareTo(a['year']);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('${widget.categoryTitle} (Cover & Details)'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.mic, color: Colors.blueAccent),
            tooltip: 'Sprachsuche & Dialekte',
            onSelected: (lang) {
              setState(() => _selectedDialectLanguage = lang);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sprachprofil aktiv: $lang (Dialekte einberechnet)')),
              );
            },
            itemBuilder: (context) {
              return _supportedLanguages.map((lang) {
                return PopupMenuItem(value: lang, child: Text(lang, style: const TextStyle(fontSize: 13)));
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Suche (mit Dialekt-Unterstützung)...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: ['A-Z', 'Z-A', '0-9 (Zahlen zuerst)', 'Neueste'].map((opt) {
                          return DropdownMenuItem(value: opt, child: Text('Sort: $opt'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSort = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text('Keine Einträge gefunden.', style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      itemCount: filteredList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return Card(
                          color: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () {
                              _showDetailsDialog(context, item);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Cover Bild
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      item['cover'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        color: Colors.grey.shade800,
                                        child: const Icon(Icons.movie, size: 40, color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(item['year'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                          Text('⭐ ${item['rating']}', style: const TextStyle(color: Colors.amber, fontSize: 11)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Detail-Dialog mit Cover, Beschreibung, Player-Start und USB-Download
  void _showDetailsDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(item['title'], style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 500,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item['cover'], width: 120, height: 180, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Erscheinungsjahr: ${item['year']}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                    const SizedBox(height: 8),
                    const Text('Beschreibung:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(item['description'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerScreen(
                                  streamUrl: 'http://sample.m3u',
                                  title: item['title'],
                                  isSeries: widget.isSeries,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Abspielen'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.greenAccent),
                          tooltip: 'Auf USB-Stick herunterladen (MP4)',
                          onPressed: () {
                            RecordingDownloadService.downloadMediaToUsb(
                              context: context,
                              mediaTitle: item['title'],
                              downloadUrl: 'http://sample.m3u',
                              usbDirectoryPath: '/storage/usb_disk', // Beispiel USB-Pfad
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

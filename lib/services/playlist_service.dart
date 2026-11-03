import 'playlist_parser_service.dart';

class Playlist {
  final String id;
  final String name;
  final String sourceType; // 'Xtream Codes', 'M3U Datei / Link', 'QR-Scan'
  final String serverOrPath;
  final String epgUrl;
  final DateTime lastUpdated;
  final List<MediaItem> items;

  Playlist({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.serverOrPath,
    required this.epgUrl,
    required this.lastUpdated,
    required this.items,
  });
}

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  final List<Playlist> _playlists = [];
  Playlist? _activePlaylist;

  // Einstellungs-Werte für die Schnellsteuerung im Dashboard
  String streamFormat = 'MPEG-TS (.ts) / HLS (.m3u8)';
  String hardwareDecoder = 'Hardware-Beschleunigung (HW+)';
  String bufferSize = 'Mittel (3 Sekunden - Optimal)';
  String epgRefreshInterval = 'Alle 12 Stunden automatisch';
  bool parentalControlEnabled = false;
  String parentalPin = '0000';
  bool autoUpdateEpg = true;

  List<Playlist> get playlists => _playlists;
  Playlist? get activePlaylist =>
      _activePlaylist ?? (_playlists.isNotEmpty ? _playlists.first : null);

  List<MediaItem> get allItems => activePlaylist?.items ?? [];

  List<MediaItem> getItemsByCategory(MediaCategory category) {
    return allItems.where((item) => item.category == category).toList();
  }

  void setActivePlaylist(Playlist playlist) {
    _activePlaylist = playlist;
  }

  void addCustomPlaylist({
    required String name,
    required String sourceType,
    required String serverOrPath,
    required String epgUrl,
    required List<MediaItem> items,
  }) {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      sourceType: sourceType,
      serverOrPath: serverOrPath,
      epgUrl: epgUrl.isEmpty ? 'Standard-EPG (Automatisch)' : epgUrl,
      lastUpdated: DateTime.now(),
      items: items,
    );
    _playlists.add(newPlaylist);
    _activePlaylist = newPlaylist;
  }

  void removePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    if (_activePlaylist?.id == id) {
      _activePlaylist = _playlists.isNotEmpty ? _playlists.first : null;
    }
  }

  void loadFullRichCatalog({
    String name = 'Streamia Komplett-Paket',
    String sourceType = 'Xtream Codes API',
    String serverOrPath = 'http://line.streamia-dns.com:8080',
    String epgUrl = 'http://line.streamia-dns.com:8080/xmltv.php',
  }) {
    final now = DateTime.now();
    final List<MediaItem> demoItems = [
      // LIVE TV SENDER
      MediaItem(
        id: 'live_1',
        title: 'Das Erste HD',
        group: 'DE • Vollprogramme',
        url: 'https://mcdn.daserste.de/daserste/de/master.m3u8',
        category: MediaCategory.live,
        epgCurrentProgram: '20:15 - Tagesschau & Primetime Live',
        rating: 9.2,
        year: 'LIVE',
        addedAt: now.subtract(const Duration(minutes: 10)),
      ),
      MediaItem(
        id: 'live_2',
        title: 'Tagesschau 24 HD',
        group: 'DE • Nachrichten',
        url: 'https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8',
        category: MediaCategory.live,
        epgCurrentProgram: 'Aktuelle Nachrichten rund um die Uhr',
        rating: 8.9,
        year: 'LIVE',
        addedAt: now.subtract(const Duration(minutes: 25)),
      ),
      MediaItem(
        id: 'live_3',
        title: 'Red Bull TV HD',
        group: 'DE • Sport & Action',
        url: 'https://rbmn-live.akamaized.net/hls/live/590964/BoRB-AT/master.m3u8',
        category: MediaCategory.live,
        epgCurrentProgram: 'Live Extremsport & Events',
        rating: 9.0,
        year: 'LIVE',
        addedAt: now.subtract(const Duration(hours: 1)),
      ),
      MediaItem(
        id: 'live_4',
        title: 'NASA TV UHD',
        group: 'INT • Doku & Wissenschaft',
        url: 'https://ntv1.akamaized.net/hls/live/2014075/NASA-NTV1-HLS/master.m3u8',
        category: MediaCategory.live,
        epgCurrentProgram: 'ISS Live-Übertragung aus dem All',
        rating: 9.5,
        year: 'LIVE',
        addedAt: now.subtract(const Duration(hours: 2)),
      ),
      MediaItem(
        id: 'live_5',
        title: 'Sport Arena 1 FHD',
        group: 'DE • Sport & Action',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.live,
        epgCurrentProgram: 'Topspiel der Woche - Vorberichterstattung',
        rating: 9.4,
        year: 'LIVE',
        addedAt: now.subtract(const Duration(hours: 3)),
      ),

      // FILME (VODS)
      MediaItem(
        id: 'vod_1',
        title: 'Cyber Horizon 2049 (4K)',
        group: 'VOD • Sci-Fi & Action',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.movie,
        epgCurrentProgram: 'Laufzeit: 142 Min • Deutsch / Englisch • UHD HDR',
        rating: 9.3,
        year: '2026',
        addedAt: now.subtract(const Duration(hours: 4)),
      ),
      MediaItem(
        id: 'vod_2',
        title: 'Nacht über Berlin - Der Thriller',
        group: 'VOD • Krimi & Thriller',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.movie,
        epgCurrentProgram: 'Laufzeit: 118 Min • Deutsch DD 5.1 • Full HD',
        rating: 8.6,
        year: '2025',
        addedAt: now.subtract(const Duration(days: 1)),
      ),
      MediaItem(
        id: 'vod_3',
        title: 'Big Buck Bunny - Animationsfilm',
        group: 'VOD • Familie & Animation',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.movie,
        epgCurrentProgram: 'Laufzeit: 95 Min • Familienkomödie • Full HD',
        rating: 8.1,
        year: '2024',
        addedAt: now.subtract(const Duration(days: 3)),
      ),
      MediaItem(
        id: 'vod_4',
        title: 'Apex Racers - Im Rausch der Tiefe',
        group: 'VOD • Sci-Fi & Action',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.movie,
        epgCurrentProgram: 'Laufzeit: 130 Min • Dolby Atmos • 4K',
        rating: 8.9,
        year: '2026',
        addedAt: now.subtract(const Duration(hours: 2)),
      ),

      // SERIEN
      MediaItem(
        id: 'ser_1',
        title: 'Dark Net Chronicles - S01E01',
        group: 'Serien • Thriller & Mystery',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.series,
        epgCurrentProgram: 'Staffel 1 • Folge 1: Das Signal (52 Min)',
        rating: 9.6,
        year: '2026',
        addedAt: now.subtract(const Duration(hours: 1)),
      ),
      MediaItem(
        id: 'ser_2',
        title: 'Dark Net Chronicles - S01E02',
        group: 'Serien • Thriller & Mystery',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.series,
        epgCurrentProgram: 'Staffel 1 • Folge 2: Verschlüsselt (49 Min)',
        rating: 9.4,
        year: '2026',
        addedAt: now.subtract(const Duration(hours: 2)),
      ),
      MediaItem(
        id: 'ser_3',
        title: 'Galactic Pioneers - S02E01',
        group: 'Serien • Sci-Fi',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.series,
        epgCurrentProgram: 'Staffel 2 • Folge 1: Neue Welten (58 Min)',
        rating: 8.8,
        year: '2025',
        addedAt: now.subtract(const Duration(days: 2)),
      ),
      MediaItem(
        id: 'ser_4',
        title: 'Medizin am Limit - S04E08',
        group: 'Serien • Drama',
        url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        category: MediaCategory.series,
        epgCurrentProgram: 'Staffel 4 • Folge 8: Nachtschicht (45 Min)',
        rating: 8.3,
        year: '2024',
        addedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    addCustomPlaylist(
      name: name,
      sourceType: sourceType,
      serverOrPath: serverOrPath,
      epgUrl: epgUrl,
      items: demoItems,
    );
  }
}

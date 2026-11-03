import 'playlist_parser_service.dart';

class Playlist {
  final String id;
  final String name;
  final String url;
  final List<MediaItem> channels;

  Playlist({
    required this.id,
    required this.name,
    required this.url,
    required this.channels,
  });
}

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  final List<Playlist> _playlists = [];
  Playlist? _activePlaylist;

  List<Playlist> get playlists => _playlists;
  Playlist? get activePlaylist => _activePlaylist ?? (_playlists.isNotEmpty ? _playlists.first : null);

  void setActivePlaylist(Playlist playlist) {
    _activePlaylist = playlist;
  }

  void addPlaylist(String name, String url, List<MediaItem> channels) {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: url,
      channels: channels,
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

  void loadDemoPlaylist() {
    const sampleM3u = '''#EXTM3U
#EXTINF:-1 group-title="News & Doku",Tagesschau 24 HD (Demo)
https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8
#EXTINF:-1 group-title="Kultur & Wissen",NASA TV Public (Demo)
https://ntv1.akamaized.net/hls/live/2014075/NASA-NTV1-HLS/master.m3u8
#EXTINF:-1 group-title="Entertainment",Red Bull TV (Demo)
https://rbmn-live.akamaized.net/hls/live/590964/BoRB-AT/master.m3u8
#EXTINF:-1 group-title="Filme & Serien",Big Buck Bunny (VOD Demo)
https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
''';
    final channels = PlaylistParserService().parseM3u(sampleM3u);
    addPlaylist('Streamia Demo-Senderliste', 'https://streamia.app/demo.m3u', channels);
  }
}

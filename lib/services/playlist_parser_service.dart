import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaylistParserService {

  // 1. Xtream Codes API Parser (Lädt Live TV, Filme, Serien direkt vom Server)
  static Future> fetchXtreamData({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    try {
      final formattedUrl = serverUrl.endsWith('/') ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl;
      final authUrl = '$formattedUrl/player_api.php?username=$username&password=$password';

      final response = await http.get(Uri.parse(authUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // userInfo enthält Kontodaten, serverInfo etc.
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': 'Server antwortete mit Code: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 2. M3U Playlist Parser (Parft lokale M3U-Dateien oder Links nach Sendern, Titeln und URLs)
  static List> parseM3UContent(String m3uContent) {
    final List> playlistItems = [];
    final lines = m3uContent.split('\n');

    String currentTitle = '';
    String currentLogo = '';

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('#EXTINF:')) {
        // Titel und Logos aus der Extinf-Zeile extrahieren
        if (line.contains(',')) {
          currentTitle = line.split(',').last.trim();
        }
        if (line.contains('tvg-logo="')) {
          try {
            currentLogo = line.split('tvg-logo="')[1].split('"').first;
          } catch (_) {
            currentLogo = '';
          }
        }
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        // Das ist die Stream-URL
        playlistItems.add({
          'title': currentTitle.isNotEmpty ? currentTitle : 'Unbenannter Stream',
          'url': line,
          'logo': currentLogo,
        });
        currentTitle = '';
        currentLogo = '';
      }
    }
    return playlistItems;
  }
}


import 'package:shared_preferences/shared_preferences.dart';

class PlaylistService {
  static const String _keyPlaylistType = 'playlist_type'; // 'xtream' oder 'm3u'
  static const String _keyPlaylistData = 'playlist_data'; // URL, User, Pass oder M3U Inhalt
  static const String _keyPlaylistName = 'playlist_name';

  // 1. Playlist speichern (Freemium: überschreibt die alte, da nur 1 erlaubt)
  static Future<void> savePlaylist({
    required String type,
    required String data,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlaylistType, type);
    await prefs.setString(_keyPlaylistData, data);
    await prefs.setString(_keyPlaylistName, name);
  }

  // 2. Prüfen, ob eine Playlist vorhanden ist
  static Future<bool> hasPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyPlaylistData);
  }

  // 3. Gespeicherte Playlist-Daten abrufen
  static Future> getPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'type': prefs.getString(_keyPlaylistType),
      'data': prefs.getString(_keyPlaylistData),
      'name': prefs.getString(_keyPlaylistName),
    };
  }

  // 4. Playlist löschen (z.B. über die Einstellungen in der Freemium-Version)
  static Future<void> clearPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlaylistType);
    await prefs.remove(_keyPlaylistData);
    await prefs.remove(_keyPlaylistName);
  }
}

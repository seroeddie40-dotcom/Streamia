enum MediaCategory { live, movie, series }

class MediaItem {
  final String id;
  final String title;
  final String group;
  final String url;
  final MediaCategory category;
  final String? logo;
  final String epgCurrentProgram;
  final String year;
  final double rating;
  final DateTime addedAt;
  bool isFavorite;

  MediaItem({
    required this.id,
    required this.title,
    required this.group,
    required this.url,
    required this.category,
    this.logo,
    this.epgCurrentProgram = 'Keine EPG-Programmdaten verfügbar',
    this.year = '2026',
    this.rating = 8.5,
    DateTime? addedAt,
    this.isFavorite = false,
  }) : addedAt = addedAt ?? DateTime.now();
}

class PlaylistParserService {
  List<MediaItem> parseM3u(String content) {
    final lines = content.split('\n');
    final List<MediaItem> items = [];
    String currentTitle = 'Unbekannter Titel';
    String currentGroup = 'Allgemein';
    String? currentLogo;
    int counter = 1;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF:')) {
        final titleParts = line.split(',');
        if (titleParts.length > 1) {
          currentTitle = titleParts.last.trim();
        }
        final groupMatch = RegExp(r'group-title="([^"]+)"').firstMatch(line);
        if (groupMatch != null) {
          currentGroup = groupMatch.group(1) ?? 'Allgemein';
        }
        final logoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(line);
        if (logoMatch != null) {
          currentLogo = logoMatch.group(1);
        }
      } else if (!line.startsWith('#')) {
        final lowerGroup = currentGroup.toLowerCase();
        final lowerUrl = line.toLowerCase();
        MediaCategory cat = MediaCategory.live;

        if (lowerGroup.contains('movie') ||
            lowerGroup.contains('film') ||
            lowerGroup.contains('vod') ||
            lowerGroup.contains('kino') ||
            lowerUrl.endsWith('.mp4') ||
            lowerUrl.endsWith('.mkv')) {
          cat = MediaCategory.movie;
        } else if (lowerGroup.contains('serie') ||
            lowerGroup.contains('series') ||
            lowerGroup.contains('staffel') ||
            RegExp(r's\d+e\d+', caseSensitive: false).hasMatch(currentTitle)) {
          cat = MediaCategory.series;
        }

        items.add(
          MediaItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}_$counter',
            title: currentTitle,
            group: currentGroup,
            url: line,
            category: cat,
            logo: currentLogo,
            epgCurrentProgram: cat == MediaCategory.live
                ? 'Live-Übertragung • 20:15 - 22:00 Uhr'
                : 'On-Demand Abruf bereit (Full HD / 4K)',
            year: '${2020 + (counter % 7)}',
            rating: 7.0 + ((counter % 28) / 10.0),
            addedAt: DateTime.now().subtract(Duration(hours: counter * 3)),
          ),
        );
        counter++;
        currentTitle = 'Unbekannter Titel';
        currentGroup = 'Allgemein';
        currentLogo = null;
      }
    }
    return items;
  }
}

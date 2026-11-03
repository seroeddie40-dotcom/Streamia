class MediaItem {
  final String title;
  final String group;
  final String url;
  final String? logo;

  MediaItem({
    required this.title,
    required this.group,
    required this.url,
    this.logo,
  });
}

class PlaylistParserService {
  List<MediaItem> parseM3u(String content) {
    final lines = content.split('\n');
    final List<MediaItem> items = [];
    String currentTitle = 'Unbekannter Kanal';
    String currentGroup = 'Allgemein';
    String? currentLogo;

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
        items.add(
          MediaItem(
            title: currentTitle,
            group: currentGroup,
            url: line,
            logo: currentLogo,
          ),
        );
        currentTitle = 'Unbekannter Kanal';
        currentGroup = 'Allgemein';
        currentLogo = null;
      }
    }
    return items;
  }
}

import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../services/pro_guard_service.dart';
import '../services/recording_download_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _playlistService = PlaylistService();
  final _proService = ProGuardService();
  final _recordingService = RecordingDownloadService();

  Future<void> _navigateAndRefresh(String routeName) async {
    await Navigator.pushNamed(context, routeName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final playlists = _playlistService.playlists;
    final isPro = _proService.isProUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Streamia Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Pro-Status',
            icon: Icon(
              isPro ? Icons.workspace_premium : Icons.star_border,
              color: isPro ? Colors.amber : Colors.white,
            ),
            onPressed: () => _navigateAndRefresh('/pro_upgrade'),
          ),
          IconButton(
            tooltip: 'Abmelden',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPro
                    ? [const Color(0xFFB8860B), const Color(0xFF1A1D29)]
                    : [const Color(0xFFE50914), const Color(0xFF1A1D29)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  isPro ? Icons.verified : Icons.live_tv,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPro ? 'Streamia PRO Aktiv' : 'Streamia Basis-Version',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPro
                            ? 'Alle Aufnahmen, Downloads & 4K-Streams sind freigeschaltet.'
                            : 'Schalte Aufnahmen & Offline-Downloads mit Pro frei.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (!isPro)
                  ElevatedButton(
                    onPressed: () => _navigateAndRefresh('/pro_upgrade'),
                    child: const Text('Upgrade'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.playlist_add,
                  title: 'Playlist hinzufügen',
                  subtitle: 'M3U-Link oder Datei',
                  onTap: () => _navigateAndRefresh('/playlist_input'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.tv,
                  title: 'Sender öffnen',
                  subtitle: '${_playlistService.activePlaylist?.channels.length ?? 0} Kanäle bereit',
                  onTap: () {
                    if (playlists.isEmpty) {
                      _navigateAndRefresh('/playlist_input');
                    } else {
                      _navigateAndRefresh('/media_browser');
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Meine Playlists',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (playlists.isEmpty)
            Card(
              color: const Color(0xFF1A1D29),
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.amber),
                title: const Text('Noch keine Playlist vorhanden'),
                subtitle: const Text('Tippe hier, um eine M3U-Liste oder Demo zu laden.'),
                onTap: () => _navigateAndRefresh('/playlist_input'),
              ),
            )
          else
            ...playlists.map(
              (playlist) => Card(
                color: const Color(0xFF1A1D29),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE50914),
                    child: Icon(Icons.Queue_music, color: Colors.white),
                  ),
                  title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${playlist.channels.length} Sender • ${playlist.url}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.greenAccent),
                        onPressed: () {
                          _playlistService.setActivePlaylist(playlist);
                          _navigateAndRefresh('/media_browser');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _playlistService.removePlaylist(playlist.id);
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _playlistService.setActivePlaylist(playlist);
                    _navigateAndRefresh('/media_browser');
                  },
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Aufnahmen & Downloads (${_recordingService.tasks.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_recordingService.tasks.isEmpty)
            const Text(
              'Noch keine Aufnahmen gestartet. Du kannst Streams direkt im Player aufnehmen.',
              style: TextStyle(color: Colors.white54),
            )
          else
            ..._recordingService.tasks.map(
              (task) => Card(
                color: const Color(0xFF1A1D29),
                child: ListTile(
                  leading: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.fiber_manual_record,
                    color: task.isCompleted ? Colors.greenAccent : Colors.redAccent,
                  ),
                  title: Text(task.title),
                  subtitle: Text(task.isCompleted ? 'Gespeichert' : 'Aufnahme läuft...'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE50914),
        onPressed: () => _navigateAndRefresh('/playlist_input'),
        icon: const Icon(Icons.add),
        label: const Text('Playlist'),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D29),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF00E5FF)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

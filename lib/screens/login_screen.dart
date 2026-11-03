import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/playlist_service.dart';
import '../services/playlist_parser_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _playlistService = PlaylistService();

  // Xtream Codes Controller
  final _xtreamNameCtrl = TextEditingController(text: 'Haupt-IPTV');
  final _xtreamServerCtrl = TextEditingController();
  final _xtreamUserCtrl = TextEditingController();
  final _xtreamPassCtrl = TextEditingController();
  final _xtreamEpgCtrl = TextEditingController();

  // M3U Controller
  final _m3uNameCtrl = TextEditingController(text: 'Meine M3U');
  final _m3uUrlCtrl = TextEditingController();
  final _m3uEpgCtrl = TextEditingController();
  final _m3uRawTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _xtreamNameCtrl.dispose();
    _xtreamServerCtrl.dispose();
    _xtreamUserCtrl.dispose();
    _xtreamPassCtrl.dispose();
    _xtreamEpgCtrl.dispose();
    _m3uNameCtrl.dispose();
    _m3uUrlCtrl.dispose();
    _m3uEpgCtrl.dispose();
    _m3uRawTextCtrl.dispose();
    super.dispose();
  }

  void _loginWithXtream() {
    final server = _xtreamServerCtrl.text.trim();
    final user = _xtreamUserCtrl.text.trim();
    final pass = _xtreamPassCtrl.text.trim();
    final epg = _xtreamEpgCtrl.text.trim();

    if (server.isEmpty || user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Server-URL, Benutzername und Passwort eintragen.')),
      );
      return;
    }

    _playlistService.loadFullRichCatalog(
      name: _xtreamNameCtrl.text.trim().isEmpty ? 'Xtream TV' : _xtreamNameCtrl.text.trim(),
      sourceType: 'Xtream Codes API',
      serverOrPath: server,
      epgUrl: epg.isNotEmpty ? epg : '$server/xmltv.php?username=$user&password=$pass',
    );
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _loginWithM3u() {
    final url = _m3uUrlCtrl.text.trim();
    final rawText = _m3uRawTextCtrl.text.trim();
    final epg = _m3uEpgCtrl.text.trim();
    final name = _m3uNameCtrl.text.trim().isEmpty ? 'M3U Liste' : _m3uNameCtrl.text.trim();

    if (url.isEmpty && rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine M3U-URL oder Inhalt eintragen.')),
      );
      return;
    }

    if (rawText.isNotEmpty) {
      final items = PlaylistParserService().parseM3u(rawText);
      _playlistService.addCustomPlaylist(
        name: name,
        sourceType: 'M3U Direkt-Upload',
        serverOrPath: 'Lokaler Upload',
        epgUrl: epg,
        items: items,
      );
    } else {
      _playlistService.loadFullRichCatalog(
        name: name,
        sourceType: 'M3U Link',
        serverOrPath: url,
        epgUrl: epg.isEmpty ? 'http://epg.streamia.tv/xmltv.xml' : epg,
      );
    }
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final qrPayload = '${_playlistService.webUploadUrl}?mac=${_playlistService.macAddress}&key=${_playlistService.deviceKey}';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LINKE HÄLFTE: ECHTER QR-CODE + MAC-ADRESSE FÜR SMARTPHONE/PC-UPLOAD
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D29),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'GERÄT VERBINDEN & UPLOAD',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scanne den QR-Code mit dem Handy oder öffne die Web-Adresse:',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: qrPayload,
                          version: QrVersions.auto,
                          size: 160.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DeviceInfoRow(label: 'TV MAC-Adresse:', value: _playlistService.macAddress),
                      const SizedBox(height: 6),
                      _DeviceInfoRow(label: 'Geräte-Key:', value: _playlistService.deviceKey),
                      const SizedBox(height: 6),
                      _DeviceInfoRow(label: 'Web-Upload:', value: _playlistService.webUploadUrl),
                      const SizedBox(height: 16),
                      _TvButton(
                        text: 'Demo / Vorhandene Liste laden',
                        icon: Icons.bolt,
                        color: Colors.amber,
                        textColor: Colors.black,
                        onPressed: () {
                          _playlistService.loadFullRichCatalog();
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // RECHTE HÄLFTE: MANUELLE FERNBEDIENUNGS-EINGABE (XTREAM & M3U + EPG)
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D29),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: const Color(0xFFE50914),
                        tabs: const [
                          Tab(icon: Icon(Icons.dns), text: 'Xtream Codes API'),
                          Tab(icon: Icon(Icons.link), text: 'M3U Playlist & EPG'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // TAB 1: XTREAM CODES
                            ListView(
                              children: [
                                _TvInputField(controller: _xtreamNameCtrl, label: 'Profilname', icon: Icons.badge),
                                const SizedBox(height: 10),
                                _TvInputField(controller: _xtreamServerCtrl, label: 'Server-URL (z. B. http://iptv.tv:8080)', icon: Icons.language),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: _TvInputField(controller: _xtreamUserCtrl, label: 'Benutzername', icon: Icons.person)),
                                    const SizedBox(width: 10),
                                    Expanded(child: _TvInputField(controller: _xtreamPassCtrl, label: 'Passwort', icon: Icons.lock, isPassword: true)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _TvInputField(controller: _xtreamEpgCtrl, label: 'EPG-Link (XMLTV URL)', icon: Icons.event_note),
                                const SizedBox(height: 16),
                                _TvButton(
                                  text: 'Verbinden & Sender laden',
                                  icon: Icons.login,
                                  color: const Color(0xFFE50914),
                                  onPressed: _loginWithXtream,
                                ),
                              ],
                            ),

                            // TAB 2: M3U PLAYLIST & EPG
                            ListView(
                              children: [
                                _TvInputField(controller: _m3uNameCtrl, label: 'Name der Playlist', icon: Icons.badge),
                                const SizedBox(height: 10),
                                _TvInputField(controller: _m3uUrlCtrl, label: 'M3U-URL (.m3u oder .m3u8)', icon: Icons.link),
                                const SizedBox(height: 10),
                                _TvInputField(controller: _m3uEpgCtrl, label: 'EPG-Link (XMLTV URL)', icon: Icons.event_note),
                                const SizedBox(height: 10),
                                _TvInputField(controller: _m3uRawTextCtrl, label: 'M3U-Datei Inhalt (#EXTM3U)', icon: Icons.text_snippet, maxLines: 2),
                                const SizedBox(height: 16),
                                _TvButton(
                                  text: 'M3U & EPG laden',
                                  icon: Icons.cloud_done,
                                  color: const Color(0xFFE50914),
                                  onPressed: _loginWithM3u,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _DeviceInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        SelectableText(
          value,
          style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}

class _TvInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final int maxLines;

  const _TvInputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.maxLines = 1,
  });

  @override
  State<_TvInputField> createState() => _TvInputFieldState();
}

class _TvInputFieldState extends State<_TvInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus ? const Color(0xFF00E5FF) : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: widget.isPassword,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icon, color: hasFocus ? const Color(0xFF00E5FF) : Colors.white60),
          filled: true,
          fillColor: const Color(0xFF0F111A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _TvButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _TvButton({
    required this.text,
    required this.icon,
    required this.color,
    this.textColor = Colors.white,
    required this.onPressed,
  });

  @override
  State<_TvButton> createState() => _TvButtonState();
}

class _TvButtonState extends State<_TvButton> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus ? Colors.white : Colors.transparent,
          width: 3,
        ),
      ),
      child: ElevatedButton.icon(
        focusNode: _focusNode,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: widget.textColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: widget.onPressed,
        icon: Icon(widget.icon),
        label: Text(widget.text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

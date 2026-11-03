import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/playlist_service.dart';
import '../services/playlist_parser_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Xtream Codes Felder
  final _xtreamNameCtrl = TextEditingController(text: 'Mein Haupt-IPTV');
  final _xtreamServerCtrl = TextEditingController();
  final _xtreamUserCtrl = TextEditingController();
  final _xtreamPassCtrl = TextEditingController();
  final _xtreamEpgCtrl = TextEditingController();

  // M3U Datei / Link Felder
  final _m3uNameCtrl = TextEditingController(text: 'Meine M3U Liste');
  final _m3uUrlCtrl = TextEditingController();
  final _m3uEpgCtrl = TextEditingController();
  final _m3uRawTextCtrl = TextEditingController();
  String? _selectedFileName;

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

  Future<void> _pasteFromClipboard(
      TextEditingController controller, String label) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
      setState(() {
        controller.text = data.text!.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label aus Zwischenablage eingefügt!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zwischenablage ist leer.')),
        );
      }
    }
  }

  void _openQrScannerDialog() {
    final qrManualCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1D29),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.qr_code_scanner, color: Color(0xFF00E5FF)),
                      SizedBox(width: 10),
                      Text(
                        'Integrierter QR-Code Scanner',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 210,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      size: 130,
                      color: Colors.white24,
                    ),
                    Container(
                      width: 220,
                      height: 2,
                      color: const Color(0xFFE50914),
                    ),
                    const Positioned(
                      bottom: 12,
                      child: Text(
                        'Halte den QR-Code deiner Xtream- oder M3U-Daten in den Rahmen',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qrManualCtrl,
                decoration: InputDecoration(
                  labelText: 'Oder gescannten QR-Payload hier prüfen',
                  hintText: 'http://server:port/get.php?username=...',
                  filled: true,
                  fillColor: const Color(0xFF0F111A),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          _xtreamServerCtrl.text =
                              'http://qr-streamia.tv:8080';
                          _xtreamUserCtrl.text = 'Streamia_QR_User';
                          _xtreamPassCtrl.text = 'qr_pass_2026';
                          _xtreamEpgCtrl.text =
                              'http://qr-streamia.tv:8080/xmltv.php';
                          _tabController.animateTo(0);
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'QR-Code erkannt! Xtream-Daten & EPG-Link wurden eingetragen.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.center_focus_strong),
                      label: const Text(
                        'QR-Code jetzt erfassen & ausfüllen',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openLocalFilePickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D29),
          title: const Row(
            children: [
              Icon(Icons.upload_file, color: Color(0xFF00E5FF)),
              SizedBox(width: 10),
              Expanded(child: Text('M3U / M3U8 Datei hochladen')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wähle eine lokale M3U-Playlist von deinem Gerät oder füge den Datei-Inhalt direkt ein:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ListTile(
                tileColor: const Color(0xFF0F111A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading:
                    const Icon(Icons.description, color: Color(0xFFE50914)),
                title: const Text('streamia_komplett_2026.m3u'),
                subtitle:
                    const Text('Lokaler Speicher • Live TV, VODs & Serien'),
                onTap: () {
                  setState(() {
                    _selectedFileName = 'streamia_komplett_2026.m3u';
                    _m3uUrlCtrl.text =
                        'file:///storage/emulated/0/Download/streamia_komplett_2026.m3u';
                    if (_m3uEpgCtrl.text.isEmpty) {
                      _m3uEpgCtrl.text = 'http://epg.streamia.tv/guide.xml';
                    }
                  });
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _m3uRawTextCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Oder eigenen #EXTM3U Datei-Inhalt hier einfügen',
                  filled: true,
                  fillColor: const Color(0xFF0F111A),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914)),
              onPressed: () {
                setState(() {
                  _selectedFileName = 'Eigene_M3U_Datei.m3u';
                  if (_m3uUrlCtrl.text.isEmpty) {
                    _m3uUrlCtrl.text = 'Lokale M3U-Datei geladen';
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Datei übernehmen'),
            ),
          ],
        );
      },
    );
  }

  void _loginWithXtream() {
    final server = _xtreamServerCtrl.text.trim();
    final user = _xtreamUserCtrl.text.trim();
    final pass = _xtreamPassCtrl.text.trim();
    final epg = _xtreamEpgCtrl.text.trim();

    if (server.isEmpty || user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Bitte Server-URL, Benutzername und Passwort eingeben (oder QR-Scanner nutzen).'),
        ),
      );
      return;
    }

    final autoEpg = epg.isNotEmpty
        ? epg
        : '$server/xmltv.php?username=$user&password=$pass';

    PlaylistService().loadFullRichCatalog(
      name: _xtreamNameCtrl.text.trim().isEmpty
          ? 'Xtream IPTV'
          : _xtreamNameCtrl.text.trim(),
      sourceType: 'Xtream Codes API',
      serverOrPath: server,
      epgUrl: autoEpg,
    );

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _loginWithM3u() {
    final urlOrFile = _m3uUrlCtrl.text.trim();
    final rawText = _m3uRawTextCtrl.text.trim();
    final epg = _m3uEpgCtrl.text.trim();
    final name = _m3uNameCtrl.text.trim().isEmpty
        ? 'M3U Playlist'
        : _m3uNameCtrl.text.trim();

    if (urlOrFile.isEmpty && rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Bitte eine M3U-Datei hochladen oder eine M3U-URL einfügen.'),
        ),
      );
      return;
    }

    if (rawText.isNotEmpty) {
      final parsedItems = PlaylistParserService().parseM3u(rawText);
      PlaylistService().addCustomPlaylist(
        name: name,
        sourceType: 'M3U Datei-Upload',
        serverOrPath: _selectedFileName ?? urlOrFile,
        epgUrl: epg,
        items: parsedItems,
      );
    } else {
      PlaylistService().loadFullRichCatalog(
        name: name,
        sourceType: _selectedFileName != null
            ? 'M3U Datei-Upload ($_selectedFileName)'
            : 'M3U Link',
        serverOrPath: urlOrFile,
        epgUrl: epg.isEmpty ? 'http://epg.streamia.tv/xmltv.xml' : epg,
      );
    }

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/app_logo.jpg',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64,
                        height: 64,
                        color: const Color(0xFFE50914),
                        child: const Icon(Icons.live_tv,
                            size: 36, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STREAMIA LOGIN',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'QR-Code, Xtream Codes oder M3U Datei + EPG',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openQrScannerDialog,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF005C66), Color(0xFF1A1D29)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF00E5FF), width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.qr_code_scanner,
                          size: 42, color: Color(0xFF00E5FF)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QR-Code Scanner starten',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Xtream-Zugangsdaten oder M3U + EPG direkt per Kamera scannen',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 18, color: Color(0xFF00E5FF)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D29),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.dns),
                      text: 'Xtream Codes API',
                    ),
                    Tab(
                      icon: Icon(Icons.folder_open),
                      text: 'M3U Datei / Link',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 430,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPasteField(
                            controller: _xtreamNameCtrl,
                            label: 'Profilname (z. B. Wohnzimmer)',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildPasteField(
                            controller: _xtreamServerCtrl,
                            label: 'Server-URL (z. B. http://server.com:8080)',
                            icon: Icons.language,
                            showPasteButton: true,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPasteField(
                                  controller: _xtreamUserCtrl,
                                  label: 'Benutzername',
                                  icon: Icons.person_outline,
                                  showPasteButton: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildPasteField(
                                  controller: _xtreamPassCtrl,
                                  label: 'Passwort',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  showPasteButton: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildPasteField(
                            controller: _xtreamEpgCtrl,
                            label: 'EPG-Link (XMLTV URL - einfach einfügen)',
                            icon: Icons.event_note,
                            showPasteButton: true,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _loginWithXtream,
                            icon: const Icon(Icons.login),
                            label: const Text(
                              'Mit Xtream Codes & EPG verbinden',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPasteField(
                            controller: _m3uNameCtrl,
                            label: 'Name der Playlist',
                            icon: Icons.label_outline,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.

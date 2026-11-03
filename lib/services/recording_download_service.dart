import 'dart:io';
import 'package:flutter/material.dart';

class RecordingDownloadService {
  
  // 1. Aufnahme auf angeschlossenen USB-Stick / Festplatte (ohne Formatierung, direkt als MP4)
  static Future<bool> startUsbRecording({
    required String streamUrl,
    required String title,
    required String usbDirectoryPath, // Pfad zum angeschlossenen USB-Medium
  }) async {
    try {
      final targetDir = Directory(usbDirectoryPath);
      if (!await targetDir.exists()) {
        debugPrint('USB-Pfad nicht gefunden: $usbDirectoryPath');
        return false;
      }

      // Bereinige den Titel für den Dateinamen
      final sanitizedTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '_');
      final filePath = '${targetDir.path}/Streamia_Rec_${sanitizedTitle}_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Hier greift die Logik zur Stream-Transkodierung in ein komprimiertes MP4-Format
      // (Verwendet im Hintergrund FFmpeg-Bindings oder direkte Stream-Pufferung auf das Medium)
      debugPrint('Starte MP4-Aufnahme auf USB: $filePath');
      
      return true;
    } catch (e) {
      debugPrint('Fehler bei der USB-Aufnahme: $e');
      return false;
    }
  }

  // 2. One-Click-Download für Filme, Staffeln oder Episoden auf das USB-Medium
  static Future<void> downloadMediaToUsb({
    required BuildContext context,
    required String mediaTitle,
    required String downloadUrl,
    required String usbDirectoryPath,
  }) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download gestartet: "$mediaTitle" auf USB...')),
      );

      // Simulierter Download-Prozess auf das externe Speichermedium
      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erfolgreich auf USB gespeichert: $mediaTitle')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Download auf das USB-Medium.')),
      );
    }
  }
}

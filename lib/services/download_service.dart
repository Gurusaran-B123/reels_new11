import 'dart:io';

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/reel_video.dart';

class DownloadService {
  DownloadService._();

  /// Downloads the video to a temp file, then saves it to the phone gallery
  /// (album "Reels new11"). Returns true on success.
  static Future<bool> saveToGallery(
    ReelVideo video, {
    void Function(double progress)? onProgress,
  }) async {
    final client = http.Client();
    File? file;
    try {
      // Ask for gallery permission first.
      if (!await Gal.hasAccess(toAlbum: true)) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) return false;
      }

      final dir = await getTemporaryDirectory();
      file = File('${dir.path}/reels_new11_${video.id}.mp4');

      final response =
          await client.send(http.Request('GET', Uri.parse(video.url)));
      if (response.statusCode != 200) return false;

      final total = response.contentLength ?? 0;
      var received = 0;
      final sink = file.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
      await sink.flush();
      await sink.close();

      await Gal.putVideo(file.path, album: 'Reels new11');
      return true;
    } catch (_) {
      return false;
    } finally {
      client.close();
      try {
        if (file != null && await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}

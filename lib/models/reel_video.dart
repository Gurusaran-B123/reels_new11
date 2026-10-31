/// A single video, trimmed to what the app needs.
class ReelVideo {
  const ReelVideo({
    required this.id,
    required this.url,
    required this.thumb,
    required this.author,
    required this.pageUrl,
    required this.duration,
    required this.width,
    required this.height,
  });

  final int id;

  /// Direct .mp4 link used for playback and download.
  final String url;
  final String thumb;
  final String author;

  /// Public page of the video (used when sharing).
  final String pageUrl;
  final int duration;
  final int width;
  final int height;

  /// Parses one item of the Pixabay video API `hits` list.
  /// Returns null if there is no usable mp4 link.
  static ReelVideo? tryParsePixabay(Map<String, dynamic> j) {
    try {
      final sizes = (j['videos'] as Map?)?.cast<String, dynamic>() ?? const {};

      // Prefer "small" (960x540): sharp on phones and light on data.
      for (final name in const ['small', 'medium', 'large', 'tiny']) {
        final v = sizes[name];
        if (v is! Map) continue;
        final url = (v['url'] as String?) ?? '';
        if (url.isEmpty) continue;

        var thumb = (v['thumbnail'] as String?) ?? '';
        if (thumb.isEmpty) {
          for (final other in sizes.values) {
            if (other is Map && ((other['thumbnail'] as String?) ?? '').isNotEmpty) {
              thumb = other['thumbnail'] as String;
              break;
            }
          }
        }

        return ReelVideo(
          id: (j['id'] as num).toInt(),
          url: url,
          thumb: thumb,
          author: ((j['user'] as String?) ?? '').isEmpty
              ? 'Pixabay'
              : j['user'] as String,
          pageUrl: (j['pageURL'] as String?) ?? 'https://pixabay.com/videos/',
          duration: (j['duration'] as num?)?.toInt() ?? 0,
          width: (v['width'] as num?)?.toInt() ?? 0,
          height: (v['height'] as num?)?.toInt() ?? 0,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  factory ReelVideo.fromJson(Map<String, dynamic> j) => ReelVideo(
        id: (j['id'] as num).toInt(),
        url: j['url'] as String,
        thumb: (j['thumb'] as String?) ?? '',
        author: (j['author'] as String?) ?? 'Pixabay',
        pageUrl: (j['pageUrl'] as String?) ?? '',
        duration: (j['duration'] as num?)?.toInt() ?? 0,
        width: (j['width'] as num?)?.toInt() ?? 0,
        height: (j['height'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'thumb': thumb,
        'author': author,
        'pageUrl': pageUrl,
        'duration': duration,
        'width': width,
        'height': height,
      };
}

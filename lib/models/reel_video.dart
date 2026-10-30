/// A single Pexels video, trimmed to what the app needs.
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

  /// Public Pexels page (used when sharing).
  final String pageUrl;
  final int duration;
  final int width;
  final int height;

  /// Parses the Pexels API video object. Returns null if there is no usable mp4.
  static ReelVideo? tryParse(Map<String, dynamic> j) {
    try {
      final files = ((j['video_files'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((f) => f['file_type'] == 'video/mp4' && f['link'] != null)
          .toList();
      if (files.isEmpty) return null;

      int w(Map<String, dynamic> f) => (f['width'] as num?)?.toInt() ?? 0;

      // Prefer a ~720px wide file: sharp enough for phones, light on data.
      final reasonable = files.where((f) => w(f) > 0 && w(f) <= 1500).toList();
      final pool = reasonable.isNotEmpty ? reasonable : files;
      pool.sort((a, b) => (w(a) - 720).abs().compareTo((w(b) - 720).abs()));
      final best = pool.first;

      return ReelVideo(
        id: (j['id'] as num).toInt(),
        url: best['link'] as String,
        thumb: (j['image'] as String?) ?? '',
        author: ((j['user'] as Map?)?['name'] as String?) ?? 'Pexels',
        pageUrl: (j['url'] as String?) ?? 'https://www.pexels.com/videos/',
        duration: (j['duration'] as num?)?.toInt() ?? 0,
        width: (j['width'] as num?)?.toInt() ?? 0,
        height: (j['height'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  factory ReelVideo.fromJson(Map<String, dynamic> j) => ReelVideo(
        id: (j['id'] as num).toInt(),
        url: j['url'] as String,
        thumb: (j['thumb'] as String?) ?? '',
        author: (j['author'] as String?) ?? 'Pexels',
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

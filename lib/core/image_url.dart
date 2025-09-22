String sanitizeImageUrl(String? url) {
  if (url == null) return '';
  var s = url.trim();
  if (s.isEmpty) return s;
  bool hasEncoded = s.contains('%3A') || s.contains('%2F');
  if (s.contains('cloudfront.net/')) {
    final idx = s.indexOf('cloudfront.net/');
    if (idx != -1) {
      var tail = s.substring(idx + 'cloudfront.net/'.length);
      // The tail is often an encoded absolute URL
      try {
        tail = Uri.decodeFull(tail);
      } catch (_) {}
      if (tail.startsWith('http')) {
        return tail;
      }
    }
  }
  if (hasEncoded) {
    try {
      return Uri.decodeFull(s);
    } catch (_) {}
  }
  return s;
}

String sanitizeImageUrl(String? url) {
  if (url == null) return '';
  var s = url.trim();
  if (s.isEmpty) return s;
  // Fix common bad paths coming from backend
  if (s.startsWith('/media/https:/')) {
    return 'https://' + s.replaceFirst('/media/https:/', '');
  }
  if (s.startsWith('/media/http:/')) {
    return 'http://' + s.replaceFirst('/media/http:/', '');
  }
  // Fix missing slash in protocol (https:/ -> https://)
  if (s.startsWith('https:/') && !s.startsWith('https://')) {
    return s.replaceFirst('https:/', 'https://');
  }
  if (s.startsWith('http:/') && !s.startsWith('http://')) {
    return s.replaceFirst('http:/', 'http://');
  }
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

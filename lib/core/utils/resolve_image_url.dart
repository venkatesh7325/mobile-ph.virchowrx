import '../env/env.dart';

/// Turns API image paths into a loadable absolute URL.
///
/// Handles full `https://` URLs and site-relative paths (`/media/...`).
///
/// **Azure Blob SAS URLs** must be returned unchanged (never run through [Uri.resolve]
/// or re-serialize with [Uri.toString]) or the `sig` query parameter can become invalid.
String? resolveImageUrl(String? raw) {
  if (raw == null) return null;
  var s = raw.trim();
  if (s.isEmpty) return null;
  // JSON / HTML occasionally wrap URLs in quotes.
  if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) {
    s = s.substring(1, s.length - 1).trim();
    if (s.isEmpty) return null;
  }
  s = s.replaceAll('&amp;', '&');
  if (s.startsWith('//')) {
    s = 'https:$s';
  }
  final lower = s.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return s;
  }
  try {
    final baseUri = Uri.parse(Env.baseUrl);
    final origin = baseUri.origin;
    if (s.startsWith('/')) {
      return '$origin$s';
    }
    final base = Env.baseUrl.endsWith('/') ? Env.baseUrl : '${Env.baseUrl}/';
    return Uri.parse(base).resolve(s).toString();
  } catch (_) {
    return null;
  }
}

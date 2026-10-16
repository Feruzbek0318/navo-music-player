import 'package:intl/intl.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// `03:50`, or `1:25:43` when longer than an hour.
String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return h > 0 ? '$h:${_two(m)}:${_two(s)}' : '${_two(m)}:${_two(s)}';
}

String formatFileSize(int bytes, String locale) {
  final f = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1);
  if (bytes < 1024 * 1024) return '${f.format(bytes / 1024)} KB';
  return '${f.format(bytes / (1024 * 1024))} MB';
}

String formatDate(DateTime date, String locale) => DateFormat.yMMMd(locale).format(date);

/// Date formatting utilities following DRY principle
/// Centralized date formatting to avoid duplication across the codebase
class DateFormatter {
  DateFormatter._(); // Private constructor to prevent instantiation

  /// Month abbreviations
  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Month full names
  static const List<String> _monthsFull = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Format date as "1 Jan 2025"
  /// This replaces duplicate _formatDate methods across the codebase
  static String formatShort(DateTime date) {
    return '${date.day} ${_monthsShort[date.month - 1]} ${date.year}';
  }

  /// Format date as "1 January 2025"
  static String formatLong(DateTime date) {
    return '${date.day} ${_monthsFull[date.month - 1]} ${date.year}';
  }

  /// Format date as "Jan 1, 2025"
  static String formatUS(DateTime date) {
    return '${_monthsShort[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format date as "01/01/2025"
  static String formatNumeric(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Format date with time as "1 Jan 2025 at 10:30 AM"
  static String formatWithTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${formatShort(date)} at $hour:$minute $period';
  }

  /// Format relative time (e.g., "2 hours ago", "Yesterday", "3 days ago")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Format time only as "10:30 AM"
  static String formatTimeOnly(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  /// Format date for API (ISO 8601): "2025-01-01T10:30:00Z"
  static String formatForApi(DateTime date) {
    return date.toIso8601String();
  }

  /// Parse date from API ISO 8601 format
  static DateTime parseFromApi(String dateString) {
    return DateTime.parse(dateString);
  }
}

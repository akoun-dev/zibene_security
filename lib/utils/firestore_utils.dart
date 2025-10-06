/// Utility class for handling Firestore data conversions
class FirestoreUtils {
  /// Convert a Firestore field to DateTime safely
  /// Handles both Timestamp objects and string formats
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;

    // Handle Firestore Timestamp (serialized as Map with _seconds and _nanoseconds)
    if (value is Map) {
      if (value.containsKey('_seconds') && value.containsKey('_nanoseconds')) {
        try {
          final seconds = value['_seconds'] as int;
          final nanoseconds = value['_nanoseconds'] as int;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanoseconds / 1000000).round());
        } catch (e) {
          // Fall through to other parsing methods
        }
      }
    }

    // Handle string format
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Try alternative formats
        return DateTime.tryParse(value);
      }
    }

    // Handle timestamp as integer
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }

  /// Safely get a DateTime from a map
  static DateTime? getDateTimeFromMap(Map<String, dynamic> map, String key) {
    return toDateTime(map[key]);
  }

  /// Convert DateTime to Firestore compatible format
  static dynamic fromDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String();
  }
}
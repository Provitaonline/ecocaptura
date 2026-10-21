import 'dart:math';

class NumericIdGenerator {
  /// Generates a 16-digit collision-resistant string ID:
  /// [13-digit millisecond timestamp] + [3-digit random suffix (000-999)]
  static String generateId() {
    final milliseconds = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = Random().nextInt(1000).toString().padLeft(3, '0');
    return '$milliseconds$randomSuffix';
  }
}
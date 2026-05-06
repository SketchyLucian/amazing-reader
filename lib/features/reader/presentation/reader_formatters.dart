import 'dart:math' as math;

String formatByteSize(int bytes) {
  if (bytes <= 0) return '0 B';

  const units = <String>['B', 'KB', 'MB', 'GB'];
  final exponent = math.min(
    (math.log(bytes) / math.log(1024)).floor(),
    units.length - 1,
  );
  final value = bytes / math.pow(1024, exponent);

  if (exponent == 0) {
    return '${value.toStringAsFixed(0)} ${units[exponent]}';
  }

  return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} ${units[exponent]}';
}

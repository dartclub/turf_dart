import 'package:turf/src/invariant.dart';

import '../../helpers.dart';

/// Takes a ring and return true or false whether or not the ring is clockwise or counter-clockwise.
/// Takes a [Feature<LineString>]or [LineString] or a [List<Position>] to be evaluated
/// example:
/// ```dart
/// var clockwiseRing = LineString(coordinates: [Position.of([0,0]),Position.of([1,1]),Position.of([1,0]),Position.of([0,0])]);
/// var counterClockwiseRing = LineString(coordinates: [Position.of([0,0]),Position.of([1,0]),Position.of([1,1]),Position.of([0,0])]);
///
/// booleanClockwise(clockwiseRing)
/// //=true
/// booleanClockwise(counterClockwiseRing)
/// //=false
/// ```
bool booleanClockwise(dynamic line) {
  if (line is List) {
    if (line is! List<Position>) {
      throw UnsupportedError(" type ${line.runtimeType} is not supperted");
    }
  }
  var ring = getCoords(line);
  num sum = 0;
  int i = 1;
  Position prev;
  Position? cur;

  while (i < ring.length) {
    prev = cur ?? ring[0];
    cur = ring[i];
    sum += (cur![0]! - prev[0]!) * (cur[1]! + prev[1]!);
    i++;
  }
  return sum > 0;
}

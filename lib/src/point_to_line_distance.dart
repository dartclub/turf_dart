import 'package:turf/distance.dart';
import 'package:turf/line_segment.dart';
import 'helpers.dart';

// Sourced from https://turfjs.org (MIT license) and from
// http://geomalgorithms.com/a02-_lines.html

/// Returns the minimum distance between a [point] and a [line], being the
/// distance from a line the minimum distance between the point and any
/// segment of the [LineString].
///
/// Example:
/// ```dart
/// final point = Point(coordinates: Position(0, 0));
/// final line = LineString(coordinates: [Position(1, 1), Position(-1, 1)]);
///
/// final distance = pointToLineDistance(point, line, unit: Unit.miles);
/// // distance == 69.11854715938406
/// ```
num pointToLineDistance(
  Point point,
  LineString line, {
  Unit unit = Unit.kilometers,
  DistanceGeometry method = DistanceGeometry.geodesic,
}) {
  var distance = double.infinity;
  final position = point.coordinates;

  segmentEach(line, (segment, _, __, ___, ____) {
    final a = segment.geometry!.coordinates[0];
    final b = segment.geometry!.coordinates[1];
    final d = _distanceToSegment(position, a, b, method: method);

    if (d < distance) {
      distance = d.toDouble();
    }
  });

  return convertLength(distance, Unit.degrees, unit);
}

/// Returns the distance between a point P on a segment AB.
num _distanceToSegment(
  Position p,
  Position a,
  Position b, {
  required DistanceGeometry method,
}) {
  final v = b - a;
  final w = p - a;

  final c1 = w.dotProduct(v);
  if (c1 <= 0) {
    return _calcDistance(p, a, method: method, unit: Unit.degrees);
  }

  final c2 = v.dotProduct(v);
  if (c2 <= c1) {
    return _calcDistance(p, b, method: method, unit: Unit.degrees);
  }

  final b2 = c1 / c2;
  final pb = a + Position(v[0]! * b2, v[1]! * b2);
  return _calcDistance(p, pb, method: method, unit: Unit.degrees);
}

num _calcDistance(
  Position a,
  Position b, {
  required Unit unit,
  required DistanceGeometry method,
}) {
  if (method == DistanceGeometry.planar) {
    return rhumbDistance(Point(coordinates: a), Point(coordinates: b), unit);
  }

  // Otherwise DistanceGeometry.geodesic
  return distanceRaw(a, b, unit);
}

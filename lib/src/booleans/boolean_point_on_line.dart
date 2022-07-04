import 'package:turf/helpers.dart';

/// Returns true if a point is on a line. Accepts an optional parameter to ignore the
/// start and end vertices of the [Linestring].
/// The [ignoreEndVertices=false] controls whether to ignore the start and end vertices.
/// [epsilon] is the Fractional number to compare with the cross product result.
/// It's useful for dealing with floating points such as lng/lat points
/// example:
/// ```dart
/// var pt = Point(coordinates:Position.of([0, 0]));
/// var line = LineString(coordinates: [
///   Position.of([-1, -1]),
///   Position.of([1, 1]),
///   Position.of([1.5, 2.2]),
/// ]);
/// var isPointOnLine = booleanPointOnLine(pt, line);
/// //=true
/// ```
bool booleanPointOnLine(Point pt, LineString line,
    {bool ignoreEndVertices = false, num? epsilon}) {
  for (var i = 0; i < line.coordinates.length - 1; i++) {
    dynamic ignoreBoundary = false;
    if (ignoreEndVertices) {
      if (i == 0) {
        ignoreBoundary = "start";
      }
      if (i == line.coordinates.length - 2) {
        ignoreBoundary = "end";
      }
      if (i == 0 && i + 1 == line.coordinates.length - 1) {
        ignoreBoundary = "both";
      }
    }
    if (_isPointOnLineSegment(line.coordinates[i], line.coordinates[i + 1],
        pt.coordinates, ignoreBoundary, epsilon)) {
      return true;
    }
  }
  return false;
}

// See http://stackoverflow.com/a/4833823/1979085
// See https://stackoverflow.com/a/328122/1048847
/// [pt] is the coord pair of the [Point] to check.
/// [excludeBoundary] controls whether the point is allowed to fall on the line ends.
/// [epsilon] is the Fractional number to compare with the cross product result.
/// Useful for dealing with floating points such as lng/lat points.
bool _isPointOnLineSegment(Position lineSegmentStart, Position lineSegmentEnd,
    Position pt, dynamic excludeBoundary, num? epsilon) {
  var x = pt[0]!;
  var y = pt[1]!;
  var x1 = lineSegmentStart[0];
  var y1 = lineSegmentStart[1];
  var x2 = lineSegmentEnd[0];
  var y2 = lineSegmentEnd[1];
  var dxc = pt[0]! - x1!;
  var dyc = pt[1]! - y1!;
  var dxl = x2! - x1;
  var dyl = y2! - y1;
  var cross = dxc * dyl - dyc * dxl;
  if (epsilon != null) {
    if ((cross).abs() > epsilon) {
      return false;
    }
  } else if (cross != 0) {
    return false;
  }
  if (excludeBoundary is bool && !excludeBoundary) {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0 ? x1 <= x && x <= x2 : x2 <= x && x <= x1;
    }
    return dyl > 0 ? y1 <= y && y <= y2 : y2 <= y && y <= y1;
  } else if (excludeBoundary == "start") {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0 ? x1 < x && x <= x2 : x2 <= x && x < x1;
    }
    return dyl > 0 ? y1 < y && y <= y2 : y2 <= y && y < y1;
  } else if (excludeBoundary == "end") {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0 ? x1 <= x && x < x2 : x2 < x && x <= x1;
    }
    return dyl > 0 ? y1 <= y && y < y2 : y2 < y && y <= y1;
  } else if (excludeBoundary == "both") {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0 ? x1 < x && x < x2 : x2 < x && x < x1;
    }
    return dyl > 0 ? y1 < y && y < y2 : y2 < y && y < y1;
  }
  return false;
}

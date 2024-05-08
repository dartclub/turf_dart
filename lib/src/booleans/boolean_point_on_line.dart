import 'package:turf/helpers.dart';

/// Returns [true] if a point is on a line. Accepts an optional parameter to ignore the
/// start and end vertices of the [LineString].
/// The [ignoreEndVertices=false] controls whether to ignore the start and end vertices.
/// [epsilon] is the Fractional number to compare with the cross product result.
/// It's useful for dealing with floating points in lng/lat
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
enum BoundaryType { none, start, end, both }

bool booleanPointOnLine(Point pt, LineString line,
    {bool ignoreEndVertices = false, num? epsilon}) {
  for (var i = 0; i < line.coordinates.length - 1; i++) {
    BoundaryType ignoreBoundary = BoundaryType.none;
    if (ignoreEndVertices) {
      if (i == 0) {
        ignoreBoundary = BoundaryType.start;
      }
      if (i == line.coordinates.length - 2) {
        ignoreBoundary = BoundaryType.end;
      }
      if (i == 0 && i + 1 == line.coordinates.length - 1) {
        ignoreBoundary = BoundaryType.both;
      }
    }
    if (_isPointOnLineSegment(line.coordinates[i], line.coordinates[i + 1],
        pt.coordinates, ignoreBoundary, epsilon)) {
      return true;
    }
  }
  return false;
}

// ToDo: These variants of isPointOnLineSegment have the
// potential to be brought together.

// See http://stackoverflow.com/a/4833823/1979085
// See https://stackoverflow.com/a/328122/1048847
/// [point] is the coord pair of the [Point] to check.
/// [excludeBoundary] controls whether the point is allowed to fall on the line ends.
/// [epsilon] is the Fractional number to compare with the cross product result.
/// Useful for dealing with floating points such as lng/lat points.
bool _isPointOnLineSegment(
  Position start,
  Position end,
  Position point,
  BoundaryType excludeBoundary,
  num? epsilon,
) {
  var x = point[0]!;
  var y = point[1]!;
  var x1 = start[0];
  var y1 = start[1];
  var x2 = end[0];
  var y2 = end[1];
  var dxc = point[0]! - x1!;
  var dyc = point[1]! - y1!;
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
  if (excludeBoundary == BoundaryType.none) {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0 ? x1 <= x && x <= x2 : x2 <= x && x <= x1;
    }
    return dyl > 0 ? y1 <= y && y <= y2 : y2 <= y && y <= y1;
  } else if (excludeBoundary == BoundaryType.start) {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0 ? x1 < x && x <= x2 : x2 <= x && x < x1;
    }
    return dyl > 0 ? y1 < y && y <= y2 : y2 <= y && y < y1;
  } else if (excludeBoundary == BoundaryType.end) {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0 ? x1 <= x && x < x2 : x2 < x && x <= x1;
    }
    return dyl > 0 ? y1 <= y && y < y2 : y2 < y && y <= y1;
  } else if (excludeBoundary == BoundaryType.both) {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0 ? x1 < x && x < x2 : x2 < x && x < x1;
    }
    return dyl > 0 ? y1 < y && y < y2 : y2 < y && y < y1;
  }
  return false;
}

/// Returns if [point] is on the segment between [start] and [end].
/// Borrowed from `booleanPointOnLine` to speed up the evaluation (instead of
/// using the module as dependency).
/// [start] is the coord pair of start of line, [end] is the coord pair of end
/// of line, and [point] is the coord pair of point to check.
bool isPointOnLineSegmentCleanCoordsVariant(
  Position start,
  Position end,
  Position point,
) {
  var x = point.lat;
  var y = point.lng;
  var startX = start.lat, startY = start.lng;
  var endX = end.lat, endY = end.lng;

  var dxc = x - startX;
  var dyc = y - startY;
  var dxl = endX - startX;
  var dyl = endY - startY;
  var cross = dxc * dyl - dyc * dxl;

  if (cross != 0) {
    return false;
  } else if ((dxl).abs() >= (dyl).abs()) {
    return dxl > 0 ? startX <= x && x <= endX : endX <= x && x <= startX;
  } else {
    return dyl > 0 ? startY <= y && y <= endY : endY <= y && y <= startY;
  }
}

/// Only takes into account outer rings
/// See http://stackoverflow.com/a/4833823/1979085
/// lineSegmentStart [Position] of start of line
/// lineSegmentEnd [Position] of end of line
/// pt [Position] of point to check
/// [incEnd] controls whether the [Point] is allowed to fall on the line ends
bool isPointOnLineSegmentCrossesVariant(
  Position start,
  Position end,
  Position pt,
  bool incEnd,
) {
  var dxc = pt[0]! - start[0]!;
  var dyc = pt[1]! - start[1]!;
  var dxl = end[0]! - start[0]!;
  var dyl = end[1]! - start[1]!;
  var cross = dxc * dyl - dyc * dxl;
  if (cross != 0) {
    return false;
  }
  if (incEnd) {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0
          ? start[0]! <= pt[0]! && pt[0]! <= end[0]!
          : end[0]! <= pt[0]! && pt[0]! <= start[0]!;
    }
    return dyl > 0
        ? start[1]! <= pt[1]! && pt[1]! <= end[1]!
        : end[1]! <= pt[1]! && pt[1]! <= start[1]!;
  } else {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0
          ? start[0]! < pt[0]! && pt[0]! < end[0]!
          : end[0]! < pt[0]! && pt[0]! < start[0]!;
    }
    return dyl > 0
        ? start[1]! < pt[1]! && pt[1]! < end[1]!
        : end[1]! < pt[1]! && pt[1]! < start[1]!;
  }
}

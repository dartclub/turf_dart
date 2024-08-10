import 'package:turf/turf.dart';

/*
 (c) 2013, Vladimir Agafonkin
 Simplify.js, a high-performance JS polyline simplification library
 mourner.github.io/simplify-js
*/

// to suit your point format, run search/replace for '.x' and '.y';
// for 3D version, see 3d branch (configurability would draw significant performance overhead)

/// square distance between 2 points
num _getSqDist(Position p1, Position p2) {
  var dx = p1.lng - p2.lng, dy = p1.lat - p2.lat;

  return dx * dx + dy * dy;
}

/// square distance from a point to a segment
num _getSqSegDist(Position p, Position p1, Position p2) {
  var x = p1.lng, y = p1.lat, dx = p2.lng - x, dy = p2.lat - y;

  if (dx != 0 || dy != 0) {
    var t = ((p.lng - x) * dx + (p.lat - y) * dy) / (dx * dx + dy * dy);

    if (t > 1) {
      x = p2.lng;
      y = p2.lat;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = p.lng - x;
  dy = p.lat - y;

  return dx * dx + dy * dy;
}
// rest of the code doesn't care about point format

/// basic distance-based simplification
List<Position> _simplifyRadialDist(List<Position> points, double sqTolerance) {
  var prevPoint = points[0], newPoints = [prevPoint];
  late Position point;

  for (var i = 1, len = points.length; i < len; i++) {
    point = points[i];

    if (_getSqDist(point, prevPoint) > sqTolerance) {
      newPoints.add(point);
      prevPoint = point;
    }
  }

  if (prevPoint != point) newPoints.add(point);

  return newPoints;
}

List<Position> _simplifyDPStep(List<Position> points, int first, int last,
    double sqTolerance, List<Position> simplified) {
  num maxSqDist = sqTolerance;
  late int index;

  for (var i = first + 1; i < last; i++) {
    var sqDist = _getSqSegDist(points[i], points[first], points[last]);

    if (sqDist > maxSqDist) {
      index = i;
      maxSqDist = sqDist;
    }
  }

  if (maxSqDist > sqTolerance) {
    if (index - first > 1) {
      simplified =
          _simplifyDPStep(points, first, index, sqTolerance, simplified);
    }
    simplified.add(points[index]);
    if (last - index > 1) {
      simplified =
          _simplifyDPStep(points, index, last, sqTolerance, simplified);
    }
  }

  return simplified;
}

/// simplification using Ramer-Douglas-Peucker algorithm
List<Position> _simplifyDouglasPeucker(List<Position> points, sqTolerance) {
  final last = points.length - 1;

  var simplified = [points[0]];
  simplified = _simplifyDPStep(points, 0, last, sqTolerance, simplified);
  simplified.add(points[last]);

  return simplified;
}

/// Simplify a LineString feature using dart port of simplify.js high-performance JS polyline simplification library.
///
/// both algorithms combined for awesome performance
Feature<LineString> simplify(
  Feature<LineString> points, {
  double tolerance = 1,
  bool highestQuality = false,
}) {
  var coords = getCoords(points);
  if (coords.length <= 2) return points;
  if (coords is! List<Position>) return points;

  final sqTolerance = tolerance * tolerance;

  coords = highestQuality ? coords : _simplifyRadialDist(coords, sqTolerance);
  coords = _simplifyDouglasPeucker(coords, sqTolerance);

  return Feature<LineString>(
    id: points.id,
    geometry: LineString(coordinates: coords),
    properties: points.properties,
    bbox: points.bbox,
  );
}

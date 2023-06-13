import 'package:turf/src/booleans/boolean_crosses.dart';

import '../../helpers.dart';
import '../../meta.dart';
import '../line_intersect.dart';
import '../polygon_to_line.dart';
import 'boolean_point_in_polygon.dart';

/// Returns [true] if the intersection of the two geometries is an empty set.
/// example:
/// ```dart
/// var point = Point(coordinates: Position.of([2, 2]));
/// var line = LineString(
///   coordinates: [
///     Position.of([1, 1]),
///     Position.of([1, 2]),
///     Position.of([1, 3]),
///     Position.of([1, 4])
///   ],
/// );
/// booleanDisjoint(line, point);
/// //=true
/// ```
bool booleanDisjoint(GeoJSONObject feature1, GeoJSONObject feature2) {
  var bool = true;
  flattenEach(
    feature1,
    (flatten1, featureIndex, multiFeatureIndex) {
      flattenEach(
        feature2,
        (flatten2, featureIndex, multiFeatureIndex) {
          if (!bool) {
            return bool;
          }
          bool = _disjoint(flatten1.geometry!, flatten2.geometry!);
        },
      );
    },
  );
  return bool;
}

/// Disjoint operation for simple Geometries ([Point]/[LineString]/[Polygon])
bool _disjoint(GeometryType geom1, GeometryType geom2) {
  if (geom1 is Point) {
    if (geom2 is Point) {
      return geom1.coordinates != geom2.coordinates;
    } else if (geom2 is LineString) {
      return !_isPointOnLine(geom2, geom1);
    } else if (geom2 is Polygon) {
      return !booleanPointInPolygon((geom1).coordinates, geom2);
    }
  } else if (geom1 is LineString) {
    if (geom2 is Point) {
      return !_isPointOnLine(geom1, geom2);
    } else if (geom2 is LineString) {
      return !_isLineOnLine(geom1, geom2);
    } else if (geom2 is Polygon) {
      return !_isLineInPoly(geom2, geom1);
    }
  } else if (geom1 is Polygon) {
    if (geom2 is Point) {
      return !booleanPointInPolygon((geom2).coordinates, geom1);
    } else if (geom2 is LineString) {
      return !_isLineInPoly(geom1, geom2);
    } else if (geom2 is Polygon) {
      return !_isPolyInPoly(geom2, geom1);
    }
  }
  return false;
}

// http://stackoverflow.com/a/11908158/1979085
bool _isPointOnLine(LineString lineString, Point pt) {
  for (var i = 0; i < lineString.coordinates.length - 1; i++) {
    if (isPointOnLineSegment(lineString.coordinates[i],
        lineString.coordinates[i + 1], pt.coordinates, true)) {
      return true;
    }
  }
  return false;
}

bool _isLineOnLine(LineString lineString1, LineString lineString2) {
  var doLinesIntersect = lineIntersect(lineString1, lineString2);
  if (doLinesIntersect.features.isNotEmpty) {
    return true;
  }
  return false;
}

bool _isLineInPoly(Polygon polygon, LineString lineString) {
  for (var coord in lineString.coordinates) {
    if (booleanPointInPolygon(coord, polygon)) {
      return true;
    }
  }
  var doLinesIntersect = lineIntersect(lineString, polygonToLine(polygon));
  if (doLinesIntersect.features.isNotEmpty) {
    return true;
  }
  return false;
}

/// Is [Polygon] (geom1) in [Polygon] (geom2)
/// Only takes into account outer rings
/// See http://stackoverflow.com/a/4833823/1979085
bool _isPolyInPoly(Polygon feature1, Polygon feature2) {
  for (var coord1 in feature1.coordinates[0]) {
    if (booleanPointInPolygon(coord1, feature2)) {
      return true;
    }
  }
  for (var coord2 in feature2.coordinates[0]) {
    if (booleanPointInPolygon(coord2, feature1)) {
      return true;
    }
  }
  var doLinesIntersect =
      lineIntersect(polygonToLine(feature1), polygonToLine(feature2));
  if (doLinesIntersect.features.isNotEmpty) {
    return true;
  }
  return false;
}

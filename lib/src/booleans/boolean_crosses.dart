import 'package:turf/src/invariant.dart';

import '../../helpers.dart';
import '../line_intersect.dart';
import '../polygon_to_line.dart';
import 'boolean_point_in_polygon.dart';

/// [booleanCrosses] returns [true] if the intersection results in a geometry whose
/// dimension is one less than the maximum dimension of the two source geometries
/// and the intersection set is interior to both source geometries.
/// [booleanCsses] returns [true] for only [MultiPoint]/[Polygon], [MultiPoint]/[LineString],
/// [LineString]/[LineString], [LineString]/[Polygon], and [LineString]/[MultiPolygon] comparisons.
/// Other comparisons are not supported as they are outside the OpenGIS Simple
/// [Feature]s spec and may give unexpected results.
/// example:
/// ```dart
/// var line1 = LineString(coordinates: [
///   Position.of([-2, 2]),
///   Position.of([4, 2])
/// ]);
/// var line2 = LineString(coordinates: [
///   Position.of([1, 1]),
///   Position.of([1, 2]),
///   Position.of([1, 3]),
///   Position.of([1, 4])
/// ]);
/// var cross = booleanCrosses(line1, line2);
/// //=true
/// ```
bool booleanCrosses(GeoJSONObject feature1, GeoJSONObject feature2) {
  var geom1 = getGeom(feature1);
  var geom2 = getGeom(feature2);

  var exception = Exception("$geom2 is not supperted");
  if (geom1 is MultiPoint) {
    if (geom2 is LineString) {
      return _doMultiPointAndLineStringCross(geom1, geom2);
    } else if (geom2 is Polygon) {
      return _doesMultiPointCrossPoly(geom1, geom2);
    } else {
      throw exception;
    }
  } else if (geom1 is LineString) {
    if (geom2 is MultiPoint) {
      // An inverse operation
      return _doMultiPointAndLineStringCross(geom2, geom1);
    } else if (geom2 is LineString) {
      return _doLineStringsCross(geom1, geom2);
    } else if (geom2 is Polygon) {
      return _doLineStringAndPolygonCross(geom1, geom2);
    } else {
      throw exception;
    }
  } else if (geom1 is Polygon) {
    if (geom2 is MultiPoint) {
      // An inverse operation
      return _doesMultiPointCrossPoly(geom2, geom1);
    } else if (geom2 is LineString) {
      // An inverse operation
      return _doLineStringAndPolygonCross(geom2, geom1);
    } else {
      throw exception;
    }
  } else {
    throw exception;
  }
}

bool _doMultiPointAndLineStringCross(
    MultiPoint multiPoint, LineString lineString) {
  var foundIntPoint = false;
  var foundExtPoint = false;
  var pointLength = multiPoint.coordinates.length;
  var i = 0;
  while (i < pointLength && !foundIntPoint && !foundExtPoint) {
    for (var i2 = 0; i2 < lineString.coordinates.length - 1; i2++) {
      var incEndVertices = true;
      if (i2 == 0 || i2 == lineString.coordinates.length - 2) {
        incEndVertices = false;
      }
      if (isPointOnLineSegment(
          lineString.coordinates[i2],
          lineString.coordinates[i2 + 1],
          multiPoint.coordinates[i],
          incEndVertices)) {
        foundIntPoint = true;
      } else {
        foundExtPoint = true;
      }
    }
    i++;
  }
  return foundIntPoint && foundExtPoint;
}

bool _doLineStringsCross(LineString lineString1, LineString lineString2) {
  var doLinesIntersect = lineIntersect(lineString1, lineString2);
  if (doLinesIntersect.features.isNotEmpty) {
    for (var i = 0; i < lineString1.coordinates.length - 1; i++) {
      for (var i2 = 0; i2 < lineString2.coordinates.length - 1; i2++) {
        var incEndVertices = true;
        if (i2 == 0 || i2 == lineString2.coordinates.length - 2) {
          incEndVertices = false;
        }
        if (isPointOnLineSegment(
            lineString1.coordinates[i],
            lineString1.coordinates[i + 1],
            lineString2.coordinates[i2],
            incEndVertices)) {
          return true;
        }
      }
    }
  }
  return false;
}

bool _doLineStringAndPolygonCross(LineString lineString, Polygon polygon) {
  Feature line = polygonToLine(polygon) as Feature;
  var doLinesIntersect = lineIntersect(lineString, line);
  if (doLinesIntersect.features.isNotEmpty) return true;

  return false;
}

bool _doesMultiPointCrossPoly(MultiPoint multiPoint, Polygon polygon) {
  var foundIntPoint = false;
  var foundExtPoint = false;
  var pointLength = multiPoint.coordinates.length;
  for (var i = 0; i < pointLength && (!foundIntPoint || !foundExtPoint); i++) {
    if (booleanPointInPolygon(multiPoint.coordinates[i], polygon)) {
      foundIntPoint = true;
    } else {
      foundExtPoint = true;
    }
  }

  return foundExtPoint && foundIntPoint;
}

/// Only takes into account outer rings
/// See http://stackoverflow.com/a/4833823/1979085
/// lineSegmentStart [Position] of start of line
/// lineSegmentEnd [Position] of end of line
/// pt [Position] of point to check
/// [incEnd] controls whether the [Point] is allowed to fall on the line ends
bool isPointOnLineSegment(
  Position lineSegmentStart,
  Position lineSegmentEnd,
  Position pt,
  bool incEnd,
) {
  var dxc = pt[0]! - lineSegmentStart[0]!;
  var dyc = pt[1]! - lineSegmentStart[1]!;
  var dxl = lineSegmentEnd[0]! - lineSegmentStart[0]!;
  var dyl = lineSegmentEnd[1]! - lineSegmentStart[1]!;
  var cross = dxc * dyl - dyc * dxl;
  if (cross != 0) {
    return false;
  }
  if (incEnd) {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0
          ? lineSegmentStart[0]! <= pt[0]! && pt[0]! <= lineSegmentEnd[0]!
          : lineSegmentEnd[0]! <= pt[0]! && pt[0]! <= lineSegmentStart[0]!;
    }
    return dyl > 0
        ? lineSegmentStart[1]! <= pt[1]! && pt[1]! <= lineSegmentEnd[1]!
        : lineSegmentEnd[1]! <= pt[1]! && pt[1]! <= lineSegmentStart[1]!;
  } else {
    if ((dxl).abs() >= (dyl).abs()) {
      return dxl > 0
          ? lineSegmentStart[0]! < pt[0]! && pt[0]! < lineSegmentEnd[0]!
          : lineSegmentEnd[0]! < pt[0]! && pt[0]! < lineSegmentStart[0]!;
    }
    return dyl > 0
        ? lineSegmentStart[1]! < pt[1]! && pt[1]! < lineSegmentEnd[1]!
        : lineSegmentEnd[1]! < pt[1]! && pt[1]! < lineSegmentStart[1]!;
  }
}

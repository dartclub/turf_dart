import 'package:turf/src/invariant.dart';
import 'package:turf/turf.dart';

import 'boolean_point_in_polygon.dart';
import 'boolean_point_on_line.dart';

/// [booleanContains] returns [true] if the second geometry is completely contained
/// by the first geometry.
/// The interiors of both geometries must intersect and, the interior and
/// boundary of the secondary must not intersect the exterior of the primary.
/// Boolean-contains returns the exact opposite result of the `turf/boolean-within`.
/// example:
/// ```dart
/// var line = LineString(coordinates: [
///   Position.of([1, 1]),
///   Position.of([1, 2]),
///   Position.of([1, 3]),
///   Position.of([1, 4])
/// ]);
/// var point = Point(coordinates: Position.of([1, 2]));
/// booleanContains(line, point);
/// //=true
/// ```
bool booleanContains(GeoJSONObject feature1, GeoJSONObject feature2) {
  var geom1 = getGeom(feature1);
  var geom2 = getGeom(feature2);

  var coords1 = (geom1 as GeometryType).coordinates;
  var coords2 = (geom2 as GeometryType).coordinates;
  Exception _exception() =>
      Exception("{feature2 $geom2 geometry not supported}");
  if (geom1 is Point) {
    if (geom2 is Point) {
      return coords1 == coords2;
    } else {
      throw _exception();
    }
  } else if (geom1 is MultiPoint) {
    if (geom2 is Point) {
      return _isPointInMultiPoint(geom1, geom2);
    } else if (geom2 is MultiPoint) {
      return _isMultiPointInMultiPoint(geom1, geom2);
    } else {
      throw _exception();
    }
  } else if (geom1 is LineString) {
    if (geom2 is Point) {
      return booleanPointOnLine(geom2, geom1, ignoreEndVertices: true);
    } else if (geom2 is LineString) {
      return _isLineOnLine(geom1, geom2);
    } else if (geom2 is MultiPoint) {
      return _isMultiPointOnLine(geom1, geom2);
    } else {
      throw _exception();
    }
  } else if (geom1 is Polygon) {
    if (geom2 is Point) {
      return booleanPointInPolygon((geom2).coordinates, geom1,
          ignoreBoundary: true);
    } else if (geom2 is LineString) {
      return _isLineInPoly(geom1, geom2);
    } else if (geom2 is Polygon) {
      return isPolyInPoly(geom1, geom2);
    } else if (geom2 is MultiPoint) {
      return _isMultiPointInPoly(geom1, geom2);
    } else {
      throw _exception();
    }
  } else {
    throw _exception();
  }
}

bool _isPointInMultiPoint(MultiPoint multiPoint, Point pt) {
  for (int i = 0; i < multiPoint.coordinates.length; i++) {
    if ((multiPoint.coordinates[i] == pt.coordinates)) {
      return true;
    }
  }
  return false;
}

bool _isMultiPointInMultiPoint(MultiPoint multiPoint1, MultiPoint multiPoint2) {
  for (Position coord2 in multiPoint2.coordinates) {
    bool match = false;
    for (Position coord1 in multiPoint1.coordinates) {
      if (coord2 == coord1) {
        match = true;
      }
    }
    if (!match) return false;
  }
  return true;
}

bool _isMultiPointOnLine(LineString lineString, MultiPoint multiPoint) {
  var haveFoundInteriorPoint = false;
  for (var coord in multiPoint.coordinates) {
    if (booleanPointOnLine(Point(coordinates: coord), lineString,
        ignoreEndVertices: true)) {
      haveFoundInteriorPoint = true;
    }
    if (!booleanPointOnLine(Point(coordinates: coord), lineString)) {
      return false;
    }
  }
  return haveFoundInteriorPoint;
}

bool _isMultiPointInPoly(Polygon polygon, MultiPoint multiPoint) {
  for (var coord in multiPoint.coordinates) {
    if (!booleanPointInPolygon(coord, polygon, ignoreBoundary: true)) {
      return false;
    }
  }
  return true;
}

bool _isLineOnLine(LineString lineString1, LineString lineString2) {
  var haveFoundInteriorPoint = false;
  for (Position coord in lineString2.coordinates) {
    if (booleanPointOnLine(
      Point(coordinates: coord),
      lineString1,
      ignoreEndVertices: true,
    )) {
      haveFoundInteriorPoint = true;
    }
    if (!booleanPointOnLine(
      Point(coordinates: coord),
      lineString1,
      ignoreEndVertices: false,
    )) {
      return false;
    }
  }
  return haveFoundInteriorPoint;
}

bool _isLineInPoly(Polygon polygon, LineString linestring) {
  var output = false;
  var i = 0;

  var polyBbox = bbox(polygon);
  var lineBbox = bbox(linestring);
  if (!doBBoxOverlap(polyBbox, lineBbox)) {
    return false;
  }
  for (i; i < linestring.coordinates.length - 1; i++) {
    var midPoint =
        getMidpoint(linestring.coordinates[i], linestring.coordinates[i + 1]);
    if (booleanPointInPolygon(
      midPoint,
      polygon,
      ignoreBoundary: true,
    )) {
      output = true;
      break;
    }
  }
  return output;
}

/// Is Polygon2 in Polygon1
/// Only takes into account outer rings
bool isPolyInPoly(GeoJSONObject geom1, GeoJSONObject geom2) {
  var poly1Bbox = bbox(geom1);
  var poly2Bbox = bbox(geom2);
  if (!doBBoxOverlap(poly1Bbox, poly2Bbox)) {
    return false;
  }

  for (var ring in (geom2 as GeometryType).coordinates) {
    for (var coord in ring) {
      if (!booleanPointInPolygon(coord, geom1)) {
        return false;
      }
    }
  }
  return true;
}

bool doBBoxOverlap(BBox bbox1, BBox bbox2) {
  if (bbox1[0]! > bbox2[0]!) {
    return false;
  }
  if (bbox1[2]! < bbox2[2]!) {
    return false;
  }
  if (bbox1[1]! > bbox2[1]!) {
    return false;
  }
  if (bbox1[3]! < bbox2[3]!) {
    return false;
  }
  return true;
}

Position getMidpoint(Position pair1, Position pair2) {
  return Position.of(
      [(pair1[0]! + pair2[0]!) / 2, (pair1[1]! + pair2[1]!) / 2]);
}

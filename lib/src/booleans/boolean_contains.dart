import 'package:turf/src/invariant.dart';
import 'package:turf/turf.dart';

import 'boolean_point_in_polygon.dart';
import 'boolean_point_on_line.dart';
import 'boolean_within_helper.dart';

/// [booleanContains] returns [true] if the second geometry is completely contained
/// by the first geometry.
/// The interiors of both geometries must intersect and, the interior and
/// boundary of the secondary must not intersect the exterior of the primary.
/// [booleanContains] returns the exact opposite result of the [booleanWithin].
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
  if (geom1 is Point) {
    if (geom2 is Point) {
      return coords1 == coords2;
    } else {
      throw FeatureNotSupported(geom1, geom2);
    }
  } else if (geom1 is MultiPoint) {
    if (geom2 is Point) {
      return isPointInMultiPoint(geom2, geom1);
    } else if (geom2 is MultiPoint) {
      return isMultiPointInMultiPoint(geom2, geom1);
    } else {
      throw FeatureNotSupported(geom1, geom2);
    }
  } else if (geom1 is LineString) {
    if (geom2 is Point) {
      return booleanPointOnLine(geom2, geom1, ignoreEndVertices: true);
    } else if (geom2 is LineString) {
      return isLineOnLine(geom2, geom1);
    } else if (geom2 is MultiPoint) {
      return isMultiPointOnLine(geom2, geom1);
    } else {
      throw FeatureNotSupported(geom1, geom2);
    }
  } else if (geom1 is Polygon) {
    if (geom2 is Point) {
      return booleanPointInPolygon((geom2).coordinates, geom1,
          ignoreBoundary: true);
    } else if (geom2 is LineString) {
      return isLineInPolygon(geom2, geom1);
    } else if (geom2 is Polygon) {
      return _isPolyInPoly(geom1, geom2);
    } else if (geom2 is MultiPoint) {
      return isMultiPointInPolygon(geom2, geom1);
    } else {
      throw FeatureNotSupported(geom1, geom2);
    }
  } else {
    throw FeatureNotSupported(geom1, geom2);
  }
}

/// Is Polygon2 in Polygon1
/// Only takes into account outer rings
bool _isPolyInPoly(GeoJSONObject geom1, GeoJSONObject geom2) {
  var poly1Bbox = bbox(geom1);
  var poly2Bbox = bbox(geom2);
  if (!_doBBoxesOverlap(poly1Bbox, poly2Bbox)) {
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

bool _doBBoxesOverlap(BBox bbox1, BBox bbox2) {
  if (bbox1[0]! > bbox2[0]! ||
      bbox1[2]! < bbox2[2]! ||
      bbox1[1]! > bbox2[1]! ||
      bbox1[3]! < bbox2[3]!) return false;

  return true;
}

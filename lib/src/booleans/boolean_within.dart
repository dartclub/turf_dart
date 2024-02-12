import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';

import 'boolean_helper.dart';

/// Returns [true] if the first [GeoJSONObject] is completely within the second [GeoJSONObject].
/// The interiors of both geometries must intersect and, the interior and boundary
/// of the primary (geometry a) must not intersect the exterior of the secondary
/// (geometry b). [booleanWithin] returns the exact opposite result of [booleanContains].
///
///
/// example:
/// ```dart
/// var point = Point(coordinates: [1, 2]);
/// var line = LineString(
///   coordinates: [
///     Position.of([1, 1]),
///     Position.of([1, 2]),
///     Position.of([1, 3]),
///     Position.of([1, 4])
///   ],
/// );
/// booleanWithin(point, line);
/// //=true
/// ```
bool booleanWithin(
  GeoJSONObject feature1,
  GeoJSONObject feature2,
) {
  var geom1 = getGeom(feature1);
  var geom2 = getGeom(feature2);

  switch (geom1.runtimeType) {
    case Point:
      final point = geom1 as Point;
      switch (geom2.runtimeType) {
        case MultiPoint:
          return isPointInMultiPoint(point, geom2 as MultiPoint);
        case LineString:
          return isPointOnLine(point, geom2 as LineString);
        case Polygon:
          return isPointInPolygon(point, geom2 as Polygon);
        case MultiPolygon:
          return isPointInMultiPolygon(point, geom2 as MultiPolygon);
        default:
          throw FeatureNotSupported(geom1, geom2);
      }
    case MultiPoint:
      final multipoint = geom1 as MultiPoint;
      switch (geom2.runtimeType) {
        case MultiPoint:
          return isMultiPointInMultiPoint(multipoint, geom2 as MultiPoint);
        case LineString:
          return isMultiPointOnLine(multipoint, geom2 as LineString);
        case Polygon:
          return isMultiPointInPolygon(multipoint, geom2 as Polygon);
        case MultiPolygon:
          return isMultiPointInMultiPolygon(multipoint, geom2 as MultiPolygon);
        default:
          throw FeatureNotSupported(geom1, geom2);
      }
    case LineString:
      final line = geom1 as LineString;
      switch (geom2.runtimeType) {
        case LineString:
          return isLineOnLine(line, geom2 as LineString);
        case Polygon:
          return isLineInPolygon(line, geom2 as Polygon);
        case MultiPolygon:
          return isLineInMultiPolygon(line, geom2 as MultiPolygon);
        default:
          throw FeatureNotSupported(geom1, geom2);
      }
    case Polygon:
      final polygon = geom1 as Polygon;
      switch (geom2.runtimeType) {
        case Polygon:
          return isPolygonInPolygon(polygon, geom2 as Polygon);
        case MultiPolygon:
          return isPolygonInMultiPolygon(polygon, geom2 as MultiPolygon);
        default:
          throw FeatureNotSupported(geom1, geom2);
      }
    default:
      throw FeatureNotSupported(geom1, geom2);
  }
}

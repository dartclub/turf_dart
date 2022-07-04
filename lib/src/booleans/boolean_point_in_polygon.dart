// http://en.wikipedia.org/wiki/Even%E2%80%93odd_rule
// modified from: https://github.com/substack/point-in-polygon/blob/master/index.js
// which was modified from http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
import 'package:pip/pip.dart';

import '../../helpers.dart';
import '../invariant.dart';

/// Takes a [Point], and a [Polygon] or [MultiPolygon]and determines if the
/// [Point] resides inside the [Polygon]. The polygon can be convex or concave.
/// The function accounts for holes. By taking a [Feature<Polygon>] or a
/// [Feature<MultiPolygon>]. [ignoreBoundary=false] should be set [true] if polygon's
/// boundary should be ignored when determining if the [Point] is inside the
/// [Polygon] otherwise false.
/// example:
/// ```dart
/// var pt = Point(coordinates: Position([-77, 44]));
/// var poly = Polygon(coordinates:[[
///   Position.of([-81, 41]),
///   Position.of([-81, 47]),
///   Position.of([-72, 47]),
///   Position.of([-72, 41]),
///   Position.of([-81, 41])
/// ]]);
/// turf.booleanPointInPolygon(pt, poly);
/// //= true
/// ```
bool booleanPointInPolygon(Position point, GeoJSONObject polygon,
    {bool ignoreBoundary = false}) {
  GeometryType? geom;
  List<List<List<Position>>>? polys;
  BBox? bbox = polygon.bbox;

  Exception exception = Exception('${polygon.type} is not supported');

  if (polygon is Feature) {
    if (polygon.geometry is Polygon || polygon.geometry is MultiPolygon) {
      return booleanPointInPolygon(point, polygon.geometry!);
    } else {
      throw exception;
    }
  } else if (polygon is GeometryType) {
    if (polygon is Polygon && polygon.coordinates.isNotEmpty) {
      geom = polygon;
      polys = [geom.coordinates];
    } else if (polygon is MultiPolygon && polygon.coordinates.isNotEmpty) {
      geom = polygon;
      polys = geom.coordinates;
    }
  } else {
    throw exception;
  }

  // Quick elimination if point is not inside bbox
  if (bbox != null && !_inBBox(point, bbox)) {
    return false;
  }

  var result = false;
  for (var i = 0; i < polys!.length; ++i) {
    var polyResult =
        pip(Point(coordinates: point), Polygon(coordinates: polys[i]));
    if (polyResult == 0) {
      return ignoreBoundary ? false : true;
    } else if (polyResult) {
      result = true;
    }
  }

  return result;
}

bool _inBBox(Position pt, BBox bbox) {
  return (bbox[0]! <= pt[0]! &&
      bbox[1]! <= pt[1]! &&
      bbox[2]! >= pt[0]! &&
      bbox[3]! >= pt[1]!);
}

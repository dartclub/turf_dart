import 'dart:math';

import '../helpers.dart';
import '../meta.dart';

/// Takes a [GeoJSONObject] and returns their area in square meters.
///
/// ```dart
/// Feature<Polygon> poly = Feature<Polygon>(
///   geometry: Polygon(coordinates: [
///     [
///       Position(125, -15),
///       Position(113, -22),
///       Position(117, -37),
///       Position(130, -33),
///       Position(148, -39),
///       Position(154, -27),
///       Position(144, -15),
///       Position(125, -15)
///     ]
///   ]),
/// );
///
/// var area = turf.area(polygon);
/// ```
num? area(GeoJSONObject geojson) {
  return geomReduce<num>(geojson, (value, geom, _, __, ___, ____) {
    return value! + _calculateArea(geom!);
  }, 0);
}

/// Calculate Area
num _calculateArea(GeometryType geom) {
  num total = 0;
  switch (geom.type) {
    case GeoJSONObjectType.polygon:
      return _polygonArea((geom as Polygon).coordinates);
    case GeoJSONObjectType.multiPolygon:
      geom as MultiPolygon;
      for (var i = 0; i < geom.coordinates.length; i++) {
        total += _polygonArea(geom.coordinates[i]);
      }
      return total;
    case GeoJSONObjectType.point:
    case GeoJSONObjectType.multiPoint:
    case GeoJSONObjectType.lineString:
    case GeoJSONObjectType.multiLineString:
      return 0;
    default:
      throw Exception('unsupported type ${geom.type}');
  }
}

num _polygonArea(List<List<Position>> coords) {
  num total = 0;
  if (coords.isNotEmpty) {
    total += _ringArea(coords[0]).abs();
    for (var i = 1; i < coords.length; i++) {
      total -= _ringArea(coords[i]).abs();
    }
  }
  return total;
}

///
/// Calculate the approximate area of the [Polygon] were it projected onto the earth in square meters.
///
/// Note that the area will be positive if ring is oriented clockwise, otherwise it will be negative.
///
/// Reference:
/// Robert. G. Chamberlain and William H. Duquette, "Some Algorithms for Polygons on a Sphere",
/// JPL Publication 07-03, Jet Propulsion
/// Laboratory, Pasadena, CA, June 2007 https://trs.jpl.nasa.gov/handle/2014/40409
num _ringArea(List<Position> coords) {
  Position p1;
  Position p2;
  Position p3;
  int lowerIndex;
  int middleIndex;
  int upperIndex;
  int i;
  num total = 0;
  final coordsLength = coords.length;

  if (coordsLength > 2) {
    for (i = 0; i < coordsLength; i++) {
      if (i == coordsLength - 2) {
        // i = N-2
        lowerIndex = coordsLength - 2;
        middleIndex = coordsLength - 1;
        upperIndex = 0;
      } else if (i == coordsLength - 1) {
        // i = N-1
        lowerIndex = coordsLength - 1;
        middleIndex = 0;
        upperIndex = 1;
      } else {
        // i = 0 to N-3
        lowerIndex = i;
        middleIndex = i + 1;
        upperIndex = i + 2;
      }
      p1 = coords[lowerIndex];
      p2 = coords[middleIndex];
      p3 = coords[upperIndex];
      total += (_rad(p3[0]!) - _rad(p1[0]!)) * sin(_rad(p2[1]!));
    }

    total = (total * earthRadius * earthRadius) / 2;
  }
  return total;
}

num _rad(num number) {
  return (number * pi) / 180;
}

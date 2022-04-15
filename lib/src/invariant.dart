import 'package:turf/turf.dart';

/// Unwraps a coordinate from a [Point], [Feature<Point>], and a [Position].
///
/// gets [Position], [Point], and [Feature<Point>] and returns [Position].
/// For example:
///
/// ```dart
/// var point = Point(coordinates: Position.named(lng: 10, lat: 10));
/// Position position = getCoord(point); // Position(10, 10)
Position getCoord(dynamic coord) {
  if (coord == null) {
    throw Exception("coord is required");
  }

  if (coord is Feature<Point> && coord.geometry != null) {
    return coord.geometry!.coordinates;
  }
  if (coord is Point) {
    return coord.coordinates;
  }
  if (coord is Position) {
    return coord;
  }

  throw Exception("coord must be GeoJSON Point or Position");
}

/// Unwraps coordinates from a [Feature], [GeometryObject] or a [List]
///
/// Gets a [List<dynamic>], [GeometryObject] or a [Feature] or a [List<dynamic>] and
/// returns [List<dynamic>].
/// For example:
///
/// ```dart
/// var polygon = Polygon(coordinates: [
///    [
///     Position(119.32, -8.7),
///     Position(119.55, -8.69),
///     Position(119.51, -8.54),
///     Position(119.32, -8.7)
///     ]
///  ]);
///
/// var coords = getCoords(poly);
/// /* [[Position(119.32, -8.7),
///  Position(119.55, -8.69),
///  Position(119.51, -8.54),
///  Position(119.32, -8.7)]] */
/// ```
List<dynamic> getCoords(dynamic coords) {
  if (coords == null) {
    throw Exception("coords is required");
  }

  if (coords is List) {
    return coords;
  }

  if (coords is Feature && coords.geometry != null) {
    return _getCoordsForGeometry(coords.geometry!);
  }

  if (coords is GeometryObject) {
    return _getCoordsForGeometry(coords);
  }

  throw Exception(
      "Parameter must be a List<dynamic>, Geometry, Feature. coords Feature, Geometry Object or a List");
}

_getCoordsForGeometry(GeometryObject geom) {
  if (geom is Point || geom is GeometryCollection) {
    throw Exception("Type must contain a list of Positions e.g Polygon");
  }

  return (geom as GeometryType).coordinates;
}

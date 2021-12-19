import 'package:turf/turf.dart';

///
/// Unwrap a coordinate from a Point Feature, Geometry or a single coordinate.
///
/// @name getCoord
/// @param {Array<number>|Geometry<Point>|Feature<Point>} coord GeoJSON Point or an Array of numbers
/// @returns {Array<number>} coordinates
///
/// For example:
///
/// ```dart
/// var point = Point(coordinates: Position.named(lng: 10, lat: 10));
/// Position position = getCoord(point); // lng: 10, lat: 10
/// ```
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

  throw Exception("coord must be GeoJSON Point or an Array of numbers");
}

///
/// Unwrap coordinates from a Feature, Geometry Object or an Array
///
/// @name getCoords
/// @param {Array<any>|Geometry|Feature} coords Feature, Geometry Object or an Array
/// @returns {Array<any>} coordinates
/// @example
/// var poly = turf.polygon([[[119.32, -8.7], [119.55, -8.69], [119.51, -8.54], [119.32, -8.7]]]);
///
/// var coords = turf.getCoords(poly);
/// //= [[[119.32, -8.7], [119.55, -8.69], [119.51, -8.54], [119.32, -8.7]]]
///
List getCoords<T extends GeometryType>(dynamic coords) {
  if (coords == null) {
    throw Exception("coords is required");
  }

  if (coords is Feature<T> && coords.geometry != null) {
    return coords.geometry!.coordinates;
  }
  if (coords is T) {
    return coords.coordinates;
  }
  if (coords is List) {
    return coords;
  }

  throw Exception(
      "coords must be GeoJSON Feature, Geometry Object or an Array");
}

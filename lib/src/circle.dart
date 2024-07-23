import 'package:turf/helpers.dart';
import 'package:turf/invariant.dart';
import 'package:turf/src/booleans/boolean_helper.dart';
import 'destination.dart';

/// Takes a [Point] or a [Feature<Point>] and calculates the circle polygon given a radius in degrees, radians, miles, or kilometers; and steps for precision.
///
///  example:
/// ```dart
/// var properties = { 'foo': 'bar' };
/// var point = Feature(geometry: Point(coordinates: Position.of([-75.343, 39.984])));
/// final polygonCircle = circle(
///                 feature.geometry!,
///                 radius,
///                 steps: 32,
///                 unit: Unit.meters,
///                 properties: feature.properties,
///               );
/// ```
Feature<Polygon> circle(
  GeoJSONObject center,
  num radius, {
  num? steps,
  Unit? unit,
  Map<String, dynamic>? properties,
}) {
  steps ??= 64;
  unit ??= Unit.kilometers;
  Point origin;
  final geometry = getGeom(center);
  if (geometry is Point) {
    origin = geometry;
  } else {
    throw GeometryNotSupported(geometry);
  }
  properties ??=
      center is Feature && center.properties != null ? center.properties : {};
  final List<Position> coordinates = [];
  for (var i = 0; i < steps; i++) {
    final c = destination(origin, radius, (i * -360) / steps, unit).coordinates;
    coordinates.add(c);
  }
  coordinates.add(coordinates[0]);
  return Feature<Polygon>(
    properties: properties,
    geometry: Polygon(coordinates: [coordinates]),
  );
}

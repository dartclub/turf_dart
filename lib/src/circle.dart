import 'package:turf/helpers.dart';
import 'destination.dart';

/// Takes a [Point] and calculates the circle polygon given a radius in degrees, radians, miles, or kilometers; and steps for precision.
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
  Point center,
  num radius, {
  num? steps = 64,
  Unit? unit = Unit.kilometers,
  Map<String, dynamic>? properties = const {},
}) {
  steps ??= 64;
  unit ??= Unit.kilometers;
  final List<Position> coordinates = [];
  for (var i = 0; i < steps; i++) {
    final c = destination(center, radius, (i * -360) / steps, unit).coordinates;
    coordinates.add(c);
  }
  coordinates.add(coordinates[0]);
  return Feature<Polygon>(
    properties: properties,
    geometry: Polygon(coordinates: [coordinates]),
  );
}

import 'dart:math';

import 'geojson.dart';
import 'helpers.dart';

Position destinationRaw(Position origin, num distance, num bearing,
    [Unit unit = Unit.kilometers]) {
  num longitude1 = degreesToRadians(origin.lng);
  num latitude1 = degreesToRadians(origin.lat);
  num bearingRad = degreesToRadians(bearing);
  num radians = lengthToRadians(distance, unit);

  // Main
  num latitude2 = asin(sin(latitude1) * cos(radians) +
      cos(latitude1) * sin(radians) * cos(bearingRad));
  num longitude2 = longitude1 +
      atan2(sin(bearingRad) * sin(radians) * cos(latitude1),
          cos(radians) - sin(latitude1) * sin(latitude2));
  return Position.named(
    lng: radiansToDegrees(longitude2),
    lat: radiansToDegrees(latitude2),
  );
}

/// Takes a [Point] and calculates the location of a destination point given a distance in
/// degrees, radians, miles, or kilometers; and bearing in degrees.
/// This uses the [Haversine formula](http://en.wikipedia.org/wiki/Haversine_formula) to account for global curvature.
/// For example:
///
/// ```dart
/// var point = Point(coordinates: Position(-75.343, 39.984));
/// var distance = 50;
/// var bearing = 90;
/// var options = Unit.miles;
///
/// var destination = destination(point, distance, bearing, options);
///
/// //addToMap
/// var addToMap = [point, destination]
/// destination.properties['marker-color'] = '#f00';
/// point.properties['marker-color'] = '#0f0';
/// ```

Point destination(Point origin, num distance, num bearing,
        [Unit unit = Unit.kilometers]) =>
    Point(
      coordinates: destinationRaw(origin.coordinates, distance, bearing, unit),
    );

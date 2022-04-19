import 'dart:math';

import 'geojson.dart';
import 'helpers.dart';

//http://en.wikipedia.org/wiki/Haversine_formula
//http://www.movable-type.co.uk/scripts/latlong.html

num distanceRaw(Position from, Position to, [Unit unit = Unit.kilometers]) {
  var dLat = degreesToRadians((to.lat - from.lat));
  var dLon = degreesToRadians((to.lng - from.lng));
  var lat1 = degreesToRadians(from.lat);
  var lat2 = degreesToRadians(to.lat);

  num a = pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);

  return radiansToLength(2 * atan2(sqrt(a), sqrt(1 - a)), unit);
}

/// Calculates the distance between two [Point]s in degrees, radians, miles, or kilometers.
///  This uses the [Haversine formula](http://en.wikipedia.org/wiki/Haversine_formula) to account for global curvature.
///  For example:
///
/// ```dart
/// var from = Point(coordinates: Position(-75.343, 39.984));
/// var to = Point(coordinates: Position(-75.443, 39.984));
/// var options = Unit.miles;
///
/// var distance = distance(from, to, options);
/// ```
num distance(Point from, Point to, [Unit unit = Unit.kilometers]) =>
    distanceRaw(from.coordinates, to.coordinates, unit);

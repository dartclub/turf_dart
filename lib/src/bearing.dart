import 'dart:math';

import 'geojson.dart';
import 'helpers.dart';

// http://en.wikipedia.org/wiki/Haversine_formula
// http://www.movable-type.co.uk/scripts/latlong.html

num bearingRaw(Position start, Position end, {bool calcFinal = false}) {
  // Reverse calculation
  if (calcFinal == true) {
    return calculateFinalBearingRaw(start, end);
  }

  num lng1 = degreesToRadians(start.lng);
  num lng2 = degreesToRadians(end.lng);
  num lat1 = degreesToRadians(start.lat);
  num lat2 = degreesToRadians(end.lat);
  num a = sin(lng2 - lng1) * cos(lat2);
  num b = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lng2 - lng1);

  return radiansToDegrees(atan2(a, b));
}

/// Takes two [Point]s and finds the geographic bearing between them,
/// i.e. the angle measured in degrees from the north line (0 degrees)
/// For example:
///
/// ```dart
/// var point1 = Point(coordinates: Position(-75.343, 39.984));
/// var point2 = Point(coordinates: Position((-75.543, 39.123));
///
/// var bearing = bearing(point1, point2);
/// //addToMap
/// var addToMap = [point1, point2]
/// point1.properties['marker-color'] = '#f00'
/// point2.properties['marker-color'] = '#0f0'
/// point1.properties.bearing = bearing
/// ```

num bearing(Point start, Point end, {bool calcFinal = false}) =>
    bearingRaw(start.coordinates, end.coordinates, calcFinal: calcFinal);

num calculateFinalBearingRaw(Position start, Position end) {
  // Swap start & end
  num reverseBearing = bearingRaw(end, start) + 180;
  return reverseBearing.remainder(360);
}

/// Calculates Final Bearing
num calculateFinalBearing(Point start, Point end) =>
    calculateFinalBearingRaw(start.coordinates, end.coordinates);

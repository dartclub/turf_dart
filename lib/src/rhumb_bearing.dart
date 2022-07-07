// https://en.wikipedia.org/wiki/Rhumb_line
import 'package:turf/src/invariant.dart';
import 'dart:math' as math;
import '../helpers.dart';

/// Takes two [Point] and finds the bearing angle between them along a Rhumb line
/// i.e. the angle measured in degrees start the north line (0 degrees)
/// [kFinal] calculates the final bearing if true.
/// Returns bearing from north in decimal degrees, between -180 and 180 degrees (positive clockwise)
/// example:
/// ```dart
/// var point1 = Feature(geometry: Point(coordinates: Position.of([-75.343, 39.984])), properties: {"marker-color": "#F00"});
/// var point2 = Feature(geometry: Point(coordinates: Position.of([-75.534, 39.123])), properties: {"marker-color": "#00F"});
/// var bearing = rhumbBearing(point1.geometry, point2.geometry);
/// //addToMap
/// var addToMap = [point1, point2];
/// point1.properties['bearing'] = bearing;
/// point2.properties['bearing'] = bearing;
/// ```
num rhumbBearing(Point start, Point end, {bool kFinal = false}) {
  num bear360;
  if (kFinal) {
    bear360 = calculateRhumbBearing(getCoord(end), getCoord(start));
  } else {
    bear360 = calculateRhumbBearing(getCoord(start), getCoord(end));
  }

  var bear180 = bear360 > 180 ? -(360 - bear360) : bear360;

  return bear180;
}

/// Returns the bearing from ‘this’ [Point] to destination [Point] along a rhumb line.
/// Adapted from Geodesy: https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js
/// Returns Bearing in degrees from north.
/// example
/// ```dart
/// var p1 = Position.named(lng: 51.127, lat: 1.338);
/// var p2 = Position.named(lng: 50.964, lat: 1.853);
/// var d = p1.rhumbBearingTo(p2); // 116.7 m
/// ```
num calculateRhumbBearing(Position from, Position to) {
  // φ => phi
  // Δλ => deltaLambda
  // Δψ => deltaPsi
  // θ => theta
  num phi1 = degreesToRadians(from.lat);
  num phi2 = degreesToRadians(to.lat);
  num deltaLambda = degreesToRadians(to.lng - from.lng);
  // if deltaLambda over 180° take shorter rhumb line across the anti-meridian:
  if (deltaLambda > math.pi) {
    deltaLambda -= 2 * math.pi;
  }
  if (deltaLambda < -math.pi) {
    deltaLambda += 2 * math.pi;
  }

  double deltaPsi = math
      .log(math.tan(phi2 / 2 + math.pi / 4) / math.tan(phi1 / 2 + math.pi / 4));

  double theta = math.atan2(deltaLambda, deltaPsi);

  return (radiansToDegrees(theta) + 360) % 360;
}

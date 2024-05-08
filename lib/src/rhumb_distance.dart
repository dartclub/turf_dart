import 'dart:math' as math;

import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';

/// Calculates the distance along a rhumb line between two [Point] in degrees, radians,
/// miles, or kilometers.
///
/// example:
/// ```dart
/// var from = Feature(geometry: Point(coordinates: Position.of([-75.343, 39.984])));
/// var to = Feature(geometry: Point(coordinates: Position.of([-75.534, 39.123])));
///
/// var distance = turf.rhumbDistance(from, to, Unit.meters);
/// ```

num rhumbDistance(Point from, Point to, [Unit unit = Unit.kilometers]) {
  final origin = getCoord(from);
  final destination = getCoord(to);

  // compensate the crossing of the 180th meridian (https://macwright.org/2016/09/26/the-180th-meridian.html)
  // solution from https://github.com/mapbox/mapbox-gl-js/issues/3250#issuecomment-294887678
  final compensateLng = (destination.lng - origin.lng) > 180
      ? -360
      : (origin.lng - destination.lng) > 180
          ? 360
          : 0;

  final distanceInMeters = calculateRhumbDistance(
      origin, Position(destination.lng + compensateLng, destination.lat));
  final distance = convertLength(distanceInMeters, Unit.meters, unit);
  return distance;
}

///
/// Returns the distance traveling from ‘this’ point to destination point along a rhumb line.
/// Adapted from Geodesy ‘distanceTo‘: https://github.com/chrisveness/geodesy/blob/master/latlon-spherical.js
///
/// example:
/// ```dart
/// var p1 = Feature(geometry: Point(coordinates: Position.of([1.338, 51.127])));
/// var p2 = Feature(geometry: Point(coordinates: Position.of([1.853, 50.964])));
/// var d = calculateRhumbDistance(p1, p2); // 40310 m
/// ```
///

num calculateRhumbDistance(Position origin, Position destination,
    [num radius = earthRadius]) {
  final R = radius;
  final phi1 = (origin.lat * math.pi) / 180;
  final phi2 = (destination.lat * math.pi) / 180;
  final dPhi = phi2 - phi1;

  var dLambda = ((destination.lng - origin.lng).abs() * math.pi) / 180;
  // if dLon over 180° take shorter rhumb line across the anti-meridian:
  if (dLambda > math.pi) {
    dLambda -= 2 * math.pi;
  }

  // on Mercator projection, longitude distances shrink by latitude; q is the 'stretch factor'
  // q becomes ill-conditioned along E-W line (0/0); use empirical tolerance to avoid it
  final dPsi = math
      .log(math.tan(phi2 / 2 + math.pi / 4) / math.tan(phi1 / 2 + math.pi / 4));
  final q = dPsi.abs() > 10e-12 ? dPhi / dPsi : math.cos(phi1);

  // distance is pythagoras on 'stretched' Mercator projection
  final delta = math.sqrt(
      dPhi * dPhi + q * q * dLambda * dLambda); // angular distance in radians
  final dist = delta * R;

  return dist;
}

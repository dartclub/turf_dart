import 'dart:math';

import 'geojson.dart';
import 'helpers.dart';

num bearingRaw(Position start, Position end, {bool calcFinal = false}) {
  // Reverse calculation
  if (calcFinal == true) {
    return calculateFinalBearingRaw(start, end);
  }

  num lon1 = degreesToRadians(start.lng);
  num lon2 = degreesToRadians(end.lng);
  num lat1 = degreesToRadians(start.lat);
  num lat2 = degreesToRadians(start.lat);
  num a = sin(lon2 - lon1) * cos(lat2);
  num b = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);

  return radiansToDegrees(atan2(a, b));
}

num bearing(Point start, Point end, {bool calcFinal = false}) =>
    bearingRaw(start.coordinates, end.coordinates, calcFinal: calcFinal);

num calculateFinalBearingRaw(Position start, Position end) {
  // Swap start & end
  var bear = bearingRaw(end, start);
  bear = (bear + 180) % 360;
  return bear;
}

num calculateFinalBearing(Point start, Point end) =>
    calculateFinalBearingRaw(start.coordinates, end.coordinates);

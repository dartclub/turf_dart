import 'dart:math';

import 'geojson.dart';
import 'helpers.dart';

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

num bearing(Point start, Point end, {bool calcFinal = false}) =>
    bearingRaw(start.coordinates!, end.coordinates!, calcFinal: calcFinal);

num calculateFinalBearingRaw(Position start, Position end) {
  // Swap start & end
  num reverseBearing = bearingRaw(end, start) + 180;
  return reverseBearing.remainder(360);
}

num calculateFinalBearing(Point start, Point end) =>
    calculateFinalBearingRaw(start.coordinates!, end.coordinates!);

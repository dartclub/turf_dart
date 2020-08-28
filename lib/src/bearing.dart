import 'dart:math';

import '../turf_dart.dart';
import 'helpers.dart';

num bearing(Position start, Position end, {calcFinal = false}) {
  // Reverse calculation
  if (calcFinal == true) {
    return calculateFinalBearing(start, end);
  }

  num lon1 = degreesToRadians(start.lng);
  num lon2 = degreesToRadians(end.lng);
  num lat1 = degreesToRadians(start.lat);
  num lat2 = degreesToRadians(start.lat);
  num a = sin(lon2 - lon1) * cos(lat2);
  num b = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);

  return radiansToDegrees(atan2(a, b));
}

num calculateFinalBearing(Position start, Position end) {
  // Swap start & end
  var bear = bearing(end, start);
  bear = (bear + 180) % 360;
  return bear;
}

import 'dart:math';

import 'geojson.dart';
import 'helpers.dart';

Position destination(Position origin, num distance, num bearing, [Unit unit]) {
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
